data "aws_subnets" "example" {

}


data "aws_security_groups" "sg_instance" {

}
resource "aws_db_subnet_group" "blahblah1" {
  depends_on = [data.aws_subnets.example]
  subnet_ids = data.aws_subnets.example.ids
  name       = "hoho"
}

resource "aws_db_instance" "mydb" {
  identifier             = "mydb1"
  db_name                = "db1"
  allocated_storage      = "10"
  db_subnet_group_name   = aws_db_subnet_group.blahblah1.name
  username               = "admin"
  password               = "kashish123"
  publicly_accessible    = false
  instance_class         = "db.t3.micro"
  engine                 = "mysql"
  engine_version         = "8.0"
  skip_final_snapshot    = true
  vpc_security_group_ids = data.aws_security_groups.sg_instance.ids
  #depends_on             = [data.aws_security_groups.sg_instance, data.aws_subnets.example]
}




resource "aws_instance" "my_instance" {
  subnet_id     = "subnet-0f4b0cc15a28a8771"
  ami           = "ami-0453ec754f44f9a4a"
  instance_type = "t2.micro"
}

resource "null_resource" "block" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("keypair2.pem")
    host        = aws_instance.my_instance.public_ip
  }
  provisioner "file" {
    source      = "./initialize_db.sql"
    destination = "/home/ec2-user/file.sql"

  }
}
resource "null_resource" "pre" {
  connection {

    type        = "ssh"
    user        = "ec2-user"
    private_key = file("keypair2.pem")
    host        = aws_instance.my_instance.public_ip
  }
  provisioner "file" {
    source      = "./mysql.repo"
    destination = "/etc/yum.repos.d/mysql.repo"

  }
}

resource "null_resource" "post" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("keypair2.pem")
    host        = aws_instance.my_instance.public_ip
  }
  provisioner "remote-exec" {
    inline = ["mysql --version",
    "mysql -h ${aws_db_instance.mydb.address} -u admin -pkashish123 -e 'source /home/ec2-user/file.sql'"]
  }
}
#"sudo su",
# "systemctl start mysqld",
