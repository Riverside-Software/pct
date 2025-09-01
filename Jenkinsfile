// Syntax check with this command line
// curl -k -X POST -F "jenkinsfile=<Jenkinsfile" https://ci.rssw.eu/pipeline-model-converter/validate

pipeline {
  agent none
  options {
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timeout(time: 45, unit: 'MINUTES')
    skipDefaultCheckout()
  }

  stages {
    stage('🏗️ Class documentation build') {
      agent { label 'Windows-Office' }
      steps {
        checkout([$class: 'GitSCM', branches: scm.branches, extensions: scm.extensions + [[$class: 'CleanCheckout']], userRemoteConfigs: scm.userRemoteConfigs])
        script {
          def antHome = tool name: 'Ant 1.9', type: 'ant'
          def dlc11 = tool name: 'OpenEdge-11.7', type: 'openedge'
          def dlc12 = tool name: 'OpenEdge-12.8', type: 'openedge'
          def jdk = tool name: 'Corretto 11', type: 'jdk'
          def version = readFile('version.txt').trim()

          withEnv(["JAVA_HOME=${jdk}"]) {
            bat "${antHome}\\bin\\ant -Dpct.release=${version} -DDLC11=${dlc11} -DDLC12=${dlc12} classDoc"
          }
        }
        stash name: 'classdoc', includes: 'dist/classDoc.zip'
      }
    }

    stage('🏗️ Standard build') {
      agent { label 'Linux-Office03' }
      steps {
        script {
          checkout([$class: 'GitSCM', branches: scm.branches, extensions: scm.extensions + [[$class: 'CleanCheckout']], userRemoteConfigs: scm.userRemoteConfigs])
          // Ugly workaround: sonar-scanner requires the main branch to be present, but Jenkins only fetches the current branch
          // An extra checkout is then done with a different refspec.
          // There's probably a better way to do that, but no time for that (today)
          checkout([$class: 'GitSCM', branches: scm.branches, extensions: scm.extensions + [[$class: 'CleanCheckout']], userRemoteConfigs: [[credentialsId: scm.userRemoteConfigs.credentialsId[0], url: scm.userRemoteConfigs.url[0], refspec: '+refs/heads/main:refs/remotes/origin/main']] ])

          unstash name: 'classdoc'
          sh 'git rev-parse --short HEAD > head-rev'
          def commit = readFile('head-rev').trim()
          def version = readFile('version.txt').trim()

          docker.image('docker.rssw.eu/progress/dlc:11.7').inside('') {
            sh "ant -DDLC11=/opt/progress/dlc -DDLC12=/ pbuild"
          }
          docker.image('docker.rssw.eu/progress/dlc:12.8').inside('') {
            sh "ant -Dpct.release=${version} -DDLC11=/ -DDLC12=/opt/progress/dlc -DGIT_COMMIT=${commit} dist"
          }
        }
        stash name: 'unsigned', includes: 'dist/PCT.jar,eToken.cfg'
      }
    }

    stage('🔏 Package signature') {
      agent { label 'Windows-Office02' }
      environment {
        KEYSTORE_ALIAS = credentials('KEYSTORE_ALIAS')
        KEYSTORE_PASS = credentials('KEYSTORE_PASS')
      }
      steps {
        unstash name: 'unsigned'
        script {
          withEnv(["PATH+JAVA=${tool name: 'JDK17', type: 'jdk'}\\bin"]) {
            bat "jarsigner -tsa http://timestamp.sectigo.com -keystore NONE -storepass %KEYSTORE_PASS% -storetype PKCS11 -providerClass sun.security.pkcs11.SunPKCS11 -providerArg .\\eToken.cfg -signedjar dist\\PCT-signed.jar dist\\PCT.jar %KEYSTORE_ALIAS%"
          }
        }
        stash name: 'signed', includes: 'dist/PCT-signed.jar'
      }
    }

    stage('📦 Archive') {
      agent { label 'Linux-Office03' }
      steps {
        unstash name: 'signed'
        stash name: 'tests', includes: 'dist/PCT.jar,dist/PCT-signed.jar,dist/testcases.zip,tests.xml'
        archiveArtifacts 'dist/PCT.jar,dist/PCT-signed.jar,dist/PCT-javadoc.jar,dist/PCT-sources.jar'
      }
    }

    stage('🧪 Unit tests') {
      steps {
        parallel branch1: { testBranch('Windows-Office', 'JDK8', 'Ant 1.10', 'OpenEdge-11.7', true, '11.7-Win', '') },
                 branch2: { testBranch('Windows-Office', 'Corretto 11', 'Ant 1.10', 'OpenEdge-12.2', true, '12.2-Win', '') },
                 branch3: { testBranch('Windows-Office02', 'JDK17', 'Ant 1.10', 'OpenEdge-12.8', true, '12.8-Win', '') },
                 branch4: { testBranch('Linux-Office03', 'JDK8', 'Ant 1.10', 'OpenEdge-11.7', false, '11.7-Linux', 'docker.rssw.eu/progress/dlc:11.7') },
                 branch5: { testBranch('Linux-Office03', 'Corretto 11', 'Ant 1.10', 'OpenEdge-12.2', false, '12.2-Linux', 'docker.rssw.eu/progress/dlc:12.2') },
                 branch6: { testBranch('Linux-Office03', 'Corretto 11', 'Ant 1.10', 'OpenEdge-12.8', true, '12.8-Linux', 'docker.rssw.eu/progress/dlc:12.8') },
                 failFast: false
      }
    }

    stage('🗃️ Unit tests reports') {
      agent { label 'Linux-Office03' }
      steps {
        // Wildcards not accepted in unstash...
        unstash name: 'junit-11.7-Win'
        unstash name: 'junit-12.2-Win'
        unstash name: 'junit-12.8-Win'
        unstash name: 'junit-11.7-Linux'
        unstash name: 'junit-12.2-Linux'
        unstash name: 'junit-12.8-Linux'

        sh "mkdir junitreports"
        unzip zipFile: 'junitreports-11.7-Win.zip', dir: 'junitreports', quiet: true
        unzip zipFile: 'junitreports-12.2-Win.zip', dir: 'junitreports', quiet: true
        unzip zipFile: 'junitreports-12.8-Win.zip', dir: 'junitreports', quiet: true
        unzip zipFile: 'junitreports-11.7-Linux.zip', dir: 'junitreports', quiet: true
        unzip zipFile: 'junitreports-12.2-Linux.zip', dir: 'junitreports', quiet: true
        unzip zipFile: 'junitreports-12.8-Linux.zip', dir: 'junitreports', quiet: true
        junit 'junitreports/**/*.xml'
      }
    }

    stage('🔍️ Sonar') {
      agent { label 'Linux-Office03' }
      steps {
        unstash name: 'coverage-11.7-Win'
        unstash name: 'coverage-12.2-Win'
        unstash name: 'coverage-12.8-Win'
        unstash name: 'coverage-12.8-Linux'
        script {
          def version = readFile('version.txt').trim()
          docker.image('docker.rssw.eu/progress/dlc:12.8').inside('') {
            sh 'ant -lib lib/jacocoant-0.8.7.jar -file sonar.xml -DDLC=/opt/progress/dlc init-sonar' 
          }
          docker.image('sonarsource/sonar-scanner-cli:latest').inside('') {
            withSonarQubeEnv('RSSW') {
              withEnv(["SONAR_USER_HOME=/tmp"]) {
                sh "sonar-scanner -Dsonar.projectVersion=${version}"
              }
            }
          }
        }
      }
    }

    stage('📦 Maven Central') {
      environment {
        MAVEN_GPG_PASSPHRASE=credentials('GPG_KEY')
        BEARER_TOKEN=credentials('MavenCentralBearer')
      }
      agent { label 'Linux-Office03' }
      steps {
        script {
          def jdk = tool name: 'JDK17', type: 'jdk'
          def mvn = tool name: 'Maven 3', type: 'maven'
          def ant = tool name: 'Ant 1.10', type: 'ant'
          def version = readFile('version.txt').trim()

          withEnv(["MAVEN_HOME=${mvn}", "JAVA_HOME=${jdk}"]) {
            if (!version.endsWith('-pre')) {
              // Manually create and upload bundle to Maven Central. It's probably possible to do that with the maven-publish plugin, but as build is done with Ant, it's easier to do it manually.
              // https://central.sonatype.org/publish/publish-portal-api/
              // https://central.sonatype.org/publish/publish-portal-upload/
              sh "mkdir bundle && cp alt-pom.xml bundle/pct-${version}.pom && cp dist/PCT.jar bundle/pct-${version}.jar && cp dist/PCT-sources.jar bundle/pct-${version}-sources.jar && cp dist/PCT-javadoc.jar bundle/pct-${version}-javadoc.jar"
              sh "gpg --pinentry-mode loopback --passphrase \${MAVEN_GPG_PASSPHRASE} --armor --output bundle/pct-${version}.jar.asc --detach-sign bundle/pct-${version}.jar"
              sh "gpg --pinentry-mode loopback --passphrase \${MAVEN_GPG_PASSPHRASE} --armor --output bundle/pct-${version}-sources.jar.asc --detach-sign bundle/pct-${version}-sources.jar"
              sh "gpg --pinentry-mode loopback --passphrase \${MAVEN_GPG_PASSPHRASE} --armor --output bundle/pct-${version}-javadoc.jar.asc --detach-sign bundle/pct-${version}-javadoc.jar"
              sh "gpg --pinentry-mode loopback --passphrase \${MAVEN_GPG_PASSPHRASE} --armor --output bundle/pct-${version}.pom.asc --detach-sign bundle/pct-${version}.pom"

              sh "${ant}/bin/ant -Dversion=${version} central-bundle"

              sh 'curl --request POST --header "Authorization: Bearer \${BEARER_TOKEN}" --form bundle=@central-bundle.zip \'https://central.sonatype.com/api/v1/publisher/upload?name=pct&publishingType=USER_MANAGED\''
              mail body: "https://central.sonatype.com/publishing/deployments", to: "g.querret@riverside-software.fr", subject: "pct - Publish artifact on Central"
            }
          }
        }
      }
    }
  }

  post {
    unstable {
      script {
        mail body: "Check console output at ${BUILD_URL}/console", to: "g.querret@riverside-software.fr", subject: "PCT ${BRANCH_NAME} build is unstable"
      }
    }
    failure {
      script {
        mail body: "Check console output at ${BUILD_URL}/console", to: "g.querret@riverside-software.fr", subject: "PCT ${BRANCH_NAME} build failure"
      }
    }
    fixed {
      script {
        mail body: "Console output at ${BUILD_URL}/console", to: "g.querret@riverside-software.fr", subject: "PCT ${BRANCH_NAME} build is back to normal"
      }
    }
  }
}

def testBranch(nodeName, jdkVersion, antVersion, dlcVersion, stashCoverage, label, dockerImg) {
  node(nodeName) {
    ws {
      deleteDir()
      def dlc = tool name: dlcVersion, type: 'openedge'
      def jdk = tool name: jdkVersion, type: 'jdk'
      def antHome = tool name: antVersion, type: 'ant'
      unstash name: 'tests'
      if (isUnix()) {
        docker.image(dockerImg).inside('') {
          sh "ant -DDLC=/opt/progress/dlc -DPROFILER=true -DTESTENV=${label} -lib dist/PCT-signed.jar -f tests.xml init dist"
        }
      } else {
        withEnv(["JAVA_HOME=${jdk}"]) {
          bat "${antHome}/bin/ant -lib dist/PCT.jar -DDLC=${dlc} -DPROFILER=true -DTESTENV=${label} -f tests.xml init dist"
        }
      }
      stash name: "junit-${label}", includes: 'junitreports-*.zip'
      archiveArtifacts 'emailable-report-*.html'
      if (stashCoverage) {
        stash name: "coverage-${label}", includes: "profiler/jacoco-${label}.exec,oe-profiler-data-${label}.zip"
      }
    }
  }
}
