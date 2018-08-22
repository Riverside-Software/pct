lexer grammar JavadocLexer;

JAVADOC_START
	: '/**' SPACE* NEWLINE -> skip
	;

JAVADOC_END
	: SPACE+ '*/' -> skip
	;

JAVADOCLINESTART
    : SPACE+ STAR ( SPACE | ) -> skip
    ;

AT
	: '@'
	;

STAR
    : '*'
    ;

NEWLINE
    : [\r\n]
    ;

SPACE
    : [ \t]
    ;

NAME
	: [a-zA-Z]+
	;

INLINE_TAG_START
	: '{@'
	;

BRACE_OPEN
	: '{'
	;

BRACE_CLOSE
	: '}'
	;

TEXT_CONTENT
	: .
	;

/*
JAVADOC_LINE
    : SPACE* STAR SPACE TEXT_CONTENT NEWLINE
    ;

TEXT_CONTENT
	: [\t @*{}/a-zA-Z]+
	;
*/