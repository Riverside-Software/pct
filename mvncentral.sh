#!/bin/sh

# 1/ Update pom.xml with version number
# 2/ Include passphrase in $HOME/.m2/settings.xml
#    <profile>
#      <id>release</id>
#      <properties>
#        <gpg.passphrase>INSERT VALUE HERE</gpg.passphrase>
#      </properties>
#    </profile>

mvn org.apache.maven.plugins:maven-gpg-plugin:1.3:sign-and-deploy-file -Durl=https://oss.sonatype.org/service/local/staging/deploy/maven2 -DrepositoryId=ossrh -DpomFile=pom.xml -Dfile=dist/PCT.jar -Pgpg
mvn org.apache.maven.plugins:maven-gpg-plugin:1.3:sign-and-deploy-file -Durl=https://oss.sonatype.org/service/local/staging/deploy/maven2 -DrepositoryId=ossrh -DpomFile=pom.xml -Dfile=dist/PCT-sources.jar -Dclassifier=sources -Pgpg
mvn org.apache.maven.plugins:maven-gpg-plugin:1.3:sign-and-deploy-file -Durl=https://oss.sonatype.org/service/local/staging/deploy/maven2 -DrepositoryId=ossrh -DpomFile=pom.xml -Dfile=dist/PCT-javadoc.jar -Dclassifier=javadoc -Pgpg
