#! /usr/bin/env bash
set -euxo pipefail

###
# do not run as root
###
if [[ $EUID -eq "0" ]]; then
   printf "please do not run this as root...\n" 
   exit 1
fi

###
# create languagetool folders
###
mkdir {fasttext,models,ngrams}

###
# clone fasttext from github
###
cd "fasttext"
git clone "https://github.com/facebookresearch/fastText.git"
cp -r "fastText"/* .
rm -rf "fastText"

###
# build fasttext
###
mkdir "build"
cd "build"
cmake ..
make

###
# download fasttext model
###
cd ../../"models"
curl -L "https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin" -O

###
# download english ngrams
###
cd ../"ngrams"
curl -L "https://languagetool.org/download/ngram-data/ngrams-en-20150817.zip" -o "ngrams.zip"
unzip "ngrams.zip"
rm -f "ngrams.zip"