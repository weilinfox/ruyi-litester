#!/bin/bash

if yq --help |grep eval >/dev/null; then
	yq --no-colors eval $@
else
	yq --raw-output $@
fi
