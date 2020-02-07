#!/bin/sh

# 1/ Update pom.xml with version number
# 2/ Include passphrase in $HOME/.m2/settings.xml
#    <profile>
#      <id>release</id>
#      <properties>
#        <gpg.passphrase>INSERT VALUE HERE</gpg.passphrase>
#      </properties>
#    </profile>
# 3/ When script is executed, go to https://oss.sonatype.org/#stagingRepositories, then close and release the staging repository
# 4/ It then takes a few minutes before artifacts are visible in Maven Central

mvn gpg:sign-and-deploy-file -Durl=https://oss.sonatype.org/service/local/staging/deploy/maven2 -DrepositoryId=ossrh -DpomFile=pom.xml -Dfile=dist/PCT.jar -Pgpg
mvn gpg:sign-and-deploy-file -Durl=https://oss.sonatype.org/service/local/staging/deploy/maven2 -DrepositoryId=ossrh -DpomFile=pom.xml -Dfile=dist/PCT-sources.jar -Dclassifier=sources -Pgpg
mvn gpg:sign-and-deploy-file -Durl=https://oss.sonatype.org/service/local/staging/deploy/maven2 -DrepositoryId=ossrh -DpomFile=pom.xml -Dfile=dist/PCT-javadoc.jar -Dclassifier=javadoc -Pgpg
