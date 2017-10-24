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
}Variavel;

int yylex();
void yyerror(sting);
string cria_nome_nova_temp();

typedef map<label, Variavel> MapaVar;





%}

%token TK_NUM TK_CHAR TK_ID
%token TK_MAIN TK_TIPO_INT TK_TIPO_BOOL TK_TIPO_FLOAT TK_TIPO_CHAR 
%token TK_SOMA_ou_SUBTRACAO TK_DIVISAO_ou_MULTIPLICACAO
%token TK_MENOR_QUE TK_MAIOR_QUE TK_IGUAL TK_DIFERENTE TK_MENOR_IGUAL TK_MAIOR_IGUAL TK_AND TK_OR TK_NOT
%token TK_ATRIBUICAO TK_CAST_DO_INT TK_CAST_DO_FLOAT
%token TK_FIM TK_ERROR

%start S

//precedencia de operações
%left TK_RELACIONAL
%left TK_LOGICO
%left TK_SOMA_ou_SUBTRACAO
%left TK_DIVISAO_ou_MULTIPLICACAO

%%

S 				: TK_TIPO_INT TK_MAIN '( '')'BLOCO
				{
					cout << "/*Compilador FOCA*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\treturn 0;\n}" << endl; 
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
				;

E 				: OPERACAO_LOGICA
				| OPERACAO_RELACIONAL
				| ATRIBUICAO
				;

E 			: E TK_SOMA_ou_SUBTRACAO E
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
        		$$.label = mapaTemporario[var].id;
        		$$.tipo = mapaTemporario[var].tipo;
        		$$.traducao = "";
			}
			|

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


string declara_vars(MapaVar mapa_vars){
   	string s = "";
	for (MapVar::iterator it = mapa_vars.begin(); it!=mapa_vars.end(); ++it) {
    	s += '\t' + it->second.tipo + ' ' + it->second.nome_temp + ";\n";
	}
    return s;
}
