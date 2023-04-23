#!/usr/local/bin/bash
#force move files
(cd dist && tar c .) | (cd website && tar xf -)