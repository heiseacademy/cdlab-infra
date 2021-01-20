#!/bin/bash

docker run --name jenkins --rm -p 8080:8080 jenkins:2.275-jcasc --httpPort=8080
