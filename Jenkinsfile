stage('Class documentation build') {
 node ('windows') {
  checkout([$class: 'GitSCM', branches: scm.branches, extensions: scm.extensions + [[$class: 'CleanCheckout']], userRemoteConfigs: scm.userRemoteConfigs])

  def antHome = tool name: 'Ant 1.9', type: 'ant'
  def dlc11 = tool name: 'OpenEdge-11.7', type: 'openedge'
  def dlc12 = tool name: 'OpenEdge-12.1', type: 'openedge'
  def jdk = tool name: 'JDK8', type: 'jdk'

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

  def jdk = tool name: 'JDK8', type: 'jdk'
  def antHome = tool name: 'Ant 1.9', type: 'ant'
  def dlc11 = tool name: 'OpenEdge-11.7', type: 'openedge'
  def dlc12 = tool name: 'OpenEdge-12.1', type: 'openedge'

  unstash name: 'classdoc'
  withEnv(["TERM=xterm", "JAVA_HOME=${jdk}"]) {
    sh "${antHome}/bin/ant -DDLC11=${dlc11} -DDLC12=${dlc12} -DGIT_COMMIT=${commit} dist"
  }
  stash name: 'tests', includes: 'dist/PCT.jar,dist/testcases.zip,tests.xml'
  archiveArtifacts 'dist/PCT.jar,dist/PCT-javadoc.jar,dist/PCT-sources.jar'
 }
}

stage('Full tests') {
 parallel branch1: { testBranch('windows', 'JDK8', 'Ant 1.9', 'OpenEdge-11.7', true, '11.7-Win') },
          branch2: { testBranch('linux', 'JDK8', 'Ant 1.9', 'OpenEdge-11.6', false, '11.6-Linux') },
          branch3: { testBranch('linux', 'JDK8', 'Ant 1.9', 'OpenEdge-11.7', false, '11.7-Linux') },
          branch4: { testBranch('linux', 'Corretto 8', 'Ant 1.10', 'OpenEdge-12.0', false, '12.0-Linux') },
          branch5: { testBranch('windows', 'Corretto 8', 'Ant 1.10', 'OpenEdge-12.0', false, '12.0-Win') },
          branch6: { testBranch('windows', 'Corretto 8', 'Ant 1.10', 'OpenEdge-12.1', true, '12.1-Win') },
          branch7: { testBranch('linux', 'Corretto 8', 'Ant 1.10', 'OpenEdge-12.1', false, '12.1-Linux') },
          failFast: false

  node('linux') {
    // Wildcards not accepted in unstash...
    unstash name: 'junit-11.7-Win'
    unstash name: 'junit-11.6-Linux'
    unstash name: 'junit-11.7-Linux'
    unstash name: 'junit-12.0-Linux'
    unstash name: 'junit-12.0-Win'
    unstash name: 'junit-12.1-Win'
    unstash name: 'junit-12.1-Linux'

    sh "mkdir junitreports"
    unzip zipFile: 'junitreports-11.7-Win.zip', dir: 'junitreports'
    unzip zipFile: 'junitreports-11.6-Linux.zip', dir: 'junitreports'
    unzip zipFile: 'junitreports-11.7-Linux.zip', dir: 'junitreports'
    unzip zipFile: 'junitreports-12.0-Linux.zip', dir: 'junitreports'
    unzip zipFile: 'junitreports-12.0-Win.zip', dir: 'junitreports'
    unzip zipFile: 'junitreports-12.1-Win.zip', dir: 'junitreports'
    unzip zipFile: 'junitreports-12.1-Linux.zip', dir: 'junitreports'
    junit 'junitreports/**/*.xml'
  }
}

stage('Sonar') {
  node('linux') {
    def antHome = tool name: 'Ant 1.9', type: 'ant'
    def dlc = tool name: 'OpenEdge-11.7', type: 'openedge'
    unstash name: 'coverage-11.7-Win'
    unstash name: 'coverage-12.1-Win'
    withCredentials([string(credentialsId: 'AdminTokenSonarQube', variable: 'SQ_TOKEN')]) {
      sh "${antHome}/bin/ant -lib lib/sonarqube-ant-task-2.6.0.1426.jar -lib lib/jacocoant-0.8.4.jar -f sonar.xml -Dsonar.login=${env.SQ_TOKEN} -Dsonar.host.url=http://sonar.riverside-software.fr -Dsonar.branch.name=${env.BRANCH_NAME} -DDLC=${dlc} sonar"
    }
  }
}

def testBranch(nodeName, jdkVersion, antVersion, dlcVersion, stashCoverage, label) {
  node(nodeName) {
    ws {
      deleteDir()
      def dlc = tool name: dlcVersion, type: 'openedge'
      def jdk = tool name: jdkVersion, type: 'jdk'
      def antHome = tool name: antVersion, type: 'ant'
      unstash name: 'tests'
      withEnv(["TERM=xterm", "JAVA_HOME=${jdk}"]) {
        if (isUnix())
          sh "${antHome}/bin/ant -lib dist/PCT.jar -DDLC=${dlc} -DPROFILER=true -DTESTENV=${label} -f tests.xml init dist"
        else
          bat "${antHome}/bin/ant -lib dist/PCT.jar -DDLC=${dlc} -DPROFILER=true -DTESTENV=${label} -f tests.xml init dist"
      }
      stash name: "junit-${label}", includes: 'junitreports-*.zip'
      archiveArtifacts 'emailable-report-*.html'
      if (stashCoverage) {
        stash name: "coverage-${label}", includes: "profiler/jacoco-${label}.exec,oe-profiler-data-${label}.zip"
      }
    }
  }
}
