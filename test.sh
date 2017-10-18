#!/bin/bash

# This script requires that nose be installed (the python test runner)
# Use pipenv or something similar to install it. Also, don't move this
# file. It assumes CWD is the proper path to the terraform state file.
export TF_STATE_PATH=$(pwd)
nosetests