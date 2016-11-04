#!/bin/bash

cd /data

mkdir -p dumps

if [ ! -f ./virtuoso.ini ];
then
  mv /virtuoso.ini . 2>/dev/null
fi

if [ ! -f "/data/.data_loaded" ];
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
        
    virtuoso-t +wait
    
    isql-v -U dba -P "$pwd" exec="ld_dir_all('toLoad', '*', '$graph');"
    
    cores=$(nproc --all)
    loaders=$(awk  'BEGIN { rounded = sprintf("%.0f", '$cores'/2.5); print rounded }')
    
   for ((n=1;n<=$loaders;n++)); do
      echo Starting RDF loader $n 
      isql-v -U dba -P "$pwd" exec="rdf_loader_run();" &
    done

    wait
    isql-v -U dba -P "$pwd" exec="checkpoint;"
    
    isql-v -U dba -P "$pwd" -K

    touch /data/.data_loaded
    
    
    if [ "$DOWNLOAD_URL" ]; then
      rm -rf /data/toLoad/*
    fi
    
    echo "finished loading"
    
fi


virtuoso-t +wait +foreground

