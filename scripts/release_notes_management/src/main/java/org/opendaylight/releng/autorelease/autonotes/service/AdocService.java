/*
 * Copyright (c) 2016 Company and Others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.releng.autorelease.autonotes.service;

import java.io.File;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.io.FileUtils;
import org.opendaylight.releng.autorelease.autonotes.model.Commit;
import org.opendaylight.releng.autorelease.autonotes.model.Release;
import org.opendaylight.releng.autorelease.autonotes.model.ReleaseProject;
import org.opendaylight.releng.autorelease.autonotes.utils.LogUtils;

/**
 * Provides ADOC service.
 */
public class AdocService implements Service {

    /**
     * Configuration property for bug regular expression
     */
    public static final String NICKNAME = "org.opendaylight.releng.autorelease.autonotes.release.nickname";

    /**
     * Configuration property for bug regular expression
     */
    public static final String PREVIOUS = "org.opendaylight.releng.autorelease.autonotes.release.previous";

    /**
     * Configuration property for bug regular expression
     */
    public static final String CURRENT = "org.opendaylight.releng.autorelease.autonotes.release.current";

    /**
     * Configuration property for bug regular expression
     */
    public static final String HEADER = "org.opendaylight.releng.autorelease.autonotes.adoc.header";

    /**
     * Configuration property for bug placeholder tag
     */
    public static final String BUG_TAG = "org.opendaylight.releng.autorelease.autonotes.commit.bug.tag";

    /**
     * Configuration property for Bug Tracking URL
     */
    public static final String BUG_URL = "org.opendaylight.releng.autorelease.autonotes.commit.bug";

    /**
     * Configuration property for Bug Tracking URL
     */
    public static final String ADOC_FILE = "org.opendaylight.releng.autorelease.autonotes.adoc.file";

    /**
     * Reference to controller.
     */
    private ServiceController controller;

    /**
     * Constructs ADOC service
     * @param controller the controller
     */
    public AdocService(ServiceController controller) {
        this.controller = controller;
    }

    /**
     * Load ADOC content.
     */
    public void execute() {
        LogUtils.step("Start loading adoc");
        try {
            StringBuilder builder = new StringBuilder();
            String header = this.controller.getPropertyService().getProperties().getProperty(HEADER);
            header = header.replace("#####NICKNAME", this.controller.getPropertyService().getProperties().getProperty(NICKNAME));
            header = header.replace("#####PREVIOUS", this.controller.getPropertyService().getProperties().getProperty(PREVIOUS));
            header = header.replace("#####CURRENT", this.controller.getPropertyService().getProperties().getProperty(CURRENT));
            builder.append(header + "\n\n");
            Release release = this.controller.getReleaseService().getRelease();
            for (ReleaseProject releaseProject : release.getUnchangedProjects()) {
                builder.append("* " + releaseProject.getProject().getName() + "\n");
            }
            builder.append("\n");
            for (ReleaseProject releaseProject : release.getChangedProjects()) {
                builder.append("==== " + releaseProject.getProject().getName() + "\n");
                for (Commit commit : releaseProject.getCommits()) {
                    Pattern replace = Pattern.compile(this.controller.getPropertyService().getProperties().getProperty(BUG_TAG) + "([0-9]{4})");
                    Matcher matcher = replace.matcher(commit.getCommitText());
                    String commitText = matcher.replaceAll(this.controller.getPropertyService().getProperties().getProperty(BUG_URL) + "$1[BUG-$1]");
                    String commitAdoc = "* " + commit.getUrl() + "[" + commit.getId() + "] " + commitText + "\n";
                    builder.append(commitAdoc);
                    LogUtils.step("Adoc: " + commitAdoc);
                }
                builder.append("\n");
            }
            String adoc = builder.toString();
            File file = new File(this.controller.getPropertyService().getProperties().getProperty(ADOC_FILE));
            FileUtils.writeStringToFile(file, adoc);
        } catch (Exception e) {
            LogUtils.log(e);
        }
        LogUtils.step("Completed loading adoc");
    }

}
