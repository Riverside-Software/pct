package com.phenix.pct;

public class Pattern {
    private String name = null;
    private boolean include = true;
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getName() {
        return this.name;
    }
    
    // Use this method to declare an Include node
    public void setInclude(boolean include) {
        this.include = include;
    }
    
    public boolean isInclude() {
        return this.include;
    }
}
