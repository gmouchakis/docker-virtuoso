#!/bin/bash

cd /data

mkdir -p dumps

if [ ! -f ./virtuoso.ini ];
then
  mv /virtuoso.ini . 2>/dev/null
fi

if [ ! -f "/.data_loaded" ];
then

    if [ "$DOWNLOAD_URL" ]; then
      echo "starting data downloading"
      mkdir -p toLoad
      cd toLoad
      wget $DOWNLOAD_URL
      tar xvf *.tar*
      cd ..
      echo "finished downloading"
    fi
    
    echo "starting data loading"
    pwd="dba"
    graph="http://localhost:8890/DAV"

    if [ "$DBA_PASSWORD" ]; then pwd="$DBA_PASSWORD" ; fi
    if [ "$DEFAULT_GRAPH" ]; then graph="$DEFAULT_GRAPH" ; fi
    echo "ld_dir_all('toLoad', '*', '$graph');" >> /load_data.sql
    echo "rdf_loader_run();" >> /load_data.sql
    echo "exec('checkpoint');" >> /load_data.sql
    echo "WAIT_FOR_CHILDREN; " >> /load_data.sql
    echo "$(cat /load_data.sql)"
    virtuoso-t +wait && isql-v -U dba -P "$pwd" exec="`cat /load_data.sql`"
    kill $(ps aux | grep '[v]irtuoso-t' | awk '{print $2}')
    touch /.data_loaded
    
    
    if [ "$DOWNLOAD_URL" ]; then
      rm -rf /data/toLoad/*
    fi
    
    echo "finished loading"
    
fi


virtuoso-t +wait +foreground

