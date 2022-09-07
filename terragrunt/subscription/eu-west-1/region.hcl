locals {
  location            = "West Europe"
  location_hyphenated = join("-", split(" ", lower(local.location)))
}
