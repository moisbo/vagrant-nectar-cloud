#!/usr/bin/env bash

apt-get update
apt-get install -y unzip


# download the svm_light package and unpack
mkdir svmlight
cd svmlight
wget -q http://download.joachims.org/svm_light/current/svm_light_linux32.tar.gz
tar xzf svm_light_linux32.tar.gz
cd ..

# unpack the data files
unzip /vagrant/data-devtest.zip
unzip /vagrant/data-train.zip

