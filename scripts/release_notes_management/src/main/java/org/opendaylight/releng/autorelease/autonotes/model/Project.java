/*
 * Copyright (c) 2016 Huawei, Inc and Others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.releng.autorelease.autonotes.model;


/**
 * A project and properties.
 */
public class Project implements Comparable<Project> {

    /**
     * The project id.
     */
    private String id;

    /**
     * The project short path.
     */
    private String shortpath;

    /**
     * The project long path.
     */
    private String longpath;

    /**
     * The project name.
     */
    private String name;

    /**
     * The project active state.
     */
    private boolean active;

    /**
     * The project release notes.
     */
    private String note;

    /**
     * Constructs a project object.
     */
    public Project() {
        this.id = "";
        this.shortpath = "";
        this.longpath = "";
        this.name = "";
        this.active = false;
        this.note = "";
    }

    /**
     * @return the id
     */
    public String getId() {
        return id;
    }

    /**
     * @param id the id to set
     */
    public void setId(String id) {
        this.id = id;
    }

    /**
     * @return the short path
     */
    public String getShortpath() {
        return shortpath;
    }

    /**
     * @param shortpath the short path to set
     */
    public void setShortpath(String shortpath) {
        this.shortpath = shortpath;
    }

    /**
     * @return the long path
     */
    public String getLongpath() {
        return longpath;
    }

    /**
     * @param longpath the long path to set
     */
    public void setLongpath(String longpath) {
        this.longpath = longpath;
    }

    /**
     * @return the name
     */
    public String getName() {
        return name;
    }

    /**
     * @param name the name to set
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * @return the active
     */
    public boolean isActive() {
        return active;
    }

    /**
     * @param active the active to set
     */
    public void setActive(boolean active) {
        this.active = active;
    }

    /**
     * @return the note
     */
    public String getNote() {
        return note;
    }

    /**
     * @param note the note to set
     */
    public void setNote(String note) {
        this.note = note;
    }

    @Override
    public int compareTo(Project p) {
        if (p != null) {
            if (this.name != null) {
                return this.name.compareTo(p.getName());
            }
        }
        return 0;
    }

    @Override
    public String toString() {
        return "{ id : " + id + ", name : " + name + ", active : " + active + ", note : " + note + " }";
    }

}
