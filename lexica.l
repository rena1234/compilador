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


    /*

"(Float)"        {
                
                yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_CAST_FLOAT;
            }

"(Int)"        {
                
                yylval.traducao = yytext;
				yylval.label = yytext;
				return TK_CAST_INT;
            }
    */

"!="        {
                /*
                *   TESTADO
                */
                
                yylval.traducao = yytext;
				yylval.label = yytext;
                printf("lexica diferente\n");
				return TK_DIFERENTE;
            }


">"         {
                
                yylval.traducao = yytext;
				yylval.label = yytext;
                printf("lexica menor que\n");
				return TK_MENOR_QUE;
            }

"<"         {
                
                yylval.traducao = yytext;
				yylval.label = yytext;
                printf("lexica maior que\n");
				return TK_MAIOR_QUE;
            }

"/"         {
                
                yylval.traducao = yytext;
				yylval.label = yytext;
                printf("lexica barra\n");
				return TK_DIVISAO_ou_MULTIPLICACAO;
            }

"*"         {
                
                yylval.traducao = yytext;
				yylval.label = yytext;
                printf("lexica *\n");
				return TK_DIVISAO_ou_MULTIPLICACAO;
            }

"-"         {
                
                /*
                *   TESTADO
                */
                yylval.traducao = yytext;
				yylval.label = yytext;
                printf("lexica -\n");
				return TK_SOMA_ou_SUBTRACAO;
            }

"+"         {
                
                yylval.traducao = yytext;
				yylval.label = yytext;
                printf("lexica +\n");
				return TK_SOMA_ou_SUBTRACAO;
            }

"="			{
                yylval.traducao = yytext;
				yylval.label = yytext;
                printf("lexica =\n");
				return TK_ATRIB;
			}

"And"	    {
				yylval.traducao = "&&";
				yylval.label = yytext;
                printf("lexica and\n");
				return TK_LOGICO;
			}

"Or"		{	
				yylval.traducao = "||";
				yylval.label = yytext;
                printf("lexica or\n");
				return TK_LOGICO;
			}

"Not"		{	
				yylval.traducao = "!";
				yylval.label = yytext;
                printf("lexica not\n");
				return TK_LOGICO;
			}

"True"		{	
				yylval.traducao = "true";
				yylval.label = yytext;
				yylval.tipo = "Boolean";
				yylval.tipo_traducao = "bool";
                printf("lexica true\n");
				return TK_BOOL;
			}

"False"		{	
				yylval.traducao = "false";
				yylval.label = yytext;
				yylval.tipo = "Boolean";
				yylval.tipo_traducao = "bool";
                printf("lexica false\n");
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
                printf("lexica main\n");
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
 
"Int"		{
                /*
                *   TESTADO
                */
				yylval.traducao = "int";
				yylval.label = yytext;
                printf("lexica tipo int\n");
				return TK_TIPO_INT;
			}

"Float"		{
                /*
                *   TESTADO
                */
				yylval.traducao = "float";
				yylval.label = yytext;
                printf("lexica tipo float\n");
				return TK_TIPO_FLOAT;
			}
"Bool"	    {
                /*
                *   TESTADO
                */
				yylval.traducao = "bool";
				yylval.label = yytext;
                printf("lexica tipo bool\n");
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
                printf("lexica num int\n");
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
                printf("lexica num float\n");
				return TK_NUM;
            }

{Id}		{
                /*
                *   TESTADO
                */
				yylval.label = yytext;
                printf("lexica id\n");
				return TK_ID;
			}
%
  
