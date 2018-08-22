parser grammar JavadocParser;

options { tokenVocab=JavadocLexer; }

documentation
	: EOF
	|  ( tag | comment )*
	  EOF
	;

comment
	:  SPACE* ( inlineTag | TEXT_CONTENT | NAME | SPACE | STAR | AT | BRACE_OPEN | BRACE_CLOSE )* NEWLINE
	;

tag
    : AT tagName SPACE* tagText
    ;

tagName
    : NAME
    ;

tagText
    : ((inlineTag | TEXT_CONTENT | NAME | SPACE | STAR | BRACE_OPEN | BRACE_CLOSE )* NEWLINE)+
    ;

inlineTag
    : INLINE_TAG_START inlineTagName SPACE+ inlineTagKey SPACE* inlineTagText BRACE_CLOSE
    ;

inlineTagName
    : NAME
    ;

inlineTagKey
    : (TEXT_CONTENT | NAME | STAR )+
    ;

inlineTagText
    : (TEXT_CONTENT | NAME | SPACE | STAR )*
    ;