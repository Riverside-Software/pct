package eu.rssw.pct.oedoc;

import javax.xml.bind.annotation.XmlEnum;

@XmlEnum
public enum AccessModifier {
    STATIC, PUBLIC, PRIVATE, PROTECTED;

    public static AccessModifier from(int value) {
        if (value == 294)
            return PRIVATE;
        else if (value == 295)
            return PUBLIC;
        else if (value == 296)
            return PROTECTED;
        return null;
    }
}