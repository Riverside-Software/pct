stage('Class documentation build') {
 node ('windows') {
  checkout([$class: 'GitSCM', branches: scm.branches, extensions: scm.extensions + [[$class: 'CleanCheckout']], userRemoteConfigs: scm.userRemoteConfigs])

  def antHome = tool name: 'Ant 1.9', type: 'hudson.tasks.Ant$AntInstallation'
  def dlc11 = tool name: 'OpenEdge-11.7', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def dlc12 = tool name: 'OpenEdge-12.0', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def jdk = tool name: 'JDK8', type: 'hudson.model.JDK'

  withEnv(["JAVA_HOME=${jdk}"]) {
    bat "${antHome}\\bin\\ant -DDLC11=${dlc11} -DDLC12=${dlc12} classDoc"
  }
  stash name: 'classdoc', includes: 'dist/classDoc.zip'
 }
}

stage('Standard build') {
 node ('linux') {
  checkout([$class: 'GitSCM', branches: scm.branches, extensions: scm.extensions + [[$class: 'CleanCheckout']], userRemoteConfigs: scm.userRemoteConfigs])

  sh 'git rev-parse HEAD > head-rev'
  def commit = readFile('head-rev').trim()

  def antHome = tool name: 'Ant 1.9', type: 'hudson.tasks.Ant$AntInstallation'
  def dlc10 = tool name: 'OpenEdge-10.2B', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def dlc10_64 = tool name: 'OpenEdge-10.2B-64b', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def dlc11 = tool name: 'OpenEdge-11.7', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def dlc12 = tool name: 'OpenEdge-12.0', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'

  unstash name: 'classdoc'
  withEnv(["TERM=xterm"]) {
    sh "${antHome}/bin/ant -DDLC10=${dlc10} -DDLC10-64=${dlc10_64} -DDLC11=${dlc11} -DDLC12=${dlc12} -DGIT_COMMIT=${commit} dist"
  }
  stash name: 'tests', includes: 'dist/testcases.zip,tests.xml'
  archiveArtifacts 'dist/PCT.jar,dist/PCT-javadoc.jar,dist/PCT-sources.jar'
 }
}

stage('Full tests') {
 parallel branch1: { testBranch('windows', 'OpenEdge-10.2B', false, '10.2-Win', 10, 32) },
    branch2: { testBranch('windows', 'OpenEdge-11.7', true, '11.7-Win', 11, 32) },
    branch3: { testBranch('linux', 'OpenEdge-10.2B-64b', false, '10.2-64-Linux', 10, 64) },
    branch4: { testBranch('linux', 'OpenEdge-11.6', false, '11.6-Linux', 11, 64) },
    branch5: { testBranch('linux', 'OpenEdge-11.7', false, '11.7-Linux', 11, 64) },
    branch6: { testBranch('linux', 'OpenEdge-10.2B', false, '10.2-Linux', 10, 32) },
    branch7: { testBranch('linux', 'OpenEdge-12.0', false, '12.0-Linux', 12, 64) },
    branch8: { testBranch('windows', 'OpenEdge-12.0', true, '12.0-Win', 12, 64) },
    failFast: false
  node('linux') {
    // Wildcards not accepted in unstash...
    unstash name: 'junit-10.2-Win'
    unstash name: 'junit-11.7-Win'
    unstash name: 'junit-10.2-Linux'
    unstash name: 'junit-10.2-64-Linux'
    unstash name: 'junit-11.6-Linux'
    unstash name: 'junit-11.7-Linux'
    unstash name: 'junit-12.0-Linux'
    unstash name: 'junit-12.0-Win'
    sh "mkdir junitreports"
    unzip zipFile: 'junitreports-10.2-Win.zip', dir: 'junitreports'
    unzip zipFile: 'junitreports-11.7-Win.zip', dir: 'junitreports'
    unzip zipFile: 'junitreports-10.2-Linux.zip', dir: 'junitreports'
    unzip zipFile: 'junitreports-10.2-64-Linux.zip', dir: 'junitreports'
    unzip zipFile: 'junitreports-11.6-Linux.zip', dir: 'junitreports'
    unzip zipFile: 'junitreports-11.7-Linux.zip', dir: 'junitreports'
    unzip zipFile: 'junitreports-12.0-Linux.zip', dir: 'junitreports'
    unzip zipFile: 'junitreports-12.0-Win.zip', dir: 'junitreports'
    junit 'junitreports/**/*.xml'
  }
}

stage('Sonar') {
  node('linux') {
    def antHome = tool name: 'Ant 1.9', type: 'hudson.tasks.Ant$AntInstallation'
    def dlc = tool name: 'OpenEdge-11.7', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
    unstash name: 'coverage-11.7-Win'
    unstash name: 'coverage-12.0-Win'
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
      withEnv(["TERM=xterm"]) {
        if (isUnix())
          sh "${antHome}/bin/ant -DDLC=${dlc} -DPROFILER=true -DTESTENV=${label} -DOE_MAJOR_VERSION=${majorVersion} -DOE_ARCH=${arch} -f tests.xml init dist"
        else
          bat "${antHome}/bin/ant -DDLC=${dlc} -DPROFILER=true -DTESTENV=${label} -DOE_MAJOR_VERSION=${majorVersion} -DOE_ARCH=${arch} -f tests.xml init dist"
      }
      stash name: "junit-${label}", includes: 'junitreports-*.zip'
      archiveArtifacts 'emailable-report-*.html'
      if (stashCoverage) {
        stash name: "coverage-${label}", includes: "profiler/jacoco-${label}.exec,oe-profiler-data-${label}.zip"
      }
    }
  }
}
