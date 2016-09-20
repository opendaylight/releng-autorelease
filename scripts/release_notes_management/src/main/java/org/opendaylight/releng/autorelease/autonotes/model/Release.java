/*
 * Copyright (c) 2016 Huawei, Inc and Others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.releng.autorelease.autonotes.model;

import java.util.List;

/**
 * A release of changed and unchanged active projects.
 */
public class Release {

    /**
     * List of all active in release.
     */
    private List<ReleaseProject> activeProjects;

	/**
     * List of active projects with at last one commit.
     */
    private List<ReleaseProject> changedProjects;

    /**
     * List of active projects without any commits.
     */
    private List<ReleaseProject> unchangedProjects;

    /**
     * Constructs a release object.
     */
    public Release() {
        this.activeProjects = null;
        this.changedProjects = null;
        this.unchangedProjects = null;
    }

    /**
     * @return the activeProjects
     */
    public List<ReleaseProject> getActiveProjects() {
        return activeProjects;
    }

    /**
     * @param activeProjects the activeProjects to set
     */
    public void setActiveProjects(List<ReleaseProject> activeProjects) {
        this.activeProjects = activeProjects;
    }

    /**
     * @return the changedProjects
     */
    public List<ReleaseProject> getChangedProjects() {
        return changedProjects;
    }

    /**
     * @param changedProjects the changedProjects to set
     */
    public void setChangedProjects(List<ReleaseProject> changedProjects) {
        this.changedProjects = changedProjects;
    }

    /**
     * @return the unchangedProjects
     */
    public List<ReleaseProject> getUnchangedProjects() {
        return unchangedProjects;
    }

    /**
     * @param unchangedProjects the unchangedProjects to set
     */
    public void setUnchangedProjects(List<ReleaseProject> unchangedProjects) {
        this.unchangedProjects = unchangedProjects;
    }

}
