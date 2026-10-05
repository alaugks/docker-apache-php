variable "TAG" {
  default = "local"
}

variable "IMAGE" {
  default = "alaugks/apache-php"
}

group "default" {
  targets = ["production", "xdebug"]
}

target "_common" {
  context    = "."
  dockerfile = "Dockerfile"
  platforms  = ["linux/amd64", "linux/arm64"]
}

target "production" {
  inherits   = ["_common"]
  target     = "production"
  tags       = ["${IMAGE}:${TAG}"]
  cache-from = ["type=gha,scope=production"]
  cache-to   = ["type=gha,mode=max,scope=production"]
}

target "xdebug" {
  inherits   = ["_common"]
  target     = "xdebug"
  tags       = ["${IMAGE}:${TAG}-xdebug"]
  cache-from = ["type=gha,scope=xdebug", "type=gha,scope=production"]
  cache-to   = ["type=gha,mode=max,scope=xdebug"]
}
