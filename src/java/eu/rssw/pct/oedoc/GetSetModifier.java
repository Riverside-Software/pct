package eu.rssw.pct.oedoc;

public enum GetSetModifier {
    NONE, PUBLIC, PROTECTED, PRIVATE;
    
    public static GetSetModifier from(int value) {
        if (value == 294)
            return PRIVATE;
        else if ((value == 295) || (value == -1) /* No modifier */)
            return PUBLIC;
        else if (value == 296)
            return PROTECTED;
        return null;
    }
    
}