stage('Class documentation build') {
 node ('windows') {
  gitClean()
  checkout scm
  def antHome = tool name: 'Ant 1.9', type: 'hudson.tasks.Ant$AntInstallation'
  def dlc11 = tool name: 'OpenEdge-11.7', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def jdk = tool name: 'JDK8', type: 'hudson.model.JDK'

  withEnv(["JAVA_HOME=${jdk}"]) {
    bat "${antHome}\\bin\\ant -DDLC11=${dlc11} classDoc"
  }
  stash name: 'classdoc', includes: 'dist/classDoc.zip'
 }
}

stage('Standard build') {
 node ('linux') {
  gitClean()
  checkout scm
  sh 'git rev-parse HEAD > head-rev'
  def commit = readFile('head-rev').trim()
  def antHome = tool name: 'Ant 1.9', type: 'hudson.tasks.Ant$AntInstallation'
  def dlc10 = tool name: 'OpenEdge-10.2B', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def dlc10_64 = tool name: 'OpenEdge-10.2B-64b', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def dlc11 = tool name: 'OpenEdge-11.7', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  unstash name: 'classdoc'
  sh "${antHome}/bin/ant -DDLC10=${dlc10} -DDLC10-64=${dlc10_64} -DDLC11=${dlc11} -DGIT_COMMIT=${commit} dist"
  stash name: 'tests', includes: 'dist/testcases.zip,tests.xml'
  archive 'dist/PCT.jar'
 }
}

stage('Full tests') {
 parallel branch8: { testBranch('windows', 'OpenEdge-10.2B', false, '10.2-Win', 10, 32) },
    branch1: { testBranch('windows', 'OpenEdge-11.7', true, '11.7-Win', 11, 32) },
    branch4: { testBranch('linux', 'OpenEdge-10.2B-64b', false, '10.2-64-Linux', 10, 64) },
    branch5: { testBranch('linux', 'OpenEdge-11.6', false, '11.6-Linux', 11, 64) },
    branch6: { testBranch('linux', 'OpenEdge-11.7', false, '11.7-Linux', 11, 64) },
    branch7: { testBranch('linux', 'OpenEdge-10.2B', false, '10.2-Linux', 10, 32) },
    failFast: false
  node('linux') {
    // Wildcards not accepted in unstash...
    unstash name: 'testng-10.2-Win'
    unstash name: 'testng-11.7-Win'
    unstash name: 'testng-10.2-Linux'
    unstash name: 'testng-10.2-64-Linux'
    unstash name: 'testng-11.6-Linux'
    unstash name: 'testng-11.7-Linux'
    step([$class: 'Publisher', reportFilenamePattern: 'testng-results-*.xml'])
  }
}

stage('Sonar') {
  node('linux') {
    def antHome = tool name: 'Ant 1.9', type: 'hudson.tasks.Ant$AntInstallation'
    def dlc = tool name: 'OpenEdge-11.7', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
    unstash name: 'coverage'
    withCredentials([string(credentialsId: 'AdminTokenSonarQube', variable: 'SQ_TOKEN')]) {
      sh "${antHome}/bin/ant -lib lib/sonarqube-ant-task-2.5.jar -f sonar.xml -Dsonar.login=${env.SQ_TOKEN} -DSONAR_URL=http://sonar.riverside-software.fr -DBRANCH_NAME=${env.BRANCH_NAME} -DDLC=${dlc} sonar"
    }
  }
}

def testBranch(nodeName, dlcVersion, stashCoverage, label, majorVersion, arch) {
  node(nodeName) {
    ws {
      deleteDir()
      def dlc = tool name: dlcVersion, type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
      def antHome = tool name: 'Ant 1.9', type: 'hudson.tasks.Ant$AntInstallation'
      unstash name: 'tests'
      if (isUnix())
        sh "${antHome}/bin/ant -DDLC=${dlc} -DPROFILER=true -DTESTENV=${label} -DOE_MAJOR_VERSION=${majorVersion} -DOE_ARCH=${arch} -f tests.xml init dist"
      else
        bat "${antHome}/bin/ant -DDLC=${dlc} -DPROFILER=true -DTESTENV=${label} -DOE_MAJOR_VERSION=${majorVersion} -DOE_ARCH=${arch} -f tests.xml init dist"
      stash name: "testng-${label}", includes: 'testng-results-*.xml'
      archive 'emailable-report-*.html'
      if (stashCoverage) {
        stash name: 'coverage', includes: 'profiler/jacoco.exec,oe-profiler-data.zip'
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
