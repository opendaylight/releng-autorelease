/*
 * Copyright (c) 2016 Huawei, Inc and Others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.releng.autorelease.autonotes.service;

/**
 * Controller for all services.
 */
public interface ServiceController {

    /**
     * Returns property service.
     * @return property service.
     */

    public PropertyService getPropertyService();

    /**
     * Returns project service.
     * @return project service.
     */
    public ProjectService getProjectService();

    /**
     * Returns GIT service.
     * @return GIT service.
     */
    public GitService getGitService();

    /**
     * Returns commit service.
     * @return commit service.
     */
    public CommitService getCommitService();

    /**
     * Returns filter service.
     * @return filter service.
     */
    public FilterService getFilterService();

    /**
     * Returns release service.
     * @return release service.
     */
    public ReleaseService getReleaseService();

    /**
     * Returns WIKI service.
     * @return WIKI service.
     */
    public WikiService getWikiService();

    /**
     * Returns ADOC service.
     * @return ADOC service.
     */
    public AdocService getAdocService();

    /**
     * Returns RST service.
     * @return RST service.
     */
    public RstService getRstService();

}
