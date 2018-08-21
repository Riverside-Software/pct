package za.co.mip.ablduck.models;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Meta {
    @Expose
    @SerializedName("private")
    public Boolean isPrivate = null;

    @Expose
    @SerializedName("protected")
    public Boolean isProtected = null;

    @Expose
    @SerializedName("static")
    public Boolean isStatic = null;

    @Expose
    @SerializedName("abstract")
    public Boolean isAbstract = null;

    @Expose
    @SerializedName("override")
    public Boolean isOverride = null;
    
    @Expose
    @SerializedName("final")
    public Boolean isFinal = null;
    
    @Expose
    @SerializedName("super")
    public Boolean isSuper = null;
    
    @Expose
    @SerializedName("new")
    public Boolean isNew = null;
    
    @Expose
    @SerializedName("global")
    public Boolean isGlobal = null;
    
    @Expose
    @SerializedName("shared")
    public Boolean isShared = null;
    
    @Expose
    @SerializedName("noundo")
    public Boolean isNoUndo = null;
    
    @Expose
    @SerializedName("internal")
    public Boolean isInternal = null;
    
    @Expose
    @SerializedName("deprecated")
    public Deprecated isDeprecated;
}
