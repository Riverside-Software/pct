package za.co.mip.ablduck.models;

import com.google.gson.annotations.Expose;

public class MemberType {
    @Expose
    public String name = "";

    @Expose
    public String title = "";

    @Expose
    public String icon = "";

    @Expose
    public Integer position = 0;
    
    public MemberType(String name, String title, String icon, Integer position) {
        this.name = name;
        this.title = title;
        this.icon = icon;
        this.position = position;
    }
}
