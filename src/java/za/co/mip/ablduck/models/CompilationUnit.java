package za.co.mip.ablduck.models;

import java.util.List;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class CompilationUnit {
    @Expose
    public List<String> files;
    
    @Expose
    public List<String> uses;
    
    @Expose
    public String id;
    
    @Expose
    public String tagname;

    @Expose
    public String name;

    @Expose
    @SerializedName("extends")
    public String inherits;
    
    @Expose
    public String author;
    
    @Expose
    public String comment;
    
    @Expose
    public String icon;
    
    @Expose
    public List<String> superclasses;
    
    @Expose
    public List<String> subclasses;
    
    @Expose
    @SerializedName("implements")
    public List<String> implementations;
    
    @Expose
    public List<String> implementers;
    
    @Expose
    public List<Member> members;
    
    @Expose
    public Meta meta = new Meta();
}
