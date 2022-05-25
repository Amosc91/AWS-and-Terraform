resource "aws_s3_bucket" "nginx_access_log" {
  bucket = "nginx-access-log-bucket"

  tags = {
    Name = "nginx-access-log-bucket"
  }
}

resource "aws_s3_bucket_acl" "nginx_bucket_acl" {
    bucket = aws_s3_bucket.nginx_access_log.id
    acl    = "private"
  
}