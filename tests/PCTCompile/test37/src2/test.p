def var var1 as myclass1 no-undo.
def var var2 as myclass2 no-undo.

var1 = new myclass1().
var2 = new myclass2().

return '0'.

/*
RCODE-INFO:FILE-NAME = "build0/package/Foo.r".
MESSAGE "build0/package/foo : " + RCODE-INFO:MD5-VALUE VIEW-AS ALERT-BOX INFO BUTTONS OK.

RCODE-INFO:FILE-NAME = "build1/package/foo.r".
MESSAGE "build1/package/foo : " + RCODE-INFO:MD5-VALUE VIEW-AS ALERT-BOX INFO BUTTONS OK.

RCODE-INFO:FILE-NAME = "build2/package/fOO.r".
MESSAGE "build2/package/foo : " + RCODE-INFO:MD5-VALUE VIEW-AS ALERT-BOX INFO BUTTONS OK.


RCODE-INFO:FILE-NAME = "build0/package/bar.r".
MESSAGE "build0/package/bar : " + RCODE-INFO:MD5-VALUE VIEW-AS ALERT-BOX INFO BUTTONS OK.

RCODE-INFO:FILE-NAME = "build1/package/bar.r".
MESSAGE "build1/package/bar : " + RCODE-INFO:MD5-VALUE VIEW-AS ALERT-BOX INFO BUTTONS OK.

RCODE-INFO:FILE-NAME = "build2/package/bAr.r".
MESSAGE "build2/package/bar : " + RCODE-INFO:MD5-VALUE VIEW-AS ALERT-BOX INFO BUTTONS OK.
*/