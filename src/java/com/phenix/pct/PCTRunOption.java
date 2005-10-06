package com.phenix.pct;

/**
 * Optional command-line option
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @version $Revision$
 */
public class PCTRunOption {
    String name = null;
    String value = null;

    public void setName(String name) {
        this.name = name;
    }
    
    public void setValue(String value) {
        this.value = value;
    }

    public String getName() {
        return this.name;
    }
    
    public String getValue() {
        return this.value;
    }
}