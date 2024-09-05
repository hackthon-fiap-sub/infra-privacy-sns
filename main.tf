
# Criação do recurso SQS
resource "aws_sqs_queue" "terraform_queue" {
  name                       = var.queue_name
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600
  delay_seconds              = 30
  receive_wait_time_seconds  = 0
  sqs_managed_sse_enabled    = true

  tags = {
    Environment = "ClientPrivacyNotificaction"
  }
}

# Criação do recurso SNS
resource "aws_sns_topic" "client_privacy_topic" {
  name = var.sns_topic_name

  tags = {
    Environment = "SelectgearmotorsClientPrivacyNotificaction"
  }
}

# Associação da política com a fila SQS
resource "aws_sqs_queue_policy" "client_privacy_queue_policy" {
  queue_url = aws_sqs_queue.terraform_queue.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "sqspolicy",
    "Statement": [
      {
        "Sid": "001",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "sqs:SendMessage",
        "Resource": aws_sqs_queue.terraform_queue.arn,
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": aws_sns_topic.client_privacy_topic.arn
          }
        }
      }
    ]
  })
}

# Inscrição no tópico SNS
resource "aws_sns_topic_subscription" "client_privacy_topic_subscription" {
  topic_arn = aws_sns_topic.client_privacy_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.terraform_queue.arn 
  #filter_policy = jsonencode({
    #attribute = ["value"]
  #})
}
