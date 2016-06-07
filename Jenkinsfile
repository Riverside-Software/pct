node {
  checkout scm
  def antHome = tool name: 'Ant 1.9', type: 'hudson.tasks.Ant$AntInstallation'
  sh "${antHome}/bin/ant dist"
}
