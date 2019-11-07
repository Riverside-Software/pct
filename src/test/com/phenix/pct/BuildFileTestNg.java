/**
 * Copyright 2005-2019 Riverside Software
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
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.tools.ant.BuildEvent;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.BuildListener;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.ProjectHelper;
import org.testng.Assert;
import org.testng.Reporter;
import org.testng.annotations.AfterTest;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

public class BuildFileTestNg {
    private Project project;

    private List<String> logBuffer;
    private List<String> fullLogBuffer;
    private BuildException buildException;

    @AfterTest
    public void tearDown() {
        if (project.getTargets().containsKey("tearDown")) {
            project.executeTarget("tearDown");
        }
    }

    /**
     * Get the project which has been configured for a test.
     * 
     * @return the Project instance for this test.
     */
    public Project getProject() {
        return project;
    }

    public BuildException getBuildException() {
        return buildException;
    }

    /**
     * Executes a target we have set up
     * 
     * @pre configureProject has been called
     * @param targetName target to run
     */
    public void executeTarget(String targetName) {
        logBuffer = new ArrayList<>();
        fullLogBuffer = new ArrayList<>();
        buildException = null;
        project.executeTarget(targetName);
    }

    /**
     * run a target, expect for any build exception
     * 
     * @param target target to run
     * @param cause information string to reader of report
     */
    public void expectBuildException(String target, String cause) {
        expectSpecificBuildException(target, cause, null);
    }

    /**
     * Runs a target, wait for a build exception.
     * 
     * @param target target to run
     * @param cause information string to reader of report
     * @param msg the message value of the build exception we are waiting for set to null for any
     *            build exception to be valid
     */
    public void expectSpecificBuildException(String target, String cause, String msg) {
        try {
            executeTarget(target);
        } catch (org.apache.tools.ant.BuildException ex) {
            buildException = ex;
            if ((null != msg) && (!ex.getMessage().equals(msg))) {
                Assert.fail("Should throw BuildException because '" + cause + "' with message '"
                        + msg + "' (actual message '" + ex.getMessage() + "' instead)");
            }
            return;
        }
        Assert.fail("Should throw BuildException because: " + cause);
    }

    /**
     * assert that a property equals "true".
     * 
     * @param property property name
     */
    public void assertPropertySet(String property) {
        Assert.assertNotEquals(project.getProperty(property), null);
    }

    /**
     * assert that a property is null.
     * 
     * @param property property name
     */
    public void assertPropertyUnset(String property) {
        Assert.assertEquals(project.getProperty(property), null);
    }

    /**
     * assert that a property equals a value; comparison is case sensitive.
     * 
     * @param property property name
     * @param value expected value
     */
    public void assertPropertyEquals(String property, String value) {
        String result = project.getProperty(property);
        Assert.assertEquals(result, value, "property " + property);
    }

    /**
     * Assert that the given message has been logged with a priority &lt;= INFO when running
     * the given target.
     */
    public void expectLog(String target, String log) {
        executeTarget(target);
        boolean found = false;
        for (String str : logBuffer) {
            if (!found) {
                found = str.equals(log);
            }
        }
        if (!found)
            Assert.fail("Message not found");
    }

    /**
     * Assert that the given messages were the only ones logged with a priority &lt;= INFO
     * when running the given target.
     */
    public void expectLog(String target, String[] expectedLog) {
        executeTarget(target);
        Assert.assertEquals(logBuffer.size(), expectedLog.length);
        for (int zz = 0; zz < expectedLog.length; zz++) {
            Assert.assertEquals(logBuffer.get(zz), expectedLog[zz]);
        }
    }

    public void expectLogRegexp(String target, List<String> regexps, boolean strict) {
        executeTarget(target);
        Iterator<String> iter = regexps.iterator();
        for (String s : logBuffer) {
            if (!iter.hasNext()) {
                if (strict) {
                    Assert.fail("Not enough regexp, current line '" + s + "'");
                }
                return;
            }
            java.util.regex.Pattern regExp = java.util.regex.Pattern.compile(iter.next());
            if (!regExp.matcher(s).matches()) {
                Assert.fail("Log '" + s + "' doesn't match regular expression '" + regExp.toString() + "'");
                return;
            }
        }
    }

    /**
     * Assert that the content of given filename is identical to the expectedContent
     */
    public void expectLogFileContent(String target, String file, String expectedContent) {
        executeTarget(target);
        try {
            String content = new String(Files.readAllBytes(Paths.get(new File(file).getAbsolutePath())));
            if (!content.equals(expectedContent)) {
                Assert.fail("Log '" + content + "' doesn't match expected result '" + expectedContent + "'");
            }
        } catch (IOException e) {
            Assert.fail("Error while accessing the file  '" + file +"' with message " + e.getMessage() );
        }  
    }

    /**
     * Retrieve a resource from the caller classloader to avoid assuming a vm working directory. The
     * resource path must be relative to the package name or absolute from the root path.
     * 
     * @param resource the resource to retrieve its url.
     * @throws junit.framework.AssertionFailedError if the resource is not found.
     */
    public URL getResource(String resource) {
        URL url = getClass().getResource(resource);
        Assert.assertNotNull(url, "Could not find resource :" + resource);
        return url;
    }

    /**
     * Sets up to run the named project
     * 
     * @param filename name of project file to run
     */
    public void configureProject(String filename) throws BuildException {
        configureProject(filename, Project.MSG_DEBUG);
    }

    /**
     * Sets up to run the named project
     * 
     * @param filename name of project file to run
     */
    public void configureProject(String filename, int logLevel) throws BuildException {
        logBuffer = new ArrayList<>();
        fullLogBuffer = new ArrayList<>();
        project = new Project();
        project.init();
        File antFile = new File(System.getProperty("root"), filename);
        project.setUserProperty("ant.file", antFile.getAbsolutePath());

        project.addBuildListener(new AntTestListener(logLevel));
        ProjectHelper.configureProject(project, antFile);

    }

    /**
     * Our own personal build listener.
     */
    private class AntTestListener implements BuildListener {
        private final int logLevel;

        /**
         * Constructs a test listener which will ignore log events above the given level.
         */
        public AntTestListener(int logLevel) {
            this.logLevel = logLevel;
        }

        @Override
        public void messageLogged(BuildEvent event) {
            if (event.getPriority() > logLevel) {
                return;
            }

            if (event.getPriority() <= Project.MSG_INFO) {
                logBuffer.add(event.getMessage());
                // Add message to TestNG reporting system
                Reporter.log(event.getMessage());
            }
            fullLogBuffer.add(event.getMessage());
        }

        @Override
        public void buildStarted(BuildEvent event) {
            // No-op
        }

        @Override
        public void buildFinished(BuildEvent event) {
            // No-op
        }

        @Override
        public void targetStarted(BuildEvent event) {
            // No-op
        }

        @Override
        public void targetFinished(BuildEvent event) {
            // No-op
        }

        @Override
        public void taskStarted(BuildEvent event) {
            // No-op
        }

        @Override
        public void taskFinished(BuildEvent event) {
            // No-op
        }
    }

}
