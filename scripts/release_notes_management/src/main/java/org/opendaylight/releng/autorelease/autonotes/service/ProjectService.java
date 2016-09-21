/*
 * Copyright (c) 2016 Huawei, Inc and Others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.releng.autorelease.autonotes.service;

import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.commons.io.IOUtils;
import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.json.JSONObject;
import org.opendaylight.releng.autorelease.autonotes.model.Project;
import org.opendaylight.releng.autorelease.autonotes.utils.LogUtils;

/**
 * Project Service
 */
public class ProjectService {

    /**
     * Configuration property for all projects
     */
    public static final String ALL_PROJECT_LIST = "org.opendaylight.releng.autorelease.autonotes.governance.projects";

    /**
     * Configuration property for all notes
     */
    public static final String ALL_RELEASE_NOTES = "org.opendaylight.releng.autorelease.autonotes.governance.notes";

    /**
     * Configuration property for active project
     */
    public static final String ACTIVE_PROJECT_LIST = "org.opendaylight.releng.autorelease.autonotes.projects.list";

    /**
     * Reference to controller.
     */
    private ServiceController controller;

    /**
     * List of projects.
     */
    private Map<String, Project> projects;

    /**
     * Constructs project list service
     * @param controller the controller
     */
    public ProjectService(ServiceController controller) {
        this.controller = controller;
        this.projects = new HashMap<String, Project>();
    }

    /**
     * Loads projects.
     */
    public void execute() {
        LogUtils.step("Start loading projects");
        loadGovernance();
        loadNotes();
        loadStates();
        for (Entry<String, Project> entry : this.projects.entrySet()) {
            if (entry != null && entry.getKey() != null && entry.getValue() != null) {
                LogUtils.step(entry.getKey() + ": " + entry.getValue().toString());
            }
        }
        LogUtils.step("Completed loading project");
    }

    /**
     * Load all projects based on governance
     */
    private void loadGovernance() {
        LogUtils.step("Start loading project goveranance");
        InputStream input = null;
        try {
            input = new URL(this.controller.getPropertyService().getProperties().getProperty(ALL_PROJECT_LIST)).openStream();
            String projectsString = IOUtils.toString(input);
            LogUtils.log(projectsString);
            JSONObject projectsJSON = new JSONObject(projectsString);
            for (String projectId : JSONObject.getNames(projectsJSON)) {
                Project project = new Project();
                project.setId(projectId);
                String[] projectpathArray = projectId.split("/");
                if (projectpathArray.length > 0) {
                    project.setShortpath(projectpathArray[projectpathArray.length - 1]);
                } else {
                    project.setShortpath(projectId);
                }
                project.setLongpath(projectId);
                project.setName(projectsJSON.getString(projectId));
                this.projects.put(projectId, project);
            }
        } catch (Exception e) {
            LogUtils.log(e);
        } finally {
            if (input != null) {
                try {
                    IOUtils.closeQuietly(input);
                } catch (Exception e) {
                    LogUtils.log(e);
                }
            }
        }
        LogUtils.step("Completed loading project goveranance");
    }

    /**
     * Load all project release notes
     */
    private void loadNotes() {
        LogUtils.step("Start loading project notes");
        InputStream input = null;
        try {
            input = new URL(this.controller.getPropertyService().getProperties().getProperty(ALL_RELEASE_NOTES)).openStream();
            String projectsString = IOUtils.toString(input);
            LogUtils.log(projectsString);
            JSONObject projectsJSON = new JSONObject(projectsString);
            for (String projectId : JSONObject.getNames(projectsJSON)) {
                Project project = this.projects.get(projectId);
                project.setNote(projectsJSON.getString(projectId));
            }
        } catch (Exception e) {
            LogUtils.log(e);
        } finally {
            if (input != null) {
                try {
                    IOUtils.closeQuietly(input);
                } catch (Exception e) {
                    LogUtils.log(e);
                }
            }
        }
        LogUtils.step("Completed loading project notes");
    }

    /**
     * Load the project active state based on inclusion in auto-release
     */
    @SuppressWarnings("rawtypes")
    private void loadStates() {
        LogUtils.step("Start loading project state");
        InputStream input = null;
        try {
            input = new URL(this.controller.getPropertyService().getProperties().getProperty(ACTIVE_PROJECT_LIST)).openStream();
            String activeProjectString = IOUtils.toString(input);

            Document document = DocumentHelper.parseText(activeProjectString);
            Element root = document.getRootElement();
            Element modules = root.element("modules");
            for (Iterator i = modules.elementIterator("module"); i.hasNext();) {
                Element module = (Element) i.next();
                String projectName = module.getText();
                this.projects.get(projectName).setActive(true);
            }
        } catch (Exception e) {
            LogUtils.log(e);
        } finally {
            if (input != null) {
                try {
                    IOUtils.closeQuietly(input);
                } catch (Exception e) {
                    LogUtils.log(e);
                }
            }
        }
        LogUtils.step("Completed loading project state");
    }

    /**
     * Returns all projects
     * @return all projects
     */
    public List<Project> getAllProjects() {
        List<Project> allProjects = new ArrayList<Project>();
        for (Project project : this.projects.values()) {
            allProjects.add(project);
        }
        Collections.sort(allProjects);
        return allProjects;
    }

    /**
     * Returns active projects.
     * @return active projects.
     */
    public List<Project> getActiveProjects() {
        List<Project> activeProjects = new ArrayList<Project>();
        for (Project project : this.projects.values()) {
            if (project.isActive()) {
                activeProjects.add(project);
            }
        }
        Collections.sort(activeProjects);
        return activeProjects;
    }

}
