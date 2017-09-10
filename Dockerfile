FROM ubuntu:14.04

USER root
RUN useradd -ms /bin/bash ranga
ADD /sudoers.txt /etc/sudoers
RUN chmod 440 /etc/sudoers


USER ranga
WORKDIR /home/ranga

COPY id_rsa .ssh/id_rsa
COPY id_rsa.pub .ssh/id_rsa.pub

RUN sudo apt-get update
RUN sudo apt-get install -y curl
RUN sudo apt-get install -y make gcc libxslt-dev libxml2-dev ca-certificates wget git-core ssh 
RUN sudo apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev
RUN sudo apt-get install -y autoconf -y bison build-essential libreadline6-dev libncurses5-dev libgmp3-dev
RUN sudo apt-get clean



RUN sudo /bin/bash -l -c 'echo "IdentityFile $HOME/.ssh/id_rsa" >> /etc/ssh/ssh_config'
RUN sudo /bin/bash -l -c 'echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config'


RUN sudo /bin/bash -l -c 'chmod 600 $HOME/.ssh/id_rsa*'
RUN sudo /bin/bash -l -c 'chown -R ranga:ranga $HOME/.ssh'

WORKDIR /home/ranga/

RUN sudo apt-get update
RUN sudo apt-get install -y npm
RUN sudo apt-get install -y nodejs
RUN sudo ln -s /usr/bin/nodejs /usr/bin/node

RUN git init
RUN git config --global user.email "gkranganath2000@gmail.com"
RUN git config --global user.name "gkranga"
RUN git remote add origin git@github.com:gkranga/sampleapp.git
RUN git remote set-url origin git@github.com:gkranga/sampleapp.git
RUN git clone git@github.com:gkranga/sampleapp.git


WORKDIR /home/ranga/sampleapp
RUN npm install


RUN sudo npm install nodemailer-mailgun-transport
RUN sudo npm install ldapjs

RUN sudo apt-get install -y nginx

RUN sudo touch /etc/nginx/sites-available/default
COPY default /etc/nginx/sites-available/default
RUN sudo npm install -g forever

RUN sudo chown -R ranga:ranga /var/lib/nginx 
RUN sudo chown -R ranga:ranga /etc/nginx/
RUN sudo touch /var/log/nginx/error.log
RUN sudo touch /var/log/nginx/access.log

RUN sudo nginx -t
RUN sudo service nginx configtest
RUN sudo service nginx restart

EXPOSE 80
CMD sudo forever start index.js &&  sudo nginx -g 'daemon off;'
RUN echo "test"
