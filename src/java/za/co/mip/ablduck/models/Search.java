package za.co.mip.ablduck.models;

import com.google.gson.annotations.Expose;

public class Search {
    @Expose
    public String name = "";

    @Expose
    public String fullName = "";

    @Expose
    public String icon = "";

    @Expose
    public String url = "";

    @Expose
    public Integer sort = 0;

    @Expose
    public Meta meta = null;
}
