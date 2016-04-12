/*
 * Copyright (c) 2016 Huawei, Inc and Others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.releng.autorelease.autonotes.service;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.opendaylight.releng.autorelease.autonotes.utils.LogUtils;

/**
 * Provides property services.
 */
public class PropertyService implements Service {

    /**
     * Stores properties
     */
    private Properties properties = new Properties();

    /**
     * Constructs property service with properties loaded from file.
     * @param filepath the file path
     */
    public PropertyService(String filepath) {
        LogUtils.step("Start initializing properties");
        InputStream input = null;
        try {
            input = new FileInputStream(filepath);
            this.properties = new Properties();
            properties.load(input);
        } catch (IOException e) {
            LogUtils.log(e);
        } finally {
            if (input != null) {
                try {
                    input.close();
                } catch (IOException e) {
                    LogUtils.log(e);
                }
            }
        }
        LogUtils.step("Properties:");
        LogUtils.step(this.properties);
        LogUtils.step("Completed initializing properties");
    }

    /**
     * Returns properties
     * @return properties
     */
    public Properties getProperties() {
        return properties;
    }

}
