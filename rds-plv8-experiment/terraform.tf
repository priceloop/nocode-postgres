terraform {
  backend "s3" {
    bucket = "753006541874-terraform-state"
    key    = "flwi-rds-experiment/state.tfstate"
    region = "eu-central-1"

  }
}
