#!/bin/bash

#MONGODPID=$(pgrep mongod)
#echo $MONGOPID
#if [[ -z $MONGOPID ]]; then
  #echo "NUMBER"
  #echo $MONGOPID
#else
  #echo "NOT"
#fi

pidfile=/Volumes/traktorram/mongod.lock
if [[ -e $pidfile ]]; then
  pid=`cat $pidfile`
  if [[ -n $pid ]]; then
    kill -15 $pid
  fi
fi
