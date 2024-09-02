#!/bin/sh
arch=$(dpkg --print-architecture)
codename=$(lsb_release --short --codename)
releases_version=1.3.1
apt update
apt install -y xrdp