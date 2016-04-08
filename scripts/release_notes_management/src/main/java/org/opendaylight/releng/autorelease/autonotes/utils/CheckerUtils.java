/*
 * Copyright (c) 2016 Company and Others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.releng.autorelease.autonotes.utils;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;

public class CheckerUtils {

    public static final List<String> toStringList(JSONArray json) throws JSONException {
        if (json != null) {
            List<String> strings = new ArrayList<String>();
            for (int i = 0; i < json.length(); i++) {
                strings.add(json.getString(i));
            }
            return strings;
        }
        return null;
    }

	public static List<Integer> toIntegerList(JSONArray json) throws JSONException {
		if (json != null) {
            List<Integer> strings = new ArrayList<Integer>();
            for (int i = 0; i < json.length(); i++) {
                strings.add(Integer.valueOf(json.getInt(i)));
            }
            return strings;
        }
        return null;
	}

}
