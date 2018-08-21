package za.co.mip.ablduck.models;

import java.util.List;

import com.google.gson.annotations.Expose;

public class Member {
    @Expose
    public String id;
    
    @Expose
    public String name;
   
    @Expose
    public String owner;
    
    @Expose
    public String tagname;

    @Expose
    public String datatype;
    
    @Expose
    public String definition;
    
    @Expose
    public String comment;
    
    @Expose
    public List<Parameter> parameters;
    
    @Expose
    public Return returns;
    
    @Expose
    public Meta meta = new Meta();
}
