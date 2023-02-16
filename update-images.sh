#!/usr/bin/env sh
images=$(docker images --format='{{.Repository}}:{{.Tag}}' | grep "$1" | tee /dev/tty)

read -p "Are you sure you want to update all these images? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "$images" | xargs --max-lines=1 docker pull
else
    echo
    echo "Doing nothing so.."
fi

