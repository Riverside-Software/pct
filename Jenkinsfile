node {
  checkout scm
  def antHome = tool name: 'Ant 1.9', type: 'hudson.tasks.Ant$AntInstallation'
  def dlc9 = tool name: 'OE-9.1E', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def dlc10 = tool name: 'OE-10.2B', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def dlc10-64 = tool name: 'OE-10.2B-64b', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  def dlc11 = tool name: 'OE-11.7', type: 'jenkinsci.plugin.openedge.OpenEdgeInstallation'
  
  sh "${antHome}/bin/ant -DDLC9=${dlc8} -DDLC10=${dlc10} -DDLC10-64=${dlc10-64} -DDLC11=${dlc11} -DBUILD_NUMBER=${env.BUILD_NUMBER} dist"
}
