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

import java.io.DataOutputStream;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.Map.Entry;

import org.apache.tools.ant.BuildEvent;
import org.apache.tools.ant.BuildListener;
import org.apache.tools.ant.Task;

public class AnalyticsBuildListener implements BuildListener {
    private static final Map<String, Integer> taskCount = new HashMap<>();

    private boolean isPCTTask(Task task) {
        if (task.getTaskType().toLowerCase().startsWith("pct"))
            return true;
        return ("DlcVersion".equalsIgnoreCase(task.getTaskType())
                || "RestGen".equalsIgnoreCase(task.getTaskType())
                || "ClassDocumentation".equalsIgnoreCase(task.getTaskType())
                || "ABLDuck".equalsIgnoreCase(task.getTaskType())
                || "ProUnit".equalsIgnoreCase(task.getTaskType())
                || "OEUnit".equalsIgnoreCase(task.getTaskType())
                || "ABLUnit".equalsIgnoreCase(task.getTaskType()));
    }

    @Override
    public void taskFinished(BuildEvent event) {
        Task task = event.getTask();
        if (task == null) {
            return;
        }
        String taskName = task.getTaskType();
        if (taskName == null) {
            return;
        }
        if (isPCTTask(task)) {
            Integer i = taskCount.get(taskName.toLowerCase());
            if (i == null)
                taskCount.put(taskName.toLowerCase(), 1);
            else
                taskCount.put(taskName.toLowerCase(), i + 1);
        }
    }

    @Override
    public void buildFinished(BuildEvent event) {
        if (event.getProject().getProperty("pct.skip.analytics") != null)
            return;
        final StringBuilder sb = new StringBuilder("pct version=\"");
        sb.append(ResourceBundle.getBundle(Version.BUNDLE_NAME).getString("PCTVersion")).append('"');
        for (Entry<String, Integer> entry : taskCount.entrySet()) {
            sb.append(',').append(entry.getKey() + "=" + entry.getValue());
        }

        Callable<Void> analytics = new Callable<Void>() {
            @Override
            public Void call() throws Exception {
                try {
                    final URL url = new URL("http://sonar-analytics.rssw.eu/write?db=sonar");
                    HttpURLConnection connx = (HttpURLConnection) url.openConnection();
                    connx.setRequestMethod("POST");
                    connx.setConnectTimeout(2000);
                    connx.setDoOutput(true);
                    DataOutputStream wr = new DataOutputStream(connx.getOutputStream());
                    wr.writeBytes(sb.toString());
                    wr.flush();
                    wr.close();
                    connx.getResponseCode();
                } catch (IOException uncaught) {
                    // No-op
                }
                return null;
            }
        };

        try {
            ExecutorService executor = Executors.newSingleThreadExecutor();
            executor.invokeAll(Arrays.asList(analytics), 3, TimeUnit.SECONDS);
            executor.shutdown();
        } catch (InterruptedException uncaught) {
            // No-op
        }
    }

    @Override
    public void buildStarted(BuildEvent event) {
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
    public void messageLogged(BuildEvent event) {
        // No-op
    }

}
