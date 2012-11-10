package eu.rssw.pct.oedoc;

import javax.xml.bind.annotation.XmlEnum;

@XmlEnum
public enum ParameterMode {
    INPUT, OUTPUT, INOUT;

    public static ParameterMode from(int value) {
        if (value == 245)
            return INPUT;
        else if (value == 233)
            return OUTPUT;
        else if (value == 517)
            return INOUT;
        else
            return null;
    }
}