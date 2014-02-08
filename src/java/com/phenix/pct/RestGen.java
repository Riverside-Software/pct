/*
 * Copyright  2000-2004 The Apache Software Foundation
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package com.phenix.pct;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Java;
import org.apache.tools.ant.taskdefs.condition.Os;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.Environment;

import java.io.File;

/**
 * Proxygen task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class RestGen extends PCT {
    // Class used by Proxygen
    private static final String PROXYGEN_CLASS = "com.progress.rest.tools.WARGenerator";

    private static enum RestGenerationType {
        REST_SERVICE_PAAR("Paar"), MOBILE_SERVICE_PAAR("MobPaar"), REST_SERVICE_WAR("RESTWar"), MOBILE_SERVICE_WAR(
                "MobWar"), MOBILE_APP_WAR("MobAppWar"), MOBILE_APP("OnlyMobApp");

        private String value;

        private RestGenerationType(String value) {
            this.value = value;
        }

        public static RestGenerationType get(String str) {
            for (RestGenerationType type : RestGenerationType.values()) {
                if (type.value.equalsIgnoreCase(str))
                    return type;
            }

            return null;
        }
    }

    private File projectDir = null;
    private RestGenerationType type = null;
    private File destFile = null;
    private String services = null;
    private boolean includeJars = false;

    private Java pxg = null;

    public void setProjectDir(File project) {
        this.projectDir = project;
    }
    
    public void setType(String type) {
        this.type = RestGenerationType.get(type);
        if (this.type == null)
            throw new BuildException("Invalid value for argument type");
    }
    
    public void setDestFile(File destFile) {
        this.destFile = destFile;
    }
    
    public void setServices(String services) {
        this.services = services;
    }
    
    public void setIncludeJars(boolean includeJars) {
        this.includeJars = includeJars;
    }

    /**
     * For jvmarg nested elements
     */
    public Commandline.Argument createJvmarg() {
        if (pxg == null) {
            pxg = new Java(this);
        }

        return pxg.getCommandLine().createVmArgument();
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        if (projectDir == null) {
            throw new BuildException(Messages.getString("PCTProxygen.1")); //$NON-NLS-1$
        }
        if (this.type == null)
            throw new BuildException("Invalid value for argument type");
        

        checkDlcHome();

        // Creates a new Java task to launch proxygen task
        if (pxg == null) {
            pxg = new Java(this);
        }

        // The previous behaviour was to fork only when working directory was specified.
        // This caused problems with JUnit testing, as I think there are System.exit statements
        // in proxygen code
        pxg.setFork(true);
        // No included JDK on UNIX
        if (Os.isFamily(Os.FAMILY_WINDOWS) || (Os.isFamily(Os.FAMILY_UNIX) /* >= v11 */))
            pxg.setJvm(getJVM().getAbsolutePath());
        pxg.setDir(this.getProject().getBaseDir());

        pxg.setClassname(PROXYGEN_CLASS);
        pxg.createClasspath().add(getRestGenClasspath(getProject()));
        // Bug #1114731 : new way of handling JAR dependencies
//        pxg.createClasspath().addFileset(this.getJavaFileset(this.getProject()));

//        // As Progress doesn't know command line parameters,
//        // arguments are given via environment variables
//        Environment.Variable var = new Environment.Variable();
//        // Bug #1311746 : mixed case extension are not handled correctly
//        // So, at first extract extension and then compare ignore case
//        int ext_pos = this.srcFile.toString().lastIndexOf('.');
//        String extension = (ext_pos == -1 ? "" : this.srcFile.toString().substring(ext_pos));
//        if (extension.equalsIgnoreCase(".xpxg")) //$NON-NLS-1$
//            var.setKey("XPXGFile"); //$NON-NLS-1$
//        else
//            var.setKey("PXGFile"); //$NON-NLS-1$

//        var.setValue(this.srcFile.toString());
//        pxg.addSysproperty(var);

        Environment.Variable var2 = new Environment.Variable();
        var2.setKey("Install.Dir"); //$NON-NLS-1$
        var2.setValue(this.getDlcHome().toString());
        pxg.addSysproperty(var2);

        Environment.Variable var3 = new Environment.Variable();
        var3.setKey("Work.Dir"); //$NON-NLS-1$
        var3.setValue(getProject().getBaseDir().getAbsolutePath());
        pxg.addSysproperty(var3);
        
        Environment.Variable var10 = new Environment.Variable();
        var10.setKey("aver"); //$NON-NLS-1$
        var10.setValue("11.3.2.00");
        pxg.addEnv(var10);
        
        Environment.Variable var11 = new Environment.Variable();
        var11.setKey("pexver"); //$NON-NLS-1$
        var11.setValue("2.3.2");
        pxg.addEnv(var11);
        
        Environment.Variable var12= new Environment.Variable();
        var12.setKey("cafver"); //$NON-NLS-1$
        var12.setValue("1.4.4");
        pxg.addEnv(var12);

        Environment.Variable var13= new Environment.Variable();
        var13.setKey("aloc"); //$NON-NLS-1$
        var13.setValue(new File(getPdsHome(), "eclipse\\plugins").getAbsolutePath());
        pxg.addEnv(var13);

//        set aver=11.3.2.00
//                set pexver=2.3.2
//                set cafver=1.4.4

//        Environment.Variable var3 = new Environment.Variable();
//        var3.setKey("ProxyGen.LeaveProxyFiles"); //$NON-NLS-1$
//        var3.setValue((this.keepFiles ? "yes" : "no")); //$NON-NLS-1$ //$NON-NLS-2$
//        pxg.addSysproperty(var3);

        Environment.Variable var4 = new Environment.Variable();
        var4.setKey("DLC"); //$NON-NLS-1$
        var4.setValue(this.getDlcHome().toString());
        pxg.addEnv(var4);
        
        Environment.Variable var5 = new Environment.Variable();
        var5.setKey("PDS_HOME"); //$NON-NLS-1$
        var5.setValue(this.getPdsHome().toString());
        pxg.addEnv(var5);

//        Environment.Variable var6 = new Environment.Variable();
//        var6.setKey("Proxygen.StartDir"); //$NON-NLS-1$
//        var6.setValue(workingDirectory.getAbsolutePath());
//        pxg.addSysproperty(var6);

        pxg.getCommandLine().createArgument().setValue("-proj");
        pxg.getCommandLine().createArgument().setValue(projectDir.getAbsolutePath());

        if ((type == RestGenerationType.REST_SERVICE_PAAR) || (type == RestGenerationType.REST_SERVICE_WAR)) {
            pxg.getCommandLine().createArgument().setValue("-restSvcNames");
        } else if ((type == RestGenerationType.MOBILE_SERVICE_PAAR) || (type == RestGenerationType.MOBILE_SERVICE_WAR)) {
            pxg.getCommandLine().createArgument().setValue("-mobSvcNames");
        } else {
            pxg.getCommandLine().createArgument().setValue("-mobApps");
        }
        pxg.getCommandLine().createArgument().setValue(services);

        
        pxg.getCommandLine().createArgument().setValue("-target");
        pxg.getCommandLine().createArgument().setValue(destFile.getAbsolutePath());
        
        if (!includeJars) {
            pxg.getCommandLine().createArgument().setValue("-includeJars");
            pxg.getCommandLine().createArgument().setValue("false");
        }
        
        pxg.getCommandLine().createArgument().setValue("-gen" + type.value);

        System.out.println("cmd : " + pxg.getCommandLine().toString());
//        pxg.setFailonerror(true);
        pxg.execute();
//        System.out.println("retval : " + retVal);
//        if (retVal != 0) {
//            throw new BuildException("PCTProxygen failed - Return code " + retVal
//                    + " - Command line : " + pxg.getCommandLine().toString());
//        }
    }
}
