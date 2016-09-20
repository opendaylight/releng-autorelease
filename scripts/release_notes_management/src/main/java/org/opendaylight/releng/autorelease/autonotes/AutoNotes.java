/*
 * Copyright (c) 2016 Huawei, Inc and Others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.releng.autorelease.autonotes;

import org.opendaylight.releng.autorelease.autonotes.service.AdocService;
import org.opendaylight.releng.autorelease.autonotes.service.CommitService;
import org.opendaylight.releng.autorelease.autonotes.service.FilterService;
import org.opendaylight.releng.autorelease.autonotes.service.GitService;
import org.opendaylight.releng.autorelease.autonotes.service.NoteService;
import org.opendaylight.releng.autorelease.autonotes.service.ProjectService;
import org.opendaylight.releng.autorelease.autonotes.service.PropertyService;
import org.opendaylight.releng.autorelease.autonotes.service.ReleaseService;
import org.opendaylight.releng.autorelease.autonotes.service.RstService;
import org.opendaylight.releng.autorelease.autonotes.service.ServiceController;
import org.opendaylight.releng.autorelease.autonotes.service.WikiService;
import org.opendaylight.releng.autorelease.autonotes.utils.LogUtils;

/**
 * Automatic generation of OpenDaylight release notes.
 */
public class AutoNotes implements ServiceController {

    /**
     * Default location of the application properties file.
     */
    public static final String DEFAULT_CONFIGURATION_FILEPATH = "conf/application.properties";

    /**
     * The property service.
     */
    private PropertyService propertyService;

    /**
     * The project service.
     */
    private ProjectService projectService;

    /**
     * The GIT service.
     */
    private GitService gitService;

    /**
     * The commit service.
     */
    private CommitService commitService;

    /**
     * The filter service.
     */
    private FilterService filterService;

    /**
     * The release service.
     */
    private ReleaseService releaseService;

    /**
     * The WIKI service.
     */
    private WikiService wikiService;

    /**
     * The ADOC service.
     */
    private AdocService adocService;

    /**
     * The RST service.
     */
    private RstService rstService;

    /**
     * The note service.
     */
    private NoteService noteService;

    /**
     * Constructs the AutoNotes Application
     * @param args configuration parameters
     */
    public AutoNotes(String[] args) {
        this.propertyService = new PropertyService(DEFAULT_CONFIGURATION_FILEPATH);
        this.projectService = new ProjectService(this);
        this.gitService = new GitService(this);
        this.commitService = new CommitService(this);
        this.filterService = new FilterService(this);
        this.releaseService = new ReleaseService(this);
        this.wikiService = new WikiService(this);
        this.adocService = new AdocService(this);
        this.rstService = new RstService(this);
        this.noteService = new NoteService(this);
    }

    @Override
    public PropertyService getPropertyService() {
        return propertyService;
    }

    @Override
    public ProjectService getProjectService() {
        return projectService;
    }

    @Override
    public GitService getGitService() {
        return gitService;
    }

    @Override
    public CommitService getCommitService() {
        return commitService;
    }

    @Override
    public FilterService getFilterService() {
        return filterService;
    }

    @Override
    public ReleaseService getReleaseService() {
        return releaseService;
    }

    @Override
    public WikiService getWikiService() {
        return wikiService;
    }

    @Override
    public AdocService getAdocService() {
        return adocService;
    }

    @Override
    public RstService getRstService() {
        return rstService;
    }

    @Override
    public NoteService getNoteService() {
        return noteService;
    }

    /**
     * Generates the OpenDaylight release notes.
     * @return exit status
     */
    private int execute() {
        this.projectService.execute();
        this.gitService.execute();
        this.commitService.execute();
        this.filterService.execute();
        this.releaseService.execute();
        this.wikiService.execute();
        this.adocService.execute();
        this.rstService.execute();
        this.noteService.execute();
        return 0;
    }

    public static void main(String[] args) {
        LogUtils.step("Begin AutoNotes Application");
        AutoNotes application = new AutoNotes(args);
        int failed = application.execute();
        LogUtils.step("Exit: " + failed);
        LogUtils.step("Completed AutoNotes Application");
        System.exit(failed > 0 ? 1 : 0);
    }

}
