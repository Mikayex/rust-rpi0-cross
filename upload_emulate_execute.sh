#!/bin/bash
set -e

if [ -n "$CROSS_REMOTE_HOST" ]; then
  source /nss-wrap.sh
  REMOTE=$CROSS_REMOTE_HOST
  REMOTE_DIR=/tmp/cross-execute

  echo "=> Executing remotely"
  ssh $REMOTE mkdir -p $REMOTE_DIR
  rsync -rtvucE --del --exclude=".*" --exclude=target $CARGO_MANIFEST_DIR/ $1 $REMOTE:$REMOTE_DIR
  ssh $REMOTE "cd $REMOTE_DIR && ./$(basename $1)"
else
  echo "=> Executing locally"
  qemu-arm $1
fi
