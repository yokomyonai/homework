■ansibleサーバーへmysqlクライアントのインストール  
yum list installed | grep mariadb  
sudo yum remove mariadb-libs  
sudo yum localinstall https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm  
sudo yum-config-manager --enable mysql80-communityCopy  
sudo yum-config-manager --disable mysql57-communityCopy  
sudo yum install mysql-community-client  
  
■ansibleの設定  
sudo amazon-linux-extras install ansible2 -y  
WinSCPで秘密鍵を/home/ec2-user/.ssh/へコピーする  
midir /home/ec2-user/MyAnsible  
midir /home/ec2-user/MyAnsible/resouces  
WinSCPでMySpringBootSample-0.0.1-SNAPSHOT.jarを/home/ec2-user/MyAnsible/resourcesへコピーする  
sudo vi /etc/ansible/hosts  
※ hostsファイルを参照  
cp -p /etc/ansible/hosts /home/ec2-user/MyAnsible/hosts  
sudo vi /home/ec2-user/MyAnsible/playbook.yaml  
※ playbook.yamlファイルを参照  
ansible-playbook -i hosts playbook.yamlを実行  
