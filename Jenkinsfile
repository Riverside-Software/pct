stage 'Class documentation build'
node ('EC2-EU1B') {
  gitClean()
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
  gitClean()
  checkout scm
  def antHome = tool name: 'Ant 1.9', type: 'hudson.tasks.Ant$AntInstallation'
  def dlc9 = tool name: 'OE-9.1E', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def dlc10 = tool name: 'OE-10.2B', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def dlc10_64 = tool name: 'OE-10.2B-64b', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def dlc11 = tool name: 'OE-11.7', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'

  unstash name: 'classdoc'
  sh "${antHome}/bin/ant -DDLC9=${dlc9} -DDLC10=${dlc10} -DDLC10-64=${dlc10_64} -DDLC11=${dlc11} -DBUILD_NUMBER=${env.BUILD_NUMBER} dist"
  stash name: 'tests', includes: 'dist/testcases.zip,tests.xml'
  archive 'dist/PCT.jar'
}

stage 'Full tests'
parallel branch1: { testBranch('EC2-EU1B', 'OE-11.6', true) },
    branch2: { testBranch('EC2-EU1B', 'OE-11.7', false) },
    branch3: { testBranch('master', 'OE-9.1E', false) },
    branch4: { testBranch('master', 'OE-10.2B-64b', false) },
    branch5: { testBranch('master', 'OE-11.6', false) },
    branch6: { testBranch('master', 'OE-11.7', false) },
    branch7: { testBranch('master', 'OE-10.2B', false) },
    branch8: { testBranch('EC2-EU1B', 'OE-10.2B', false) },
    failFast: false

stage 'Sonar'
node('master') {
    def antHome = tool name: 'Ant 1.9', type: 'hudson.tasks.Ant$AntInstallation'
    def dlc = tool name: 'OE-11.6', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
    unstash name: 'coverage'
    sh "${antHome}/bin/ant -lib lib/sonar-ant-task-2.2.jar -f sonar-java.xml -DSONAR_URL=http://sonar.riverside-software.fr -DJOB_NAME=Dev2-PCT -DBUILD_NUMBER=${env.BUILD_NUMBER} sonar"
    sh "${antHome}/bin/ant -lib lib/sonar-ant-task-2.2.jar -f sonar-oe.xml -DSONAR_URL=http://sonar.riverside-software.fr -DJOB_NAME=Dev2-PCT -DBUILD_NUMBER=${env.BUILD_NUMBER} -DDLC=${dlc} sonar"
    sh "${antHome}/bin/ant -lib lib/sonar-ant-task-2.2.jar -f sonar-oe-dbg.xml -DSONAR_URL=http://sonar.riverside-software.fr -DJOB_NAME=Dev2-PCT -DBUILD_NUMBER=${env.BUILD_NUMBER} -DDLC=${dlc} sonar"
}

def testBranch(nodeName, dlcVersion, stashCoverage) { node(nodeName) {
    ws {
      deleteDir()
      def dlc = tool name: dlcVersion, type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
      def antHome = tool name: 'Ant 1.9', type: 'hudson.tasks.Ant$AntInstallation'
      unstash name: 'tests'
      if (isUnix())
        sh "${antHome}/bin/ant -DDLC=${dlc} -DPROFILER=true -f tests.xml init dist"
      else
        bat "${antHome}/bin/ant -DDLC=${dlc} -DPROFILER=true -f tests.xml init dist"
      // step([$class: 'hudson.plugins.testng.Publisher', reportFilenamePattern: 'test-output/testng-results.xml'])
      if (stashCoverage) {
        stash name: 'coverage', includes: 'profiler/*.exec,oe-profiler-data.zip'
      }
    }
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
