#!/bin/sh

PROJECT_ID="$1"

gcloud projects list

rm -rf ${HOME}/$PROJECT_ID
#echo -n "Y" | gcloud projects delete $PROJECT_ID
gcloud projects delete $PROJECT_ID
gcloud projects list
