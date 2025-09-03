variable "vpc_id" {

}
variable "alb_subnet_ids" {
  type = list(string)
}
variable "app_subnet_ids" {
  type = list(string)
}
variable "alb_sg_id" {

}
variable "app_sg_id" {

}
variable "desired_capacity" {
  type = number
}
variable "min_size" {
  type = number
}
variable "max_size" {
  type = number
}
variable "instance_type" {
  type = string
}
variable "keypair_name" {
  type    = string
  default = null
}
