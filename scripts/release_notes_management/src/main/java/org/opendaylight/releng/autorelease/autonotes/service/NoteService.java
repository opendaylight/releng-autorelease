/*
 * Copyright (c) 2016 Huawei, Inc and Others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.releng.autorelease.autonotes.service;

import java.io.File;

import org.apache.commons.io.FileUtils;
import org.opendaylight.releng.autorelease.autonotes.model.Release;
import org.opendaylight.releng.autorelease.autonotes.model.ReleaseProject;
import org.opendaylight.releng.autorelease.autonotes.utils.LogUtils;

/**
 * Provides note service.
 */
public class NoteService implements Service {

    /**
     * Configuration property for rst notes header
     */
    public static final String RST_NOTES_HEADER = "org.opendaylight.releng.autorelease.autonotes.rst.notes.header";

    /**
     * Configuration property for rst notes file
     */
    public static final String RST_NOTES_FILE = "org.opendaylight.releng.autorelease.autonotes.rst.notes.file";

    /**
     * Reference to controller.
     */
    private ServiceController controller;

    /**
     * Constructs note service
     * @param controller the controller
     */
    public NoteService(ServiceController controller) {
        this.controller = controller;
    }

    /**
     * Load notes content.
     */
    public void execute() {
        LogUtils.step("Start loading notes");
        try {
            StringBuilder builder = new StringBuilder();
            String header = this.controller.getPropertyService().getProperties().getProperty(RST_NOTES_HEADER);
            builder.append(header + "\n\n");
            Release release = this.controller.getReleaseService().getRelease();
            for (ReleaseProject releaseProject : release.getActiveProjects()) {
                builder.append("* `" + releaseProject.getProject().getName() + " <" + releaseProject.getProject().getNote() + ">`_\n");
            }
            builder.append("\n");
            
            String adoc = builder.toString();
            File file = new File(this.controller.getPropertyService().getProperties().getProperty(RST_NOTES_FILE));
            FileUtils.writeStringToFile(file, adoc);
        } catch (Exception e) {
            LogUtils.log(e);
        }
        LogUtils.step("Completed loading notes");
    }

}
