#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 shepherd"
  echo "where shepherd is the path to shepherd in the GUIX store as"
  echo "given by \`shepherd' from (use-modules (gnu packages admin))"
  exit 1
fi

echo
{ read len_script; read len_tar; } < /dev/sdb
pwd
head -c "$len_tar" /dev/sdd | tar -xf -

# Checking that hello is not available yet:
$(guix build hello)/bin/hello && echo "Expected hello to be missing at this point" && exit 1

# Import hello.nar
guix archive --authorize < signing-key.pub
guix archive --import < hello.nar

# This works:
$(guix build hello)/bin/hello

# This fails
guix build --check hello

# Wait for the control socket for shepherd to appear and halt the VM.
(
  while [ ! -e /var/run/shepherd/socket ]; do
    sleep 1
  done
  "$1/sbin/halt"
) &
