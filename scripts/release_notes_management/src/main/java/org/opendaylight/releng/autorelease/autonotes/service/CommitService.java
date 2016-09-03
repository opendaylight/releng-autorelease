/*
 * Copyright (c) 2016 Huawei, Inc and Others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.releng.autorelease.autonotes.service;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.io.FileUtils;
import org.opendaylight.releng.autorelease.autonotes.model.Commit;
import org.opendaylight.releng.autorelease.autonotes.utils.LogUtils;

/**
 * Provides commit services.
 */
public class CommitService implements Service {

    /**
     * Configuration property for log URL
     */
    public static final String LOG_URL = "org.opendaylight.releng.autorelease.autonotes.commit.log";

    /**
     * Configuration property for GIT Patch Tracking URL
     */
    public static final String GIT_URL = "org.opendaylight.releng.autorelease.autonotes.commit.git";

    /**
     * Configuration property for Bug Tracking URL
     */
    public static final String BUG_URL = "org.opendaylight.releng.autorelease.autonotes.commit.bug";

    /**
     * Configuration property for bug placeholder tag
     */
    public static final String BUG_TAG = "org.opendaylight.releng.autorelease.autonotes.commit.bug.tag";

    /**
     * Configuration property for bug regular expression
     */
    public static final String BUG_REGEX = "org.opendaylight.releng.autorelease.autonotes.commit.bug.regex";

    /**
     * Reference to controller.
     */
    private ServiceController controller;

    /**
     * Mapping from project to list of commits.
     */
    private Map<String, List<Commit>> commits;

    /**
     * Constructs commit service
     * @param controller the controller
     */
    public CommitService(ServiceController controller) {
        this.controller = controller;
        this.commits = new HashMap<String, List<Commit>>();
    }

    /**
     * A GIT commit object.
     * 
     * For a particular log message, a commit object is 
     * generated according to the template
     * [COMMIT_URL COMMIT_ID] [BUG_URL BUG_ID]: COMMIT_MESSAGE
     * For example:
     * 7051ce0472f86e78d859a32252d7c2fa5f797558 Bug 4839: Reduce unnecessary barrier request on remove-flow RPC call.
     * [https://git.opendaylight.org/gerrit/#/q/7051ce0472f86e78d859a32252d7c2fa5f797558 7051ce] [https://bugs.opendaylight.org/show_bug.cgi?id=4839 BUG-4839]: Reduce unnecessary barrier request on remove-flow RPC call.
     */
    public void execute() {
        LogUtils.step("Start loading commits");
        try {
            File log = new File(this.controller.getPropertyService().getProperties().getProperty(LOG_URL));
            List<String> lines = FileUtils.readLines(log);
            String projectCursor = "";
            for (int i = 0; i < lines.size(); i++) {
                String line = lines.get(i);
                if (line.startsWith("#####")) {
                    projectCursor = line.replace("#####", "");
                    this.commits.put(projectCursor, new ArrayList<Commit>());
                    LogUtils.step("Project: " + projectCursor);
                    continue;
                } else {
                    loadCommit(projectCursor, line);
                }
            }
        } catch (IOException e) {
            LogUtils.log(e);
        }
        LogUtils.step("Completed loading commits");
    }

    private void loadCommit(String project, String line) {
        Commit commit = new Commit();
        commit.setCommitId(this.getCommitId(line));
        commit.setId(this.getId(commit.getCommitId()));
        commit.setUrl(this.getUrl(commit.getCommitId()));
        commit.setCommitText(getBugExtractedCommitText(getCommitText(line)));
        commit.setCommitLog(line);
        this.commits.get(project).add(commit);
        LogUtils.step("Commit: " + commit.toString());
    }

    private String getCommitId(String line) {
        if (line != null) {
            String[] array = line.split(" ");
            if (array.length >= 1) {
                return array[0];
            }
        }
        return null;
    }

    private String getId(String commitId) {
        if (commitId.length() >= 6) {
            return commitId.substring(0, 6);
        }
        return null;
    }

    private String getUrl(String commitId) {
        return this.controller.getPropertyService().getProperties().getProperty(GIT_URL) + commitId;
    }

    private String getCommitText(String line) {
        if (line != null) {
            int index = line.indexOf(" ") + 1;
            if (index > -1 && index < line.length()) {
                return line.substring(index, line.length());
            }
        }
        return null;
    }

    private String getBugExtractedCommitText(String commitText) {
        Pattern pattern = Pattern.compile(this.controller.getPropertyService().getProperties().getProperty(BUG_REGEX));
        Matcher replacer = pattern.matcher(commitText);
        return replacer.replaceAll(this.controller.getPropertyService().getProperties().getProperty(BUG_TAG) + "$2");
    }

    public Map<String, List<Commit>> getCommits() {
        return this.commits;
    }

}
