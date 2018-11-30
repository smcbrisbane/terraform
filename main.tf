# This is just a simple example of an EC2 being created with a role and a bucket
#
##############################################################################################
# EC2
##############################################################################################
resource  "aws_instance" "sf-infra-test-us-east-1-ec2-pcat" {
  ami = "ami-0d207cc73b6a5a3e1"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.sf-pcat-ec2-role-instance-profile.name}"
  availability_zone = "us-east-1a"
  vpc_security_group_ids = ["sg-05bea0402f1be20f9"]
  subnet_id = "subnet-10a5d93f"
  associate_public_ip_address = false
  key_name = "sf-infra-test-us-east-1-ddm2"
  instance_initiated_shutdown_behavior = "stop"
  depends_on = ["aws_iam_instance_profile.sf-pcat-ec2-role-instance-profile"]

  tags {
    Name = "I copied from PCAT"
    off-hours-shutdown = "enabled"
    creator = "pcat"
    ou = "test"
    contact = "WG10272"
    terraform_managed = "yes"
  }

  count = 1
}

##############################################################################################
# Role and Policy
##############################################################################################

resource "aws_iam_instance_profile" "sf-pcat-ec2-role-instance-profile" {
  name = "sf-pcat-ec2-role-instance-profile"
  role = "${aws_iam_role.sf-pcat-ec2-role.name}"
}


resource "aws_iam_role" "sf-pcat-ec2-role" {
  name = "sf-pcat-ec2-role"
  assume_role_policy = "${data.aws_iam_policy_document.switchrole-trust-relationship.json}"

}

data "aws_iam_policy_document" "switchrole-trust-relationship" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_role_policy_attachment" "sf-pcat-ec2-role-ec2fullaccess-attachment" {

    role = "${aws_iam_role.sf-pcat-ec2-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    depends_on = ["aws_iam_role.sf-pcat-ec2-role"]
}

resource "aws_iam_role_policy_attachment" "sf-pcat-ec2-role-s3fullaccess-attachment" {

    role = "${aws_iam_role.sf-pcat-ec2-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    depends_on = ["aws_iam_role.sf-pcat-ec2-role"]
}

resource "aws_iam_role_policy_attachment" "sf-pcat-ec2-role-admin-denynetworkactions-attachment" {

    role = "${aws_iam_role.sf-pcat-ec2-role.name}"
    policy_arn = "arn:aws:iam::761602949203:policy/sfDenyNetworkActions"
    depends_on = ["aws_iam_role.sf-pcat-ec2-role"]
}

resource "aws_iam_role_policy_attachment" "sf-pcat-ec2-role-apigateway-attachment" {

    role = "${aws_iam_role.sf-pcat-ec2-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
    depends_on = ["aws_iam_role.sf-pcat-ec2-role"]
}

resource "aws_iam_role_policy_attachment" "sf-pcat-ec2-role-elasticbean-attachment" {

    role = "${aws_iam_role.sf-pcat-ec2-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess"
    depends_on = ["aws_iam_role.sf-pcat-ec2-role"]
}

##############################################################################################
# S3 and Policy
##############################################################################################

resource "aws_s3_bucket" "emberjs-bucket" {
  bucket = "sf-pcat-ember-application-us-east-1"
  acl      = "private"
  region = "us-east-1"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "arn:aws:kms:us-east-1:761602949203:key/87a09846-3e04-4905-b24d-1447f5fac97d"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags {
    creator = "pcat"
    ou = "test"
    contact = "WG10272"
    terraform_managed = "yes"
  }
}

resource "aws_s3_bucket_policy" "s3-bucket-policy-emberjs" {
  bucket = "${aws_s3_bucket.emberjs-bucket.id}"
  policy =<<POLICY
{
    "Version": "2012-10-17",
    "Id": "DDM2-bucket-policy",
    "Statement": [
        {
            "Sid": "Stmt1535642059886",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::970752313810:user/sf-pcat-terraform-ci-cd",
                    "arn:aws:iam::970752313810:role/OrganizationAccountAccessRole",
                    "${aws_iam_role.sf-pcat-ec2-role.arn}"
                ]
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::sf-pcat-ember-application-us-east-1",
                "arn:aws:s3:::sf-pcat-ember-application-us-east-1/*"
            ]
        }
    ]
}
POLICY
depends_on = ["aws_iam_role.sf-pcat-ec2-role"]
}
