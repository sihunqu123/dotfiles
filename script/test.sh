#!/bin/bash 

shopt -s expand_aliases
############!/usr/bin/env bash

#idifFileName="testuser"
#cat > ./${idifFileName}.idif <<HERE
#dn: cn=test user\${i},ou=people,dc=example,dc=com
#cn: test user\${i}
#objectClass: inetOrgPerson
#sn: user\${i}
#displayName: testuser\${i}
#mail: testuser\${i}@example.com
#userPassword: passw0rd
#HERE
#
#
#sed -i 's/${i}/2/g' ./testuser.idif


# for p in 

aaa=" a Pi "
bbb=" api "

echo "1 ${aaa:-} 2"
echo "3 ${aaa,,} 4"
echo "3 ${aaa^^} 4"

if [ "${bbb:-}" = "api-gateway" ] || [ "${bbb:-}" = "api" ]; then
  echo "if"
fi

if [ "${bbb:-}" = "api-gateway" ] || [ "${bbb:-}" = "null" ]; then
  echo "if"
fi
