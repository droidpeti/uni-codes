#!/bin/bash

date | tee run.log
echo "second line" | tee -a run.log
