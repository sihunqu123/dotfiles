#!/bin/bash

echo 'boy
boy is good
//SDFASDFA
girl
boy is good
//SDFASDFADSFA
gay
' | sed -E '
/^\s*\/\/[A-Z]+\s*$/!d
'
