#! /bin/bash

for deb in deb/*.deb; do
    dpkg -i $deb
done
