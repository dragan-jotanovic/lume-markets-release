app {
  url = "https://github.com/luceracloud/lume-release"
}

pack {
  name        = "lume_release"
  description = "Lume markets Platform Release Package"
  version     = "v4.0.0"
}

dependency "core_backend" {
  alias  = "core_backend"
  source = "git::https://github.com/dragan-jotanovic/core-backend.git//packs/core_backend?ref=v0.1.10&depth=1"
}

dependency "venue_adapters" {
  alias  = "venue_adapters"
  source = "git::https://github.com/dragan-jotanovic/venue-adapters.git//packs/venue_adapters?ref=v0.1.4&depth=1"
}
