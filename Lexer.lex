
package ;

import java_cup.runtime.*;
import java.io.IOException;

import .Sym;
import static .Sym.*;

%%

%class Lexer
%unicode
%cup
%line
%column

// %public
%final
// %abstract

%cupsym .Sym
%cup
// %cupdebug

%{
	StringBuffer string = new StringBuffer();

	private Symbol symbol(int type) {
		return new Symbol(type, yyline, yycolumn);
	}
	private Symbol symbol(int type, Object value) {
		return new Symbol(type, yyline, yycolumn, value);
	}
%}

	LineTerminator = \r|\n|\r\n
    InputCharacter = [^\r\n]
    Whitespace = {LineTerminator} | " " | "\t"

    Comment = {NormalComment} | {SingleLineComment}
    NormalComment = "/#" [^#] ~"#/" | "/#" "#"+ "/"
    SingleLineComment = "#" {InputCharacter}* {LineTerminator}?
    
    Letter = [a-zA-Z]
	Digit = [0-9]
	IdChar = {Letter} | {Digit} | "_"
	Identifier = {Letter}{IdChar}*

	IntegerLiteral = 0 | "-"? [1-9][0-9]*
    // FloatLiteral = {IntegerLiteral} (\. [0-9]+)? 
    // RatLiteral = (({IntegerLiteral} "_")? ({IntegerLiteral} "/" {IntegerLiteral})?) | {IntegerLiteral}

    BooleanLiteral = "T" | "F"

    Punctuation = [["!".."/"] || [":".."@"] || ["[".."`"] || ["{".."~"]]

    CharLiteral = {Punctuation} | {Letter} | {Digit} | " "   
    
    %state STRING, CHARLITERAL

%%

<YYINITIAL> {	
	\'								{ yybegin(CHARLITERAL); }
	\" 								{ yybegin(STRING); string.setLength(0); }
	"char"							{ return symbol(sym.CHAR); }
	"let"							{ return symbol(sym.LET); }
	"bool"							{ return symbol(sym.BOOL); }
	"tdef"							{ return symbol(sym.TDEF); }
	"fdef"							{ return symbol(sym.FDEF); }
	"rat"							{ return symbol(sym.RAT); }
	"float"							{ return symbol(sym.FLOAT); }
	"int"							{ return symbol(sym.INT); }
}

<STRING> {
	\"								{ yybegin(YYINITIAL); return symbol(sym.STRING, string.toString()); }

	{CharLiteral}+					{ string.append( yytext() ); }

	"\\\""							{ string.append( '\"' ); }
  	"\\'"							{ string.append( '\'' ); }
  	"\\\\"							{ string.append( '\\' ); }
}

<CHARLITERAL> {
	{CHARLITERAL}\'					{ yybegin(YYINITIAL); return symbol(sym.CHAR, yytext().charAt(0)); }
}

[^] {
	
}
