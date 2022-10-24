#!/bin/bash

DATAINICIO=`date '+%d/%m/%Y %H:%M:%S'`

S3URI="s3://$BUCKET/$KEY"
IFS='.'
read -a strarr <<< "$KEY"
NOMEDIR="${strarr[0]}"

# Download the zip file from S3, note the use of the S3 URI, not HTTPS
message=$(aws s3 cp "$S3URI" temp.zip 2>&1)
if [ $? != 0 ]; then
    python logger.py erro $message
    exit 1
fi
# Decompress the zip file into a temp directory
message=$(unzip -d temp_zip_contents temp.zip 2>&1)
if [ $? != 0 ]; then
    python logger.py erro $message
    exit 1
fi
# Sync up the contents of the temp directory to S3 prefix
message=$(aws s3 sync temp_zip_contents "s3://$BUCKET/$NOMEDIR" 2>&1)
if [ $? != 0 ]; then
    python logger.py erro $message
    exit 1
fi

message=$(rm -rf temp.zip temp_zip_contents 2>&1)
if [ $? != 0 ]; then
    python logger.py erro $message
    exit 1
fi

DATAFIM=`date '+%d/%m/%Y %H:%M:%S'`

message= "{
    \"mensagem\": \"$KEY: extração ocorrido com sucesso!\",
    \"incio\": $DATAINICIO,
    \"fim\": $DATAFIM
}"

python logger.py info $message
