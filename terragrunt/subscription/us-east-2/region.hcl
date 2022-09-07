locals {
  location            = "East US 2"
  location_hyphenated = join("-", split(" ", lower(local.location)))
}
