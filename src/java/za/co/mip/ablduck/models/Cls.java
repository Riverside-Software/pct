package za.co.mip.ablduck.models;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Cls {
    @Expose
    public String name = "";

    @Expose
    @SerializedName("extends")
    public String inherits = "";

    @Expose
    public String icon = "";
}
