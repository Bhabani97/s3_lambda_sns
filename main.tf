
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.iam_for_lambda.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {      "Sid": "Stmt1634882425628",
      "Action": "logs:*",
      "Effect": "Allow",
    
    }

  ]


  "Version": "2012-10-17",
  "Statement": [
    {
    ",
      "Action": "*",
      "Effect": "Allow",
    
  ]
  
  "Version": "2012-10-17",
  "Statement": [
    {
    
      "Action": "*",
      "Effect": "Allow",
      
    }
  ]

}

)

}

data "archive_file" "init" {
  type        = "zip"
  source_file = "${path.module}/hello.py"
  output_path = "${path.module}/files/hello.zip"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "${path.module}/files/hello.zip"
  function_name = "welcome"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "hello.welcome"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
 # source_code_hash = filebase64sha256("${path.module}/files/hello.zip")

  runtime = "python3.8"

 
}
# Creating s3 resource for invoking to lambda function
resource "aws_s3_bucket" "terraform_bucket1997" {
bucket = "my-test-bucket-terraform1997"
acl    = "private"
tags = {
Name        = "My bucket"
Environment = "Dev"
}
}
# Adding S3 bucket as trigger to my lambda and giving the permissions
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.terraform_bucket1997.arn
}
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.terraform_bucket1997.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.test_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    #filter_prefix       = "AWSLogs/"
    #filter_suffix       = ".log"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

# create sns topic

resource "aws_sns_topic" "topic" {
  name = "mytopic"
}

#sns subscription

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.test_lambda.arn
}


#aws_lambda_permission.with_sns will allow SNS to call Lambda 

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.topic.arn
}



