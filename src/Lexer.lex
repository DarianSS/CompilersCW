
import java_cup.runtime.*;

%%

%class Lexer
%unicode
%cup
%line
%column

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

//IntegerLiteral = 0 | "-"? [1-9][0-9]* 
// FloatLiteral = {IntegerLiteral} (\. [0-9]+)?
// RatLiteral = (({IntegerLiteral} "_")? ({IntegerLiteral} "/" {IntegerLiteral})?) | {IntegerLiteral}

FloatLiteral  = "-"? {FLit1}|{FLit2}|{FLit3}

FLit1    = [0-9]+ \. [0-9]* 
FLit2    = \. [0-9]+ 
FLit3    = [0-9]+ 

IntegerLiteral = 0 | [1-9][0-9]* 

BooleanLiteral = "T" | "F"

Punctuation = [[!] || [#-/] || [:-@] || [\[] || [\]-`] || [{-~]]

SingleChar = {Punctuation} | {Letter} | {Digit} | " "   

%state STRING, CHARLITERAL

%%

<YYINITIAL> {
	/* keywords */
	"char"							{ return symbol(sym.CHAR); }
	"bool"							{ return symbol(sym.BOOL); }
	"tdef"							{ return symbol(sym.TDEF); }
	"fdef"							{ return symbol(sym.FDEF); }
	"rat"							{ return symbol(sym.RAT); }
	"float"							{ return symbol(sym.FLOAT); }
	"int"							{ return symbol(sym.INT); }
	"seq"							{ return symbol(sym.SEQ); }
	"dict"							{ return symbol(sym.DICT); }
	"in"							{ return symbol(sym.IN); }
	"read"							{ return symbol(sym.READ); }
	"print"							{ return symbol(sym.PRINT); }
	"return"						{ return symbol(sym.RETURN); }
	"void"							{ return symbol(sym.VOID); }
	"while"							{ return symbol(sym.WHILE); }
	"forall"						{ return symbol(sym.FORALL); }
	"do"							{ return symbol(sym.DO); }
	"od"							{ return symbol(sym.OD); }
	"if"							{ return symbol(sym.IF); }
	"fi"							{ return symbol(sym.FI); }
	"else"							{ return symbol(sym.ELSE); }
	"elif"							{ return symbol(sym.ELIF); }
	"top"							{ return symbol(sym.TOP); }
	"alias"							{ return symbol(sym.ALIAS); }
	"then"							{ return symbol(sym.THEN); }
	"main"							{ return symbol(sym.MAIN); }

	/* boolean literals */ 
 	"T"								{ return symbol(sym.BOOLEAN_LITERAL, true); }
 	"F"								{ return symbol(sym.BOOLEAN_LITERAL, false); }

	/* null literal */
 	"null"							{ return symbol(sym.NULL_LITERAL); }

 	/* identifiers */ 
  	{Identifier}					{ return symbol(sym.IDENTIFIER, yytext()); }

	/* Separators */
	"("								{ return symbol(sym.LPAREN); }
 	")"								{ return symbol(sym.RPAREN); }
 	"{"								{ return symbol(sym.LBRACE); }
 	"}"								{ return symbol(sym.RBRACE); }
 	"["								{ return symbol(sym.LBRACK); }
 	"]"								{ return symbol(sym.RBRACK); }
 	";"								{ return symbol(sym.SEMICOLON); }
 	","								{ return symbol(sym.COMMA); }
 	"."								{ return symbol(sym.DOT); }

 	/* Operators */
 	"="								{ return symbol(sym.EQ); }
 	"_"								{ return symbol(sym.UNDERSCORE); }
	"<"								{ return symbol(sym.LT); }
	">"								{ return symbol(sym.GT); }
	"!"								{ return symbol(sym.NOT); }
	"=="							{ return symbol(sym.EQEQ); }
 	"<="							{ return symbol(sym.LTEQ); }
 	">="							{ return symbol(sym.GTEQ); }
 	"!="							{ return symbol(sym.NOTEQ); }
 	"&&" 							{ return symbol(sym.ANDAND); }
 	"||"							{ return symbol(sym.OROR); }
 	"^"								{ return symbol(sym.POW); }
 	"+"								{ return symbol(sym.PLUS); }
	"-"								{ return symbol(sym.MINUS); }
 	"*"								{ return symbol(sym.MULT); }
 	"/"								{ return symbol(sym.DIV); }
 	":"								{ return symbol(sym.COLON); }
 	"::"							{ return symbol(sym.CONCAT); }

 	/* string literal */
	\"								{ string.setLength(0); yybegin(STRING); }

  	/* character literal */
	\'								{ yybegin(CHARLITERAL); }

	/* Number literals */
	{IntegerLiteral}				{ return symbol(sym.INTEGER_LITERAL, new Integer(yytext())); }
	{FloatLiteral}					{ return symbol(sym.FLOAT_LITERAL, new Float(yytext().substring(0,yylength()-1))); }

	/* comments */
	{Comment}						{ /* ignore */ }

 	/* whitespace */
	{Whitespace}					{ /* ignore */ } 
}

<STRING> {
	\"								{ yybegin(YYINITIAL); return symbol(sym.STRING, string.toString()); }

	{SingleChar}+					{ string.append( yytext() ); }

	"\\\""							{ string.append( '\"' ); } 
  	"\\'"							{ string.append( '\'' ); }
  	"\\\\"							{ string.append( '\\' ); }
}

<CHARLITERAL> {
	{SingleChar}\'					{ yybegin(YYINITIAL); return symbol(sym.CHAR, yytext().charAt(0)); }
	\\'\'							{ yybegin(YYINITIAL); return symbol(sym.CHAR, yytext().charAt(0)); }
	\\\\\'							{ yybegin(YYINITIAL); return symbol(sym.CHAR, yytext().charAt(0)); }
}

[^]  {
  System.out.println("file:" + (yyline+1) +
    ":0: Error: Invalid input '" + yytext()+"'");
  return symbol(sym.BADCHAR);
}
