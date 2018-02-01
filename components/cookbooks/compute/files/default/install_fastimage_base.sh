#!/usr/bin/env bash

# Setup path
if [ -e /home/oneops/ruby/2.0.0-p648/bin ]; then
    echo "export PATH=/home/oneops/ruby/2.0.0-p648/bin:$PATH" >> /home/oneops/.bash_profile
    echo "export GEM_HOME=/home/oneops/ruby/2.0.0-p648/lib/ruby/gems/2.0.0" >> /home/oneops/.bash_profile
    echo "export GEM_PATH=/home/oneops/ruby/2.0.0-p648/lib/ruby/gems/2.0.0" >> /home/oneops/.bash_profile
fi

# Setup ssh
sed -e 's/.* ssh-rsa/ssh-rsa/' .ssh/authorized_keys > .ssh/authorized_keys_
chown root:root .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
mv .ssh/authorized_keys_ .ssh/authorized_keys
cp -r ~/.ssh /home/oneops/.ssh
cp ~/.ssh/authorized_keys /home/oneops/.ssh/authorized_keys

# rsync cookbooks
rsync -a /root/circuit-oneops-1 /home/oneops/
rsync -a /root/shared /home/oneops/
chown -R oneops:oneops /home/oneops/circuit-oneops-1 /home/oneops/shared /home/oneops/.ssh /opt/oneops/workorder /opt/oneops/rubygems_proxy
