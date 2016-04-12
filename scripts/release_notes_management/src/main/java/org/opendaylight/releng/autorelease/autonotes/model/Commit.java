/*
 * Copyright (c) 2016 Huawei, Inc and Others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.releng.autorelease.autonotes.model;

/**
 * A GIT commit object.
 */
public class Commit {

    private String id;
    private String url;
    private String commitId;
    private String commitText;
    private String commitLog;

    /**
     * Construct a commit object with empty string values.
     */
    public Commit() {
        this.id = "";
        this.url = "";
        this.commitId = "";
        this.commitText = "";
        this.commitLog = "";
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
     * @return the URL
     */
    public String getUrl() {
        return url;
    }

    /**
     * @param url the URL to set
     */
    public void setUrl(String url) {
        this.url = url;
    }

    /**
     * @return the commitId
     */
    public String getCommitId() {
        return commitId;
    }

    /**
     * @param commitId the commitId to set
     */
    public void setCommitId(String commitId) {
        this.commitId = commitId;
    }

    /**
     * @return the commitText
     */
    public String getCommitText() {
        return commitText;
    }

    /**
     * @param commitText the commitText to set
     */
    public void setCommitText(String commitText) {
        this.commitText = commitText;
    }

    /**
     * @return the commitLog
     */
    public String getCommitLog() {
        return commitLog;
    }

    /**
     * @param commitLog the commitLog to set
     */
    public void setCommitLog(String commitLog) {
        this.commitLog = commitLog;
    }

    @Override
    public String toString() {
        return "{ id : " + id + ", Commit Id : " + commitId + ", Commit Message : " + commitText + " }";
    }

}
