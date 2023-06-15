# 作成したEC2のパブリックIPアドレスを出力
output "ec2_ansible_global_ips" {
  value = "${aws_instance.myonaiyoko_ansible_node.*.public_ip}"
}
output "ec2_web_global_ips" {
  value = "${aws_instance.myonaiyoko_ec2.*.public_ip}"
  description = "Public IPs of the web server instances"
}