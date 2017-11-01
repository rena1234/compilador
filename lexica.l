%{
	#include <string>
%}


Espaco [ \t]
Delim {Espaco}+
Int (-?[1-9][0-9]*)|0
Float {Int}\.[0-9]+
Char \'([^'])\'
Id [a-zA-z_]([a-zA-z_]|[0-9])*

%%

[(){}[\];,:]	{ return *yytext; }

"If"         {
                yylval.traducao = "if";
                yylval.label = yytext;
                return TK_IF;
             }

"(Float)"    {
                yylval.tipo = "Float"; 
                yylval.tipo_traducao = "float"; 
                yylval.traducao = "(float)";
		yylval.label = yytext;
		return TK_CAST;
             }

"(Int)"      {
                
                yylval.tipo = "Int"; 
                yylval.tipo_traducao = "int"; 
                yylval.traducao = "(int)";
		yylval.label = yytext;
		return TK_CAST;
            }

"!="        {
                /*
                *   TESTADO
                */
                
                yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_RELACIONAL;
            }


">"         {
                
                yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_RELACIONAL;
            }

"<"         {
                
                yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_RELACIONAL;
            }

"/"         {
                
                yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_DIVISAO_ou_MULTIPLICACAO;
            }

"*"         {
                
                yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_DIVISAO_ou_MULTIPLICACAO;
            }

"-"         {
                
                /*
                *   TESTADO
                */
                yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_SOMA_ou_SUBTRACAO;
            }

"+"         {
                
                yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_SOMA_ou_SUBTRACAO;
            }

"="			{
                yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_ATRIB;
			}

"And"	    {
				yylval.traducao = "&&";
				yylval.label = yytext;
				return TK_LOGICO;
			}

"Or"		{	
				yylval.traducao = "||";
				yylval.label = yytext;
				return TK_LOGICO;
			}

"Not"		{	
				yylval.traducao = "!";
				yylval.label = yytext;
				return TK_LOGICO;
			}

"True"		{	
				yylval.traducao = "true";
				yylval.label = yytext;
				yylval.tipo = "Bool";
				yylval.tipo_traducao = "bool";
				return TK_BOOL;
			}

"False"		{	
				yylval.traducao = "false";
				yylval.label = yytext;
				yylval.tipo = "Bool";
				yylval.tipo_traducao = "bool";
				return TK_BOOL;
			}
    /*
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
            */

"main"      {
                /*
                *   TESTADO
                */
                yylval.traducao = yytext;
                yylval.label = yytext;
                return TK_MAIN;
            }
{Delim} 	{}

   /* 
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
            */
"Char"      {
                yylval.traducao = "char";
                yylval.label = yytext;
                return TK_TIPO_CHAR;
            }
"Int"		{
                /*
                *   TESTADO
                */
				yylval.traducao = "int";
				yylval.label = yytext;
				return TK_TIPO_INT;
			}

"Float"		{
                /*
                *   TESTADO
                */
				yylval.traducao = "float";
				yylval.label = yytext;
				return TK_TIPO_FLOAT;
			}
"Bool"	    {
                /*
                *   TESTADO
                */
				yylval.traducao = "bool";
				yylval.label = yytext;
				return TK_TIPO_BOOL;
			}

{Int}       {
				/*
                *   TESTADO
                */
                yylval.traducao = yytext;
				yylval.label = yytext;
				yylval.tipo = "Int";
				yylval.tipo_traducao = "int";
				yylval.tamanho = ((string) yytext).size();
				return TK_NUM;
			}

{Float}     {
				/*
                *   TESTADO
                */
				yylval.traducao = yytext;
				yylval.label = yytext;
				yylval.tipo = "Float";
				yylval.tipo_traducao = "float";
				yylval.tamanho = ((string) yytext).size();
				return TK_NUM;
            }

{Char}      {
                yylval.traducao = yytext;
                yylval.label = yytext;
                yylval.tipo = "Char";
                yylval.tipo_traducao = "char";
                return TK_CHAR;
            }

{Id}		{
                /*
                *   TESTADO
                */
				yylval.label = yytext;
				return TK_ID;
			}
%
  
