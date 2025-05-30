import pymysql
import os

def lambda_handler(event, context):
    conn = pymysql.connect(
        host=os.environ['DB_HOST'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASSWORD'],
        database=os.environ['DB_NAME'],
        port=int(os.environ.get('DB_PORT', 3306))
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
