resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "main-monitoring"
  dashboard_body = jsonencode({
    widgets = [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 8,
        "height": 6,
        "properties": {
          "metrics": [
            [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id ]
          ],
          "period": 300,
          "stat": "Average",
          "region": var.region,
          "title": "RDS CPU 사용률"
        }
      },
      {
        "type": "log",
        "x": 8,
        "y": 0,
        "width": 8,
        "height": 6,
        "properties": {
          "query": "fields @timestamp, @message | filter @message like /실패/ | sort @timestamp desc | limit 20",
          "region": var.region,
          "title": "Lambda: MAIL_SEND_FAIL 로그",
          "logGroupNames": [
            "/aws/lambda/news-lambda-handler"
          ],
          "view": "table",
          "stacked": false
        }
      },
      {
        "type": "log",
        "x": 8,
        "y": 6,
        "width": 8,
        "height": 6,
        "properties": {
          "query": "fields @timestamp, @message | filter @message like /성공/ | sort @timestamp desc | limit 20",
          "region": var.region,
          "title": "Lambda: MAIL_SEND_SUCCESS 로그",
          "logGroupNames": [
            "/aws/lambda/news-lambda-handler"
          ],
          "view": "table",
          "stacked": false
        }
      }
    ]
  })
}
