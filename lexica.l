%{
#include <string>

%}


Espaco [ \t]
Delim {Espaco}+
Int (-?[1-9][0-9]*)|0
Float {Int}\.[0-9]+
Char \'([^'])\'
Id [a-zA-z_]([a-zA-z_]|[0-9])*
String \"([^\"\n]|\\\")*\" 

%%

[{}()[\];,:]    { return *yytext; }

"Var"    {
                return TK_VAR;
            }
"Switch"    {
                return TK_SWITCH;
            }

"Case"      {
                return TK_CASE;
            }
"Default"   {
                return TK_DEFAULT;
            }
"If"         {
                yylval.traducao = "if";
                yylval.label = yytext;
                return TK_IF;
             }
"Else"       {
                 yylval.traducao = "else";
                 yylval.label = yytext;
                 return TK_ELSE;
             }
"For"        {
                yylval.traducao = "for";
                 yylval.label = yytext;
                 return TK_FOR;
              }
"While"       {
                yylval.traducao = "while";
                 yylval.label = yytext;
                 return TK_WHILE;
              }
"(Float)"     {
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
"Scan"      {
              yylval.label = yytext;
                return TK_IN_OUT;
            }
"Print"    {
               yylval.label = yytext;
                return TK_IN_OUT;
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
"=="        {
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

"="         {
                yylval.traducao = yytext;
                yylval.label = yytext;
                return TK_ATRIB;
            }

"And"       {
                yylval.traducao = "&&";
                yylval.label = yytext;
                return TK_LOGICO;
            }

"Or"        {   
                yylval.traducao = "||";
                yylval.label = yytext;
                return TK_LOGICO;
            }

"Not"       {   
                yylval.traducao = "!";
                yylval.label = yytext;
                return TK_LOGICO;
            }

"True"      {   
                yylval.traducao = "true";
                yylval.label = yytext;
                yylval.tipo = "Bool";
                yylval.tipo_traducao = "bool";
                return TK_BOOL;
            }

"False"     {   
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
{Delim}     {}

   /* 
"return"    {
                yylval.traducao = yytext;
                yylval.label = yytext;
                return TK_RETURN;
            }

"break"     {
                yylval.traducao = yytext;
                yylval.label = yytext;
                return TK_BREAK;
            }
            */
"Global"    {
                yylval.label = yytext;
                yylval.traducao = "cin";
                return TK_GLOBAL;
            }
"Char"      {
                yylval.traducao = "char";
                yylval.label = yytext;
                return TK_TIPO_CHAR;
            }
"String"    {
                yylval.traducao = yytext;
                yylval.label = yytext;
                return TK_TIPO_STRING;
            }
"Int"       {
                /*
                *   TESTADO
                */
                yylval.traducao = "int";
                yylval.label = yytext;
                return TK_TIPO_INT;
            }

"Float"     {
                /*
                *   TESTADO
                */
                yylval.traducao = "float";
                yylval.label = yytext;
                return TK_TIPO_FLOAT;
            }
"Bool"      {
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
{String}    {
                string texto = yytext;
                texto.replace(texto.begin(),texto.begin()+1,"");
                texto.replace(texto.end()-1,texto.end(),"");
                yylval.traducao = texto;
                yylval.label = texto;
                yylval.tipo = "String";
                yylval.tipo_traducao = "char";
                yylval.tamanho = texto.size();
                return TK_STRING;
            }
{Id}        {
                /*
                *   TESTADO
                */
                yylval.label = yytext;
                return TK_ID;
            }

%
