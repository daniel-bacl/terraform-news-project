 ## 코드에 CloudWatch 코드 입력


# ---------- 기본 의존 ----------
import enum, json, pymysql, boto3, traceback, os
from datetime import datetime, timezone, timedelta
from contextlib import contextmanager
from collections import defaultdict
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


# ---------- DB 설정 ----------
DB = dict(
    host=os.environ.get("DB_HOST"),
    user=os.environ.get("DB_USER"),
    password=os.environ.get("DB_PASSWORD"),
    database=os.environ.get("DB_NAME"),
    charset=os.environ.get("DB_CHARSET", "utf8mb4"),
    cursorclass=pymysql.cursors.DictCursor
)

# ---------- SES 설정 ----------
ses = boto3.client("ses", region_name="ap-northeast-2")
SES_SENDER = os.environ.get("SES_SENDER")


# ---------- 상태 코드 enum ----------
class St(enum.IntEnum):
    SENT = 1
    SUCCESS = 2
    FAIL = 3


# ---------- DB 커넥션 ----------
@contextmanager
def db():
    conn = pymysql.connect(**DB)
    try:
        yield conn.cursor()
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


# ----------------------------------------------------------------------
# 0) 뉴스+유저 조회
# ----------------------------------------------------------------------
from datetime import datetime, timedelta, timezone

def fetch_targets():
    # 현재 시각 (한국시간 기준, UTC+9)
    current_hour = (datetime.utcnow() + timedelta(hours=9)).hour

    q = """
    SELECT c.id   AS cid,
           k.keyword,
           n.title, n.link,
           u.id   AS uid,
           u.email
      FROM crolling  c
      JOIN keyword   k ON k.id = c.keyword_id
      JOIN news      n ON n.crolling_id = c.id
      JOIN subscribe s ON s.keyword_id = k.id
      JOIN users     u ON u.id = s.user_id
 LEFT JOIN send_history sh 
       ON sh.user_id = u.id AND sh.crolling_id = c.id
     WHERE sh.id IS NULL
       AND u.send_hour = %s
    ORDER BY c.id
    """

    with db() as cur:
        cur.execute(q, (str(current_hour).zfill(2),))  # "01" ~ "23" 두자리 맞춤
        return cur.fetchall()

# ----------------------------------------------------------------------
# 1) 이메일 발송
# ----------------------------------------------------------------------
def send_via_ses(email: str, news_by_keyword: dict, date_str: str):
    subject = f"[뉴스 알림] ({date_str})"

    body_lines = [
        f"안녕하세요. {email} 구독자님\n\n다음 키워드에 대한 새로운 뉴스가 등록되었습니다.\n"
    ]

    for keyword, news_list in news_by_keyword.items():
        body_lines.append(f"[{keyword}]")
        for title, link in news_list:
            body_lines.append(f"• {title} : {link}")
        body_lines.append("")

    body_lines.append("감사합니다.")
    body_text = "\n".join(body_lines)

    logger.info(f"[Mail Send Try] 대상={email}, 제목={subject}")

    response = ses.send_email(
        Source=SES_SENDER,
        Destination={"ToAddresses": [email]},
        Message={
            "Subject": {"Data": subject, "Charset": "UTF-8"},
            "Body": {
                "Text": {"Data": body_text, "Charset": "UTF-8"}
            }
        }
    )

    logger.info(f"[Mail Send Success] 대상={email}, SES 응답={response['MessageId']}")


# ----------------------------------------------------------------------
# 2) 발송 이력 기록
# ----------------------------------------------------------------------
def add_history(uid: int, cid: int) -> int:
    with db() as cur:
        cur.execute(
            """
            INSERT IGNORE INTO send_history (user_id, crolling_id, send_status_id, sent_at)
            VALUES (%s, %s, %s, %s)
            """,
            (uid, cid, St.SENT, datetime.now(timezone.utc)),
        )
        return cur.lastrowid

def update_history(hid: int, status: St):
    with db() as cur:
        cur.execute(
            "UPDATE send_history SET send_status_id=%s, sent_at=%s WHERE id=%s",
            (status, datetime.now(timezone.utc), hid),
        )

def mark_sent(cids: set[int]):
    if not cids:
        return
    with db() as cur:
        cur.executemany(
            "UPDATE crolling SET is_send = 1 WHERE id = %s",
            [(cid,) for cid in cids]
        )


# ----------------------------------------------------------------------
# 3) Lambda Entry Point
# ----------------------------------------------------------------------
def lambda_handler(event, context): 
    rows = fetch_targets()

    if not rows:
        logger.info("발송 대상이 없습니다. (no new items)")
        return {"statusCode": 200, "body": json.dumps({"msg": "no new items"})}

    today = datetime.now().strftime("%Y-%m-%d")
    grouped = defaultdict(lambda: {
        "news_by_keyword": defaultdict(list),
        "uids": set(),
        "cids": set()
    })

    for r in rows:
        email = r["email"]
        keyword = r["keyword"]
        grouped[email]["news_by_keyword"][keyword].append((r["title"], r["link"]))
        grouped[email]["uids"].add(r["uid"])
        grouped[email]["cids"].add(r["cid"])

    for email, data in grouped.items():
        uid = list(data["uids"])[0]

        # 여러 crolling_id 모두 기록
        hids = []
        for cid in data["cids"]:
            hid = add_history(uid, cid)
            hids.append(hid)

        try:
            send_via_ses(email, data["news_by_keyword"], today)
            for hid in hids:
                update_history(hid, St.SUCCESS)
        except Exception as e:
            logger.error(f"[Mail Send Fail] 대상={email}, 에러={e}")
            logger.error(traceback.format_exc())
            for hid in hids:
                update_history(hid, St.FAIL)


    logger.info(f"총 {len(grouped)}명에게 뉴스 알림 전송 완료")
    return {"statusCode": 200, "body": json.dumps({"msg": f"processed {len(grouped)} users"})}
