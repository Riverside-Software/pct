/**
 * Copyright 2005-2024 Riverside Software
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
package com.phenix.pct.test;

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertNotEquals;
import static org.testng.Assert.assertNotNull;
import static org.testng.Assert.assertTrue;
import static org.testng.Assert.fail;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.tools.ant.BuildEvent;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.BuildListener;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.ProjectHelper;
import org.testng.Reporter;
import org.testng.annotations.AfterTest;

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

    public List<String> getLogBuffer() {
        return logBuffer;
    }

    public List<String> getFullLogBuffer() {
        return fullLogBuffer;
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
        } catch (BuildException ex) {
            buildException = ex;
            if ((null != msg) && (!ex.getMessage().equals(msg))) {
                fail("Should throw BuildException because '" + cause + "' with message '" + msg
                        + "' (actual message '" + ex.getMessage() + "' instead)");
            }
            return;
        }
        fail("Should throw BuildException because: " + cause);
    }

    /**
     * assert that a property equals "true".
     * 
     * @param property property name
     */
    public void assertPropertySet(String property) {
        assertNotEquals(project.getProperty(property), null);
    }

    /**
     * assert that a property is null.
     * 
     * @param property property name
     */
    public void assertPropertyUnset(String property) {
        assertEquals(project.getProperty(property), null);
    }

    /**
     * assert that a property equals a value; comparison is case sensitive.
     * 
     * @param property property name
     * @param value expected value
     */
    public void assertPropertyEquals(String property, String value) {
        String result = project.getProperty(property);
        assertEquals(result, value, "property " + property);
    }

    public void assertPropertyMatches(String property, String pattern) {
        String result = project.getProperty(property);
        assertTrue(result.matches(pattern),
                MessageFormat.format(
                        "Property ''{0}'' with value ''{1}'' doesn''t match pattern ''{2}''",
                        property, result, pattern));
    }

    /**
     * Assert that the given message has been logged with a priority &lt;= INFO when running the
     * given target.
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
            fail("Message not found");
    }

    /**
     * Runs a target, wait for a build exception, and expect specific log output
     */
    public void expectLogAndBuildException(String target, String[] expectedLog) {
        try {
            executeTarget(target);
        } catch (BuildException ex) {
            buildException = ex;
            for (int zz = 0; zz < expectedLog.length; zz++) {
                assertEquals(logBuffer.get(zz), expectedLog[zz]);
            }
            return;
        }
        fail("Should throw BuildException");
    }

    /**
     * Assert that the given messages were the only ones logged with a priority &lt;= INFO when
     * running the given target.
     */
    public void expectLog(String target, String[] expectedLog) {
        executeTarget(target);
        assertEquals(logBuffer.size(), expectedLog.length);
        for (int zz = 0; zz < expectedLog.length; zz++) {
            assertEquals(logBuffer.get(zz), expectedLog[zz]);
        }
    }

    public void expectLogRegexp(String target, List<String> regexps, boolean strict) {
        executeTarget(target);
        Iterator<String> iter = regexps.iterator();
        for (String s : logBuffer) {
            if (!iter.hasNext()) {
                if (strict) {
                    fail("Not enough regexp, current line '" + s + "'");
                }
                return;
            }
            java.util.regex.Pattern regExp = java.util.regex.Pattern.compile(iter.next());
            if (!regExp.matcher(s).matches()) {
                fail("Log '" + s + "' doesn't match regular expression '" + regExp.toString()
                        + "'");
                return;
            }
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
        assertNotNull(url, "Could not find resource :" + resource);
        return url;
    }

    /**
     * Sets up to run the named project
     * 
     * @param filename name of project file to run
     */
    public void configureProject(String filename) {
        configureProject(filename, Project.MSG_DEBUG);
    }

    /**
     * Sets up to run the named project
     * 
     * @param filename name of project file to run
     */
    public void configureProject(String filename, int logLevel) {
        logBuffer = new ArrayList<>();
        fullLogBuffer = new ArrayList<>();
        project = new Project();
        project.init();
        File antFile = new File(System.getProperty("root"), filename);
        project.setUserProperty("ant.file", antFile.getAbsolutePath());

        project.addBuildListener(new AntTestListener(logLevel));
        ProjectHelper.configureProject(project, antFile);

    }

    protected static boolean searchInList(List<String> log, String pattern) {
        for (String str : log) {
            if (str.contains(pattern))
                return true;
        }
        return false;
    }

    protected static boolean searchInFile(File file, String pattern) {
        try {
            return searchInList(Files.readAllLines(file.toPath(), StandardCharsets.UTF_8), pattern);
        } catch (IOException caught) {
            return false;
        }
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
