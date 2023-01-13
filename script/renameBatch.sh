#!/bin/bash

originFiles='
abc (1).jpg*
abc (2).jpg*
abc (3).jpg*
'

targetFiles='
abc - (1).jpg*
abc - (2).jpg*
abc - (3).jpg*
'

echo "originFiles: ${originFiles}"
echo "targetFiles: ${targetFiles}"

array=(\
 /opt/github/Atlas/sourcecode/wispr-node-buildtools/sandbox/buildroot/git/master/docker/smgt/service/template/usr/local/site/tomcat/conf/logging.properties \
 /opt/github/Atlas/sourcecode/wispr-node-buildtools/sandbox/buildroot/git/master/docker/web/service/template/usr/local/site/tomcat/conf/logging.properties \
 /opt/github/Atlas/sourcecode/wispr-node-buildtools/sandbox/buildroot/git/master/docker/doad/service/template/usr/local/site/tomcat-doad/conf/logging.properties \
); for i in "${array[@]}"; do echo $i; done



