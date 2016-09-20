/*
 * Copyright (c) 2016 Huawei, Inc and Others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.releng.autorelease.autonotes.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.opendaylight.releng.autorelease.autonotes.model.Commit;
import org.opendaylight.releng.autorelease.autonotes.model.Project;
import org.opendaylight.releng.autorelease.autonotes.model.Release;
import org.opendaylight.releng.autorelease.autonotes.model.ReleaseProject;
import org.opendaylight.releng.autorelease.autonotes.utils.LogUtils;

/**
 * Release service
 */
public class ReleaseService implements Service {

    /**
     * Reference to controller.
     */
    private ServiceController controller;

    /**
     * The release of projects.
     */
    private Release release;

    /**
     * Constructs release service
     * @param controller the controller
     */
    public ReleaseService(ServiceController controller) {
        this.controller = controller;
        this.release = new Release();
    }

    /**
     * Load release.
     */
    public void execute() {
        LogUtils.step("Start loading release");
        this.release.setActiveProjects(new ArrayList<ReleaseProject>());
        this.release.setChangedProjects(new ArrayList<ReleaseProject>());
        this.release.setUnchangedProjects(new ArrayList<ReleaseProject>());
        Map<String, List<Commit>> original = this.controller.getCommitService().getCommits();
        Map<String, List<Commit>> commits = this.controller.getFilterService().filter(original);
        for (Project project : this.controller.getProjectService().getActiveProjects()) {
            ReleaseProject releaseProject = new ReleaseProject();
            releaseProject.setCommits(commits.get(project.getId()));
            releaseProject.setProject(project);
            this.release.getActiveProjects().add(releaseProject);
            if (releaseProject.getCommits().size() > 0) {
                this.release.getChangedProjects().add(releaseProject);
                LogUtils.step("Add Changed Project: " + project.toString());
            } else {
                this.release.getUnchangedProjects().add(releaseProject);
                LogUtils.step("Add Unchanged Project: " + project.toString());
            }
        }
        LogUtils.step("Completed loading release");
    }

    /**
     * Returns release
     * @return release
     */
    public Release getRelease() {
        return this.release;
    }

}
