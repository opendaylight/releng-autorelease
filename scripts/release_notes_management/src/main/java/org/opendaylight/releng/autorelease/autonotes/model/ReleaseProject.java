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
 * A project and properties for a specific release
 */
public class ReleaseProject {

    /**
     * The project.
     */
    private Project project;

    /**
     * The list of commits.
     */
    private List<Commit> commits;

    /**
     * Constructs a release project object.
     */
    public ReleaseProject() {
        this.project = null;
        this.commits = null;
    }

    /**
     * @return the project
     */
    public Project getProject() {
        return project;
    }

    /**
     * @param project the project to set
     */
    public void setProject(Project project) {
        this.project = project;
    }

    /**
     * @return the commits
     */
    public List<Commit> getCommits() {
        return commits;
    }

    /**
     * @param commits the commits to set
     */
    public void setCommits(List<Commit> commits) {
        this.commits = commits;
    }

}
