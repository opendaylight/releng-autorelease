/*
 * Copyright (c) 2016 Huawei, Inc and Others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.releng.autorelease.autonotes.utils;

public class LogUtils {

    public static final boolean DEBUG = true;
    public static final boolean EXIT = false;

    public static final void log(Object o) {
        if (DEBUG) {
            if (o instanceof Exception) {
                ((Exception) o).printStackTrace();
            } else if (o != null) {
                System.out.println(o);
            }
        }
    }

    public static final void step(Object o) {
        if (DEBUG) {
            if (o instanceof Exception) {
                ((Exception) o).printStackTrace();
            } else if (o != null) {
                System.out.println(o);
                if (EXIT)
                    System.exit(0);
            }
        }
    }

}
