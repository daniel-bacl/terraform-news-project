import pymysql
import os

def lambda_handler(event, context):
    host_port = os.environ["DB_HOST"].split(":")
    db_host = host_port[0]
    db_port = int(host_port[1]) if len(host_port) > 1 else int(os.environ.get("DB_PORT", 3306))

    conn = pymysql.connect(
            host=db_host,
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASSWORD'],
            database=os.environ['DB_NAME'],
            port=db_port
    )

    cursor = conn.cursor()
    with open('/var/task/init.sql', 'r') as f:
        sql_commands = f.read().split(';')
        for command in sql_commands:
            command = command.strip()
            if command:
                cursor.execute(command)
    conn.commit()
    cursor.close()
    conn.close()
    return {'status': 'success'}
