%{
#include <iostream>
#include <string>
#include <fstream>
#include <cstdio>
#include <sstream>
#include <map>
#include <vector>

#define YYSTYPE atributos
using namespace std;

typedef struct ATRIBUTOS{
	string label;
	string traducao;
	string tipo;
	string tipo_traducao;
	int tamanho;
}atributos;

typedef struct VARIAVEL
{
    string id;
	string tipo_traducao;
	string temporario;
}Variavel;

typedef struct
{
	string id;
	string tipo_traducao;
}VariavelTemporaria;

typedef map<string, Variavel> MapaVar;
typedef map<string, VariavelTemporaria> MapaTemp;

static MapaVar mapa_variaveis;
static MapaTemp mapa_temporario;

int yylex();
void yyerror(string);
string cria_nome_nova_temp();
string declara_variaveis_temp(MapaTemp mapa_vars);





%}

%token TK_NUM TK_CHAR TK_ID TK_BOOL 
%token TK_MAIN TK_TIPO_INT TK_TIPO_BOOL TK_TIPO_FLOAT TK_TIPO_CHAR 
%token TK_SOMA_ou_SUBTRACAO TK_DIVISAO_ou_MULTIPLICACAO
%token TK_MENOR_QUE TK_MAIOR_QUE TK_IGUAL TK_DIFERENTE TK_MENOR_IGUAL TK_LOGICO
%token TK_ATRIB TK_CAST_DO_INT TK_CAST_DO_FLOAT
%token TK_FIM TK_ERROR

%start S

//precedencia de operações
%left TK_RELACIONAL
%left TK_LOGICO
%left TK_SOMA_ou_SUBTRACAO
%left TK_DIVISAO_ou_MULTIPLICACAO

%%

S 				: TK_TIPO_INT TK_MAIN '('')'BLOCO
				{
					cout << "/*Compilador FOCA*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << declara_variaveis_temp(mapa_temporario) << $5.traducao << "\treturn 0;\n}" << endl; 
				};

BLOCO			: '{' COMANDOS '}'
				{
					$$.traducao = $2.traducao; //todos os comandos sendo atribuido em $$
				};

COMANDOS		: COMANDO COMANDOS
				{
					$$.traducao = $1.traducao + $2.traducao; //um comando(expressao)
				}
				|
				{
					$$.traducao = ""; //EOF
				}
				;

COMANDO 		: E ';'
 				| OPERACAO_LOGICO ';'
			    | DECLARACAO ';'
				;
DECLARACAO  : TK_TIPO_FLOAT TK_ID TK_ATRIB  E 
			{  
                if(mapa_variaveis.find($2.label)){ 
                    /* 
                    *   RETORNAR ERRO AQUI VARIAVEL JA FOI DECLARADA
                    */
                }

                $$.label = cria_nome_nova_temp();
                $$.tipo = "Float";
                $$.tipo_traducao = "float"

                mapaVariaveis[$2.label] = { .id = $2.label,
                        .tipo_traducao = $$.tipo_traducao, $$.label };
                mapa_temporario[$$.label] = { .id = $$.label, .tipo = $$.tipo };
                if($4.tipo != "Float"){
                    string varCast = cria_nome_nova_temp();
                    mapa_temporario[varCast] = { .id = varCast,
                            .tipo_traducao = "float" };
                    
                  	string expCast = varCast + "= (float) " + $4.label +";";
                    $$.traducao =  expCast + "/n" + $2.temporario + " = " $4.label; 
                }
  				else{
                	$$.traducao = $2.temporario + " = " + $4.label +";";
                }
			}
			| TK_TIPO_BOOL TK_ID TK_ATRIB E
			{
                if(mapaVariaveis.find($2.label)){ 
                    /* 
                    *   RETORNAR ERRO AQUI VARIAVEL JA FOI DECLARADA
                    */
                }

                $$.label = cria_nome_nova_temp();
                $$.tipo = "Bool";
                $$.tipo_traducao = "bool"

                mapaVariaveis[$2.label] = { .id = $2.label,
                        .tipo_traducao = $$.tipo_traducao, $$.label };
                mapa_temporario[$$.label] = { .id = $$.label, .tipo = $$.tipo };
                if($4.tipo != "Bool"){
                    string varCast = cria_nome_nova_temp();
                    mapa_temporario[varCast] = { .id = varCast,
                            .tipo_traducao = "bool" };
                    
                  	string expCast = varCast + "= (bool) " + $4.label +";";
                    $$.traducao =  expCast + "/n" + $2.temporario + " = " $4.label; 
                }
  				else{
                	$$.traducao = $2.temporario + " = " + $4.label +";";
                }
			}
			| TK_TIPO_CHAR TK_ID TK_ATRIB E
      		{

                if(mapaVariaveis.find($2.label)){ 
                    /* 
                    *   RETORNAR ERRO AQUI VARIAVEL JA FOI DECLARADA
                    */
                }

                $$.label = cria_nome_nova_temp();
                $$.tipo = "Char";
                $$.tipo_traducao = "char"

                mapaVariaveis[$2.label] = { .id = $2.label,
                        .tipo_traducao = $$.tipo_traducao, $$.label };
                mapa_temporario[$$.label] = { .id = $$.label, .tipo = $$.tipo };
                if($4.tipo != "Char"){
                    string varCast = cria_nome_nova_temp();
                    mapa_temporario[varCast] = { .id = varCast,
                            .tipo_traducao = "char" };
                    
                  	string expCast = varCast + "= (char) " + $4.label +";";
                    $$.traducao =  expCast + "/n" + $2.temporario + " = " $4.label; 
                }
  				else{
                	$$.traducao = $2.temporario + " = " + $4.label +";";
                }
      		}
			| TK_TIPO_INT TK_ID TK_ATRIB E
      		{

                if(mapaVariaveis.find($2.label)){ 
                    /* 
                    *   RETORNAR ERRO AQUI VARIAVEL JA FOI DECLARADA
                    */
                }

                $$.label = cria_nome_nova_temp();
                $$.tipo = "Int";
                $$.tipo_traducao = "int"

                mapaVariaveis[$2.label] = { .id = $2.label,
                        .tipo_traducao = $$.tipo_traducao, $$.label };
                mapa_temporario[$$.label] = { .id = $$.label, .tipo = $$.tipo };
                if($4.tipo != "Int"){
                    string varCast = cria_nome_nova_temp();
                    mapa_temporario[varCast] = { .id = varCast,
                            .tipo_traducao = "int" };
                    
                  	string expCast = varCast + "= (int) " + $4.label +";";
                    $$.traducao =  expCast + "/n" + $2.temporario + " = " $4.label; 
                }
  				else{
                	$$.traducao = $2.temporario + " = " + $4.label +";";
                }
      		}
			;

E				: ATRIBUICAO
  			    | OPERACAO_ARITMETICA
				;

OPERACAO_ARITMETICA : E TK_SOMA_ou_SUBTRACAO E
				{   
                    
                    $$.label = cria_nome_nova_temp();
                    if ($1.tipo == Int && $3.tipo == Float) {
                        string varCast = cria_nome_nova_temp();
                        $$.tipo_traducao = "float";
                        $$.traducao += '\t' + varCast + " = (float) " + $1.label + ";\n" +
                        '\t' + $$.label + " = " + varCast + $2.traducao + $3.label + ";\n";
                        MapaVar[varCast] = { .id = varCast, .tipo_traducao = "float" };
                        MapaVar[$$.label] = { .id = $$.label, .tipo_traducao = "float" };
                    }
                     else if ($1.tipo == Float && $3.tipo == Int) {
                        string varCast = cria_nome_nova_temp();
                        $$.tipo_traducao = "float";
                        $$.traducao += '\t' + varCast + " = (float) " + $3.label + ";\n" +
                        '\t' + $$.label + " = " + varCast + $2.traducao + $1.label + ";\n";
                        MapaVar[varCast] = { .id = varCast, .tipo_traducao = "float" };
                        MapaVar[$$.label] = { .id = $$.label, .tipo_traducao = "float" };
                    }
                     else {
                        $$.tipo = $1.tipo;
                        $$.tipo_traducao = "int";
                        MapaVar[$$.label] = { .id = $$.label, .tipo_traducao = $1.tipo_traducao };
                        $$.traducao += '\t' + $$.label + " = " + $1.label + $2.traducao + $3.label + ";\n";
                    }

				}
                |
                E TK_DIVISAO_ou_MULTIPLICACAO E
				{   
                    
                    $$.label = cria_nome_nova_temp();
                    if ($1.tipo == Int && $3.tipo == Float) {
                        string varCast = cria_nome_nova_temp();
                        $$.tipo_traducao = "float";
                        $$.traducao += '\t' + varCast + " = (float) " + $1.label + ";\n" +
                        '\t' + $$.label + " = " + varCast + $2.traducao + $3.label + ";\n";
                        MapaVar[varCast] = { .id = varCast, .tipo_traducao = "float" };
                        MapaVar[$$.label] = { .id = $$.label, .tipo_traducao = "float" };
                    }
                     else if ($1.tipo == Float && $3.tipo == Int) {
                        string varCast = cria_nome_nova_temp();
                        $$.tipo_traducao = "float";
                        $$.traducao += '\t' + varCast + " = (float) " + $3.label + ";\n" +
                        '\t' + $$.label + " = " + varCast + $2.traducao + $1.label + ";\n";
                        MapaVar[varCast] = { .id = varCast, .tipo_traducao = "float" };
                        MapaVar[$$.label] = { .id = $$.label, .tipo_traducao = "float" };
                    }
                     else {
                        $$.tipo = $1.tipo;
                        $$.tipo_traducao = "int";
                        MapaVar[$$.label] = { .id = $$.label, .tipo_traducao = $1.tipo_traducao };
                        $$.traducao += '\t' + $$.label + " = " + $1.label + $2.traducao + $3.label + ";\n";
                    }

				}
                |
                TK_NUM
                {
                    $$.tipo_traducao = $1.tipo_traducao;
                    $$.label = cria_nome_nova_temp();
                    MapaVar[$$.label] = { .id = $$.label, .tipo_traducao = $$.tipo_traducao };
                    $$.traducao = '\t' + $$.label + " = " + $1.traducao + ";\n";
                }


                |
                '(' E ')'
                {
                    $$.label = cria_nome_nova_temp();
                    $$.traducao= $2.traducao;
                    $$.tipo_traducao = $2.tipo_traducao;
                    MapaVar[$$.label] = { .id = $$.label, .tipo_traducao = $$.tipo_traducao };
                }
			| TK_ID 
			{
        		string var = mapa[$1.label].temporario;
        		$$.label = mapa_temporario[var].id;
        		$$.tipo = mapa_temporario[var].tipo;
        		$$.traducao = "";
			}
			;

OPERACAO_RELACIONAL	:	E TK_RELACIONAL E
                    {
                        $$.label = cria_nome_nova_temp();
                        $$.tipo = Bool; $$.tipo_traducao = "bool";
                        mapa_temporario[$$.label] = {.id = $$.label, .tipo = $$.tipo_traducao};
  											//decide qual operacao
                        string var;
  											if($2.traducao == "And") var = "&&";
                        else if($2.traducao == "Or") var = "||";
                        else if($2.traducao == "!=") var = "!=";
                        //
                        $$.traducao = $1.traducao + $3.traducao + '\t' + $$.label + " = " + $1.label + var + $3.label + ";\n";
                    }
					| OPERACAO_RELACIONAL TK_RELACIONAL TK_BOOL
                    {
                      	$$.label = cria_nome_nova_temp();
                      	$$.tipo = "Bool";
                        $$.tipo_traducao = "bool";
                      	mapa_temporario[$$.label] = {.id = $$.label, .tipo = $$.tipo_traducao};
										//decide qual operacao
                        string var;
                        if($2.traducao == "And") var = "&&";
                        else if($2.traducao == "Or") var = "||";
                        else if($2.traducao == "!=") var = "!=";
                        //
                      	$$.traducao = $1.traducao + '\t' + $$.label + " = " + $1.label + "==" + var + ";\n"
                    }
                    ;

OPERACAO_LOGICO 	: OPERACAO_LOGICO TK_LOGICO OPERACAO_LOGICO
                    {
                          $$.label = cria_nome_temp();
                          $$.tipo = Bool;$$.tipo_traducao = "bool";
						  mapa_temporario[$$.label] = { .id = $$.label, .tipo = $$.tipo_traducao };
                          //decide qual operacao
                          string var;
                          if($2.traducao == "And") var = "&&";
                          else if($2.traducao == "Or") var = "||";
                          else if($2.traducao == "!=") var = "!=";
                          $$.traducao = $1.traducao + $3.traducao + '\t' + $$.label + " = " + $1.label + var + $3.label + ";\n";	
                    }
				    |
                    OPERACAO_RELACIONAL
                    ;  
        
ATRIBUICAO			: TK_ID TK_ATRIB TK_BOOL
                    {
                      //mapV mapa = buscaMapa($1.label);
                      $$.traducao = '\t' + mapa_temporario[mapa[$1.label].temporario].id + " = " + $3.traducao + ";\n";
                    }
                    |
                    TK_ID TK_ATRIB TK_CHAR
                    {
                      //mapV mapa = buscaMapa($1.label);
                      $$.traducao = '\t' + mapa_temporario[mapa[$1.label].temporario].id + " = " + $3.traducao + ";\n";
                    } 
                    |
                    TK_ID TK_ATRIB E
                    {
                        //mapVar mapa = buscaMapa($1.label); ---usar mais tarde
                        $1.tipo = mapa_temporario[mapa[$1.label].temporario].tipo;
                        if($1.tipo != $3.tipo){
                          	string variavel_cast = cria_nome_nova_temp();
                            if($1.tipo == "Int"){
                                $$.tipo = "Int";
                            	mapa_temporario[varCast] = { .id = variavel_cast .tipo = "Int" };
                            	$$.traducao = $3.traducao + '\t' + varavel_cast + " = (int) " + $3.label + ";\n" +
															'\t' + mapa_temporario[mapa[$1.label].temporario].id + " = " + variavel_cast + ";\n";
                            }else if($1.tipo == "Float"){
                                $$.tipo = "Float";
                                mapa_temporario[varCast] = { .id = variavel_cast .tipo = "Float" };
                                $$.traducao = $3.traducao + '\t' + varavel_cast + " = (float) " + $3.label + ";\n" +
                                '\t' + mapa_temporario[mapa[$1.label].temporario].id + " = " + variavel_cast + ";\n";
                            }
                        } 
                    }
  					|
                    TK_ID TK_ATRIB OPERACAO_LOGICO
                    {	
                      $$.traducao = $3.traducao + '\t' + mapa_temporario[mapa[$1.label].temporario].id + " = " + $3.label + ";\n";
                    }
                    ;
        
        
        
%%

//FUNÇOES 
string cria_nome_nova_temp(){
	static int n = 0;
	n++;
    return "temp" + to_string(n);
}

variavel cria_var(string nome_temp){
    variavel * var =  malloc(sizeof(variavel));
    var -> nome_temp = nome_temp;
	return var;
}


string declara_variaveis_temp(MapaTemp mapa_vars){
   	string s = "";
	for (MapVar::iterator it = mapa_vars.begin(); it!=mapa_vars.end(); ++it) {
    	s += '\t' + it->second.tipo_traducao + ' ' + it->id + ";\n";
	}
    return s;
}
