#!/usr/bin/env bash

#Replace .profile with .bashrc if required

source ~/.bashrc
if [ -z "$GITHUB_TOKEN" ]; then
    echo "export GITHUB_TOKEN=80794ecaf8be58e0bb627b27be5b3607cb62b8f1" >> ~/.bashrc
fi

if [ -z "$TUI_GITHUB_API_TOKEN" ]; then
    echo "export TUI_GITHUB_API_TOKEN=80794ecaf8be58e0bb627b27be5b3607cb62b8f1" >> ~/.bashrc
fi

# grunt build aliases
echo "alias gcam='cd /var/www/tuicamper/Source/assets && grunt default'" >> ~/.bashrc
echo "alias gcamsm='cd /var/www/tuicamper/Source/assets && grunt search_mask'" >> ~/.bashrc
echo "alias gcamt='cd /var/www/tuicamper/Source/camper/public/typo3conf && grunt'" >> ~/.bashrc

# grunt deploy aliases
echo "alias dcam='cd /var/www/tuicamper/Deployment && grunt --target=tuicampertest'" >> ~/.bashrc
