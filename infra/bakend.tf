terraform {

  backend "s3" {
    bucket       = "terraform-state-753690273280-eu-west-2"
    key          = "tenant/sandbox-1/eu-west-2"
    region       = "eu-west-2"
    encrypt      = true
    kms_key_id   = "arn:aws:kms:eu-west-2:753690273280:key/bcaf6746-9d9d-49a5-812c-06a4d2bd7095"
    use_lockfile = true
  }
}
