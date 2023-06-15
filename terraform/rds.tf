resource "aws_db_subnet_group" "test-db-subnet-group" {
  name       = "test-db-subnet-group"
  subnet_ids = ["${aws_subnet.myonaiyoko_private-db_1a_sn.id}", "${aws_subnet.myonaiyoko_private-db_1c_sn.id}"]

  tags = {
    Name = "My database subnet group"
  }
}

resource "aws_db_instance" "test-db" {
  identifier           = "test-db"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  name                 = "testdb"
  username             = "user1"
  password             = "Password"
  vpc_security_group_ids  = [aws_security_group.myonaiyoko_rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.test-db-subnet-group.name
  skip_final_snapshot = true
}
