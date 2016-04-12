/*
 * Copyright (c) 2016 Huawei, Inc and Others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.releng.autorelease.autonotes.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;

import org.opendaylight.releng.autorelease.autonotes.model.Project;
import org.opendaylight.releng.autorelease.autonotes.utils.LogUtils;

/**
 * GIT service.
 */
public class GitService implements Service {

    /**
     * Configuration property for command script
     */
    public static final String COMMAND_SCRIPT = "org.opendaylight.releng.autorelease.autonotes.git.script";

    /**
     * Configuration property for command branch
     */
    public static final String COMMAND_BRANCH = "org.opendaylight.releng.autorelease.autonotes.git.branch";

    /**
     * Configuration property for command range
     */
    public static final String COMMAND_RANGE = "org.opendaylight.releng.autorelease.autonotes.git.range";

    /**
     * Reference to controller.
     */
    private ServiceController controller;

    /**
     * Constructs GIT service
     * @param controller the controller
     */
    public GitService(ServiceController controller) {
        this.controller = controller;
    }

    /**
     * Loads GIT repositories.
     */
    public void execute() {
        LogUtils.step("Begin cloning all projects");
        String commandScript = this.controller.getPropertyService().getProperties().getProperty(COMMAND_SCRIPT);
        String commandBranch = this.controller.getPropertyService().getProperties().getProperty(COMMAND_BRANCH);
        String commandRange = this.controller.getPropertyService().getProperties().getProperty(COMMAND_RANGE);
        for (Project project : this.controller.getProjectService().getActiveProjects()) {
            String command = commandScript + " " + project.getShortpath() + " " + project.getLongpath() + " " + commandBranch + " " + commandRange;
            run(command);
        }
        LogUtils.step("Completed cloning all projects");
    }

    /**
     * Execute command as a separate process
     * @param command The command to run
     */
    private void run(String command) {
        Process process = null;
        BufferedReader stream = null;
        String line;
        try {
            LogUtils.step(command);
            process = Runtime.getRuntime().exec(command);
            stream = new BufferedReader(new InputStreamReader(process.getInputStream()));
            while ((line = stream.readLine()) != null) {
                LogUtils.step(line);
            }
            process.waitFor();
            LogUtils.step("Exit: " + process.exitValue());
        } catch (Exception e) {
            LogUtils.log(e);
        } finally {
            if (stream != null) {
                try {
                    stream.close();
                } catch (Exception e) {
                    LogUtils.log(e);
                }
            }
            if (process != null) {
                try {
                    process.destroy();
                } catch (Exception e) {
                    LogUtils.log(e);
                }
            }
        }
    }

}
