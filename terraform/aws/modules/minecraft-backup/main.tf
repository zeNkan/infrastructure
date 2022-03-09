# MINECRAFT SETUP
resource "aws_s3_bucket" "mc_backup" {
  bucket = "lanbros-mc-backup"
  acl    = "private"

  lifecycle_rule {
    id      = "mc_backup_expiration"
    enabled = true

    expiration {
      days = "7"
    }
  }
}

resource "aws_iam_user" "mc_backup" {
  name = "mc-backup"
}

data "aws_iam_policy_document" "mc_backup_policy_doc" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.mc_backup.arn}/*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.mc_backup.arn
    ]
  }
}

resource "aws_iam_user_policy" "mc_backup_policy" {
  name   = "mc_backup_policy"
  user   = aws_iam_user.mc_backup.name
  policy = data.aws_iam_policy_document.mc_backup_policy_doc.json
}
