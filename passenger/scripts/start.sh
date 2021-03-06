#!/bin/bash

##
# Copy files into specific directories.
##

##
# Apache.
##

if [ -f '/etc/conf/apache/apache2.conf' ]; then
  cp /etc/conf/apache/apache2.conf /etc/apache2/apache2.conf
fi

if [ -f '/etc/conf/apache/vhost.conf' ]; then
  rm -f /etc/apache2/sites-enabled/*
  cp /etc/conf/apache/vhost.conf /etc/apache2/sites-available/passenger
  a2ensite passenger
fi

##
# Mysql.
##

if [ -f '/etc/conf/mysql/my.cnf' ]; then
  cp /etc/conf/mysql/my.cnf /etc/mysql/my.cnf
fi
chown -R mysql:mysql /var/lib/mysql

##
# SSHD.
##

# Global ssh config.
if [ -d '/etc/conf/sshd' ]; then
  rsync -avz /etc/conf/sshd/* /etc/ssh/
fi

# Root user.
if [ -f '/etc/conf/sshd/root_authorized_keys' ]; then
  mkdir -p /root/.ssh
  cp /etc/conf/sshd/root_authorized_keys /root/.ssh/authorized_keys
  chmod 400 /root/.ssh/authorized_keys
  chown root:root -R /root/.ssh
fi

# Deployer user.
if [ -f '/etc/conf/sshd/deployer_authorized_keys' ]; then
  mkdir -p /home/deployer/.ssh
  cp /etc/conf/sshd/deployer_authorized_keys /home/deployer/.ssh/authorized_keys
  chmod 400 /home/deployer/.ssh/authorized_keys
  chown deployer:deployer -R /home/deployer/.ssh
fi

##
# Permissions.
##

chown -R deployer:www-data /var/www

##
# Rsyslog.
##

if [ -f '/etc/conf/rsyslog/rsyslog.conf' ]; then
  cp /etc/conf/rsyslog/rsyslog.conf /etc/rsyslog.conf
fi

##
# Nullmailer.
##

if [ ! -z "${NULLMAILER_REMOTE}" ]; then
  echo ${NULLMAILER_REMOTE} > /etc/nullmailer/remotes
fi
mkfifo /var/spool/nullmailer/trigger
chmod 0622 /var/spool/nullmailer/trigger
chown mail:root /var/spool/nullmailer/trigger

##
# Supervisord.
##

supervisord -n -c /etc/supervisord.conf
