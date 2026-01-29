resource "aws_key_pair" "upgrad_key" {
  key_name   = "upgrad-key"
  public_key = file("upgrad-key.pub")
}
