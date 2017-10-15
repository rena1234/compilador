%{
	#include <string>
%}


Espaco [ \t]
Delim {Espaco}+
Int -?[1-9][0-9]*
Float {Int}(\.[0-9]*)?
Char \'([^'])\'
Id [a-zA-z_]([a-zA-z_]|[0-9])*

%%

[()[\];,:]	{ return *yytext; }

"="			{
                yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_ATRIB;
			}

"And"	    {
				yylval.traducao = "&&";
				yylval.label = yytext;
				return TK_AND;
			}

"Or"		{	
				yylval.traducao = "||";
				yylval.label = yytext;
				return TK_OR;
			}

"Not"		{	
				yylval.traducao = "!";
				yylval.label = yytext;
				return TK_NOT;
			}

"True"		{	
				yylval.traducao = "true";
				yylval.label = yytext;
				yylval.tipo = "Boolean";
				yylval.tipo_traducao = "bool";
				return TK_LOGICO;
			}

"False"		{	
				yylval.traducao = "false";
				yylval.label = yytext;
				yylval.tipo = "Boolean";
				yylval.tipo_traducao = "bool";
				return TK_LOGICO;
			}
"{"         {
                yylval.traducao = yytext;
                yylval.label = yytext;
                return TK_BEGIN;
            }
"}"         {
                yylval.traducao = yytext;
                yylval.label = yytext;
                return TK_END;
            }

"main"      {
                yylval.traducao = yytext;
                yylval.label = yytext;
                return TK_MAIN;
            }
{Delim} 	{}

"return"	{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_RETURN;
			}

"break"		{
				yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_BREAK;
			}
 
"Int"		{
				yylval.traducao = "int";
				yylval.label = yytext;
				return TK_TIPO_INT;
			}

"Float"		{
				yylval.traducao = "float";
				yylval.label = yytext;
				return TK_TIPO_FLOAT;
			}
"Bool"	    {
				yylval.traducao = "bool";
				yylval.label = yytext;
				return TK_TIPO_BOOL;
			}

{Int}       {
				yylval.traducao = yytext;
				yylval.label = yytext;
				yylval.tipo = "Int";
				yylval.tipo_traducao = "int";
				yylval.tamanho = ((string) yytext).size();
				return TK_INT;
			}

{Float}     {
				yylval.traducao = yytext;
				yylval.label = yytext;
				yylval.tipo = "Float";
				yylval.tipo_traducao = "float";
				yylval.tamanho = ((string) yytext).size();
				return TK_FLOAT;
            }

{Id}		{
				yylval.label = yytext;
				return TK_ID;
			}
%%
