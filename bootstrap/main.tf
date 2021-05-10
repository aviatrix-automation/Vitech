provider "aws" {
  profile = var.profile
  region  = var.region
}

resource "aws_iam_role_policy" "pan_bootstrap_policy" {
  name = "pan-bootstrap-policy"
  role = aws_iam_role.pan_bootstrap_s3_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::*"
          ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "pan_bootstrap_s3_role" {
  name = "pan-bootstrap-s3-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "pan_bootstrap_s3_role" {
  name = "pan-bootstrap-s3-role"
  role = aws_iam_role.pan_bootstrap_s3_role.name
}

output "bootstrap_s3_role" {
  value = aws_iam_role.pan_bootstrap_s3_role.id
}


/*
################################################################
 Create the S3 bucket and set its folder structure
 > Needs to be deployed in the same AWS account as the firewalls
################################################################
*/


resource "aws_s3_bucket" "avtx_panvm_bootstrap" {
  bucket_prefix = "avtx-panvm-bootstrap"
  acl           = "private"
  tags = {
    Name = "PAN VM Bootstrap"
  }
}

resource "aws_s3_bucket_object" "panvm_content" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap.id
  acl    = "private"
  key    = "content/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "panvm_license" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap.id
  acl    = "private"
  key    = "license/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "panvm_software" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap.id
  acl    = "private"
  key    = "software/"
  source = "/dev/null"
}


/*
################################################################
 Create the HA S3 bucket and set its folder structure
 > Needs to be deployed in the same AWS account as the firewalls
################################################################
*/


resource "aws_s3_bucket" "avtx_panvm_bootstrap_ha" {
  bucket_prefix = "avtx-panvm-bootstrap-ha"
  acl           = "private"
  tags = {
    Name = "PAN VM Bootstrap"
  }
}

resource "aws_s3_bucket_object" "panvm_content_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_ha.id
  acl    = "private"
  key    = "content/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "panvm_license_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_ha.id
  acl    = "private"
  key    = "license/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "panvm_software_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_ha.id
  acl    = "private"
  key    = "software/"
  source = "/dev/null"
}




resource "aws_s3_bucket_object" "cfg_upload" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap.id
  key    = "config/init-cfg.txt"
  source = "${path.cwd}/pan-bootstrap-cfg/init-cfg.txt"
  etag   = filemd5("${path.cwd}/pan-bootstrap-cfg/init-cfg.txt")
}

resource "aws_s3_bucket_object" "bootstrap_upload" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap.id
  key    = "config/bootstrap.xml"
  source = "${path.cwd}/pan-bootstrap-cfg/bootstrap.xml"
  etag   = filemd5("${path.cwd}/pan-bootstrap-cfg/bootstrap.xml")
}

resource "aws_s3_bucket_object" "bootstrap_upload_auth" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap.id
  key    = "license/authcodes"
  source = "${path.cwd}/pan-bootstrap-cfg/authcode"
  etag   = filemd5("${path.cwd}/pan-bootstrap-cfg/authcode")
}


resource "aws_s3_bucket_object" "cfg_upload_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_ha.id
  key    = "config/init-cfg.txt"
  source = "${path.cwd}/pan-bootstrap-cfg/init-cfg_ha.txt"
  etag   = filemd5("${path.cwd}/pan-bootstrap-cfg/init-cfg_ha.txt")
}

resource "aws_s3_bucket_object" "bootstrap_upload_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_ha.id
  key    = "config/bootstrap.xml"
  source = "${path.cwd}/pan-bootstrap-cfg/bootstrap.xml"
  etag   = filemd5("${path.cwd}/pan-bootstrap-cfg/bootstrap.xml")
}

resource "aws_s3_bucket_object" "bootstrap_upload_auth_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_ha.id
  key    = "license/authcodes"
  source = "${path.cwd}/pan-bootstrap-cfg/authcode"
  etag   = filemd5("${path.cwd}/pan-bootstrap-cfg/authcode")
}







output "bootstrap_bucket" {
  value = aws_s3_bucket_object.cfg_upload.bucket
}

output "bootstrap_bucket_ha" {
  value = aws_s3_bucket_object.cfg_upload_ha.bucket
}



