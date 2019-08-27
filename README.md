# Tweety
The dummy app
* Pull repository from github
* Unit Test 
* Done.....


## Jenkins

### Install (AWS Linux-AMI)

#### Install java 8

```
{
  sudo yum update -y
  sudo yum remove java-1.7.0
  sudo yum install java-1.8.0
}	
```

#### Install nvm & node
```
{
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
  . ~/.nvm/nvm.sh
  nvm install 9
}
```

#### Install Docker
```
{
  sudo yum update -y
  sudo amazon-linux-extras install docker
  sudo yum install docker
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  docker info
}
```

#### Install Jenkins
```
{
  sudo yum update -y
  sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins.io/redhat/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
  sudo yum install jenkins -y
  sudo usermod -a -G docker jenkins
  sudo service jenkins start
}
```

#### Hack login e.g (Optional)
```
[root@ip-xxxx ~]# cat /var/lib/jenkins/secrets/initialAdminPassword
72c9d76e61724a80bfca4db32e3adacc
change to 
[root@ip-xxxx ~]# cat /var/lib/jenkins/secrets/initialAdminPassword
passwd:72c9d76e61724a80bfca4db32e3adacc
```

#### uninstall jenkins
```
{
  sudo service jenkins stop
  sudo yum clean all
  sudo yum -y remove jenkins
  sudo rm -rf /var/cache/jenkins
  sudo rm -rf /var/lib/jenkins/
}
```

### Jenkins -> Configure Pipeline
#### Build Triggers
* GitHub hook trigger for GITScm polling (Check this option)

#### Pipeline
* Defination --> Pipeline script from SCM (Select from dropdown)
* SCM -> GIT (Select)
* Repositories -> Enter Repository URL. Add Github Credentials.
* Branch to build (*/master or */release etc.)
* Script Path -> Enter `Jenkinsfile`

#### Plugins to install
* Pipeline: AWS Steps
* NodeJS Plugin

#### Credentials
* github
* aws
