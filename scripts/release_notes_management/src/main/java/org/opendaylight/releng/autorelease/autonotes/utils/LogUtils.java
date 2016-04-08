package org.opendaylight.releng.autorelease.autonotes.utils;

public class LogUtils {

    public static final boolean DEBUG = true;
    public static final boolean EXIT = true;
	public static final void log(Object o) {
        if (DEBUG) {
            if (o instanceof Exception) {
                ((Exception) o).printStackTrace();
            } else if (o != null){
                System.out.println(o);
            }
        }
    }	
	public static final void step(Object o) {
	    if (DEBUG) {
	        if (o instanceof Exception) {
	            ((Exception) o).printStackTrace();
	        } else if (o != null){
	            System.out.println(o);
	            if (EXIT) System.exit(0);
	        }
	    }
    }
}
