package za.co.mip.ablduck.models;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Signature {
    @Expose
    @SerializedName("long")
    public String longName = "";

    @Expose
    @SerializedName("short")
    public String shortName = "";

    @Expose
    public String tagname = "";

    public Signature(String longName, String shortName) {
        this.longName = longName;
        this.shortName = shortName;
        this.tagname = longName;
    }
}
