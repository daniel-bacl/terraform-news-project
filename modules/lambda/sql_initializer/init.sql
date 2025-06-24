
-- 사용자 테이블
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    auth_code CHAR(8), 
    send_hour VARCHAR(2),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 키워드 테이블
CREATE TABLE keyword (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    keyword VARCHAR(100) NOT NULL UNIQUE,
    subscribe_count INT DEFAULT 0
);

-- 구독 매핑 테이블
CREATE TABLE subscribe (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    keyword_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, keyword_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (keyword_id) REFERENCES keyword(id)
);

-- 크롤링 기록 테이블
CREATE TABLE crolling (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    keyword_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (keyword_id) REFERENCES keyword(id)
);

-- 뉴스 테이블
CREATE TABLE news (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    crolling_id BIGINT NOT NULL,
    title VARCHAR(500) NOT NULL,
    link VARCHAR(700) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (crolling_id) REFERENCES crolling(id)
);

-- 발송 상태 코드 테이블
CREATE TABLE send_status (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    send_status VARCHAR(50) NOT NULL UNIQUE
);

-- 발송 이력 테이블
CREATE TABLE send_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    crolling_id BIGINT NOT NULL,
    send_status_id BIGINT NOT NULL DEFAULT 1,
    sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, crolling_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (crolling_id) REFERENCES crolling(id),
    FOREIGN KEY (send_status_id) REFERENCES send_status(id)
);

INSERT INTO send_status (`send_status`) 
VALUES ('send'),    # 1 기본값
('success'),		# 2 성공
('fail');			# 3 실패