locals {
  location            = "global"
  location_hyphenated = join("-", split(" ", lower(local.location)))
}
