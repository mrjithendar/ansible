resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.azs.names
  result_count = length(data.aws_availability_zones.azs.names)
}
