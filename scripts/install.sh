#!/bin/bash
I=`dpkg -s jekyll | grep "Status" `
if [ -n "$I" ]
then
        echo "installed"
else
	echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
	echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
	echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
	source ~/.bashrc
	gem install jekyll bundler
fi
