stage 'Class documentation build'
node ('EC2-EU1B') {
  deleteDir()
  checkout scm
  def antHome = tool name: 'Ant 1.9', type: 'hudson.tasks.Ant$AntInstallation'
  def dlc11 = tool name: 'OE-11.6', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def jdk = tool name: 'JDK 7 64b', type: 'hudson.model.JDK'

  withEnv(["JAVA_HOME=${jdk}"]) {
    bat "${antHome}\\bin\\ant -DDLC=${dlc11} classDoc"
  }
  stash name: 'classdoc', includes: 'dist/classDoc.zip'
}

stage 'Standard build'
node ('master') {
  deleteDir()
  checkout scm
  def antHome = tool name: 'Ant 1.9', type: 'hudson.tasks.Ant$AntInstallation'
  def dlc9 = tool name: 'OE-9.1E', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def dlc10 = tool name: 'OE-10.2B', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def dlc10_64 = tool name: 'OE-10.2B-64b', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def dlc11 = tool name: 'OE-11.7', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'

  unstash name: 'classdoc'
  sh "${antHome}/bin/ant -DDLC9=${dlc9} -DDLC10=${dlc10} -DDLC10-64=${dlc10_64} -DDLC11=${dlc11} -DBUILD_NUMBER=${env.BUILD_NUMBER} dist"
  step([$class: 'ArtifactArchiver', artifacts: 'dist/PCT.jar'])
  stash name: 'tests', includes: 'dist/testcases.zip,tests.xml'
}

stage 'Fail-fast tests'
node('master') {
  ws {
    deleteDir()
    def dlc11 = tool name: 'OE-11.7', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
    def antHome = tool name: 'Ant 1.9', type: 'hudson.tasks.Ant$AntInstallation'
    unstash name: 'tests'
    sh "${antHome}/bin/ant -DDLC=${dlc11} -f tests.xml init dist"
  }
}

// see https://issues.jenkins-ci.org/browse/JENKINS-31924
def gitClean() {
    timeout(time: 60, unit: 'SECONDS') {
        if (fileExists('.git')) {
            echo 'Found Git repository: using Git to clean the tree.'
            // The sequence of reset --hard and clean -fdx first
            // in the root and then using submodule foreach
            // is based on how the Jenkins Git SCM clean before checkout
            // feature works.
            if (isUnix()) {
              sh 'git reset --hard'
            } else {
              bat 'git reset --hard'
            }
            // Note: -e is necessary to exclude the temp directory
            // .jenkins-XXXXX in the workspace where Pipeline puts the
            // batch file for the 'bat' command.
            if (isUnix()) {
              sh 'git clean -ffdx -e ".jenkins-*/"'
              sh 'git submodule foreach --recursive git reset --hard'
              sh 'git submodule foreach --recursive git clean -ffdx'
            } else {
              bat 'git clean -ffdx -e ".jenkins-*/"'
              bat 'git submodule foreach --recursive git reset --hard'
              bat 'git submodule foreach --recursive git clean -ffdx'
            }
        }
        else
        {
            echo 'No Git repository found: using deleteDir() to wipe clean'
            deleteDir()
        }
    }
}
