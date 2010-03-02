#!/bin/sh

pbpaste | openssl base64 -d | dump-nsarchive

