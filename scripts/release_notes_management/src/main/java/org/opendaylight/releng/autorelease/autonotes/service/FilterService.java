/*
 * Copyright (c) 2016 Huawei, Inc and Others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.releng.autorelease.autonotes.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.opendaylight.releng.autorelease.autonotes.model.Commit;

/**
 * Filter service
 */
public class FilterService implements Service {

    /**
     * Configuration property for filters
     */
    public static final String KEYPHRASES = "org.opendaylight.releng.autorelease.autonotes.filter.keyphrases";

    /**
     * Reference to controller.
     */
    private ServiceController controller;

    /**
     * The filters.
     */
    private List<String> filters;

    /**
     * Constructs filter service
     * @param controller the controller
     */
    public FilterService(ServiceController controller) {
        this.controller = controller;
        this.filters = new ArrayList<String>();
    }

    /**
     * Load filters
     */
    public void execute() {
        String keyphrasesString = this.controller.getPropertyService().getProperties().getProperty(KEYPHRASES);
        String[] keyphrasesArray = keyphrasesString.split(",");
        for (String keyphrase : keyphrasesArray) {
            this.filters.add(keyphrase);
        }
    }

    /**
     * Filter the commits for dropped key phrases
     * @param input the original set of commits
     * @return the filtered set of commits
     */
    public Map<String, List<Commit>> filter(Map<String, List<Commit>> input) {
        Map<String, List<Commit>> output = new HashMap<String, List<Commit>>();
        for (Entry<String, List<Commit>> entry : input.entrySet()) {
            List<Commit> filtered = new ArrayList<Commit>();
            for (Commit commit : entry.getValue()) {
                if (commit.getCommitText() != null) {
                    boolean drop = false;
                    for (String filter : this.filters) {
                        if (commit.getCommitText().startsWith(filter)) {
                            drop = true;
                        }
                    }
                    if (!drop) {
                        filtered.add(commit);
                    }
                }
            }
            output.put(entry.getKey(), filtered);
        }
        return output;
    }

}
