%{
#include <iostream>
#include <string>
#include <fstream>
#include <cstdio>
#include <sstream>
#include <map>
#include <vector>
#include <stack>

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

typedef struct BLOCO
{
	bool quebravel;
	MapaVar variaveis;
	string inicio;
	string fim;
}Bloco;

static MapaVar mapa_variaveis;
static MapaTemp mapa_temporario;
static stack <Bloco> pilha_blocos; 
  
  
int yylex();
void yyerror(string);
string cria_nome_nova_temp();
string declara_variaveis_temp(MapaTemp mapa_vars);
MapaVar cria_mapavar();
Variavel retorna_var(string label);




%}

%token TK_NUM TK_CHAR TK_ID TK_BOOL 
%token TK_MAIN TK_TIPO_INT TK_TIPO_BOOL TK_TIPO_FLOAT TK_TIPO_CHAR 
%token TK_SOMA_ou_SUBTRACAO TK_DIVISAO_ou_MULTIPLICACAO
%token TK_MENOR_QUE TK_MAIOR_QUE TK_IGUAL TK_DIFERENTE TK_MENOR_IGUAL TK_LOGICO
%token TK_ATRIB TK_CAST
%token TK_FIM TK_ERROR

%start S

//precedencia de operações
%left TK_RELACIONAL
%left TK_LOGICO
%left TK_SOMA_ou_SUBTRACAO
%left TK_DIVISAO_ou_MULTIPLICACAO

%nonassoc TK_IF
%%

/*S 				: TK_TIPO_INT TK_MAIN '('')'BLOCO
				{
					cout << "//Compilador Frankenstein/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << declara_variaveis_temp(mapa_temporario) << $5.traducao << "\n\treturn 0;\n}" << endl; 
				};*/
  
S				  : ESCOPO_GLOBAL COMANDOS
          {
  					cout << "//Compilador Frankenstein/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\n" << declara_variaveis_temp(mapa_temporario) << $2.traducao << "\n\treturn 0;\n}" << endl;
          /*
          	declarar funções aqui tbm
          */
          }
	      ;

ESCOPO_GLOBAL:
          {
            	//EMPILHAR BLOCO
                pilha_blocos.push({ .quebravel = false, .variaveis = cria_mapavar(), .inicio="", .fim=""});
          }
	      ;

COMANDOS	: COMANDO COMANDOS
				{
					$$.traducao = $1.traducao + $2.traducao; //um comando(expressao)
				}
				|
				{
					$$.traducao = ""; //EOF
				}
				;


COMANDO 		: DECLARACAO ';'
				      | ATRIBUICAO ';'
              | IF 
       		    | E ';'
            ;

BLOCO			: '{' COMANDOS '}'
				{
  				    pilha_blocos.pop();
                    pilha_blocos.push({ .quebravel = false, .variaveis = cria_mapavar(), .inicio="", .fim=""});
					$$.traducao = $2.traducao; //todos os comandos sendo atribuido em $$
				};

TIPO    : TK_TIPO_INT | TK_TIPO_BOOL | TK_TIPO_FLOAT | TK_TIPO_CHAR;

ARGUMENTOS    : ARGUMENTO ARGUMENTOS_ADICIONAIS
ARGUMENTOS_ADICIONAIS :
                      | ',' ARGUMENTOS
                      ;  
ARGUMENTO    : TIPO TK_ID
FUNCAO    : TIPO TK_ID '(' ARGUMENTOS ')' BLOCO
          ;

DECLARACAO  : TK_TIPO_FLOAT TK_ID TK_ATRIB  E 
			{  
               if(mapa_variaveis.find($2.label) != mapa_variaveis.end()){ 
                    yyerror("Variavel já foi declarada \n");
                }

                if($4.tipo != "Float"){
                    string varCast = cria_nome_nova_temp();
                    mapa_temporario[varCast] = { .id = varCast,
                            .tipo_traducao = "float" };
                    
                  	string expCast = varCast + " = (float) " + $4.label +";";
                    $$.traducao =  $4.traducao + "\t" + expCast + "\n";

                   pilha_blocos.top().variaveis[$2.label] = { .id = $2.label,
                            .tipo_traducao = "float", varCast };
                }
  				else{
                	$$ = $4;

                    pilha_blocos.top().variaveis[$2.label] = { .id = $2.label,
                            .tipo_traducao = $4.tipo_traducao, $4.label };
              }
			}
       | TK_TIPO_INT TK_ID
      {
          if(mapa_variaveis.find($2.label) != mapa_variaveis.end()){ 
              yyerror("Variavel já foi declarada \n");
          }
          
          $$.label = cria_nome_nova_temp();
          $$.tipo = "Int";
          $$.tipo_traducao = "int";
        
          pilha_blocos.top().variaveis[$2.label] = { .id = $2.label,
                        .tipo_traducao = $$.tipo_traducao, $$.label };

        
         	$$.traducao = "\t" + $$.tipo_traducao + " " + $$.label + ";"+ "\n";
      }

			| TK_TIPO_FLOAT TK_ID
      {
          if(mapa_variaveis.find($2.label) != mapa_variaveis.end()){ 
              yyerror("Variavel já foi declarada \n");
          }
          
          $$.label = cria_nome_nova_temp();
          $$.tipo = "Float";
          $$.tipo_traducao = "float";
          pilha_blocos.top().variaveis[$2.label] = { .id = $2.label,
                        .tipo_traducao = $$.tipo_traducao, $$.label };
          $$.traducao = "\t"+ $$.tipo_traducao + " " + $$.label + ";"+"\n";

        
      }
			| TK_TIPO_BOOL TK_ID
      {
          if(mapa_variaveis.find($2.label) != mapa_variaveis.end()){ 
              yyerror("Variavel já foi declarada \n");
          }
          
          $$.label = cria_nome_nova_temp();
          $$.tipo = "Bool";
          $$.tipo_traducao = "bool";
          pilha_blocos.top().variaveis[$2.label] = { .id = $2.label,
                        .tipo_traducao = $$.tipo_traducao, $$.label };
          $$.traducao = "\t"+$$.tipo_traducao + " " + $$.label + ";"+"\n";

        
      }
			| TK_TIPO_CHAR TK_ID
      {
          if(mapa_variaveis.find($2.label) != mapa_variaveis.end()){ 
              yyerror("Variavel já foi declarada \n");
          }
          
          $$.label = cria_nome_nova_temp();
          $$.tipo = "Char";
          $$.tipo_traducao = "char";
          pilha_blocos.top().variaveis[$2.label] = { .id = $2.label,
                        .tipo_traducao = $$.tipo_traducao, $$.label };
          $$.traducao = "\t"+$$.tipo_traducao + " " + $$.label + ";"+"\n";  

        
      }
			| TK_TIPO_BOOL TK_ID TK_ATRIB OPERACAO_LOGICO
			{
                /*
                if(pilha_blocos.top().variaveis.find($2.label) != mapa_variaveis.end()){ 
                    yyerror("Variavel já foi declarada \n");
                }
                */
                $$ = $4;

                pilha_blocos.top().variaveis[$2.label] = { .id = $2.label,
                        .tipo_traducao = $4.tipo_traducao, $4.label };
			}
			| TK_TIPO_CHAR TK_ID TK_ATRIB TK_CHAR 
      		{

                if(mapa_variaveis.find($2.label) != mapa_variaveis.end()){ 
                    yyerror("Variavel já foi declarada \n");
                }
                $$.label = cria_nome_nova_temp();
                $$.tipo = "Char";
                $$.tipo_traducao = "char";
                pilha_blocos.top().variaveis[$2.label] = { .id = $2.label,
                        .tipo_traducao = $$.tipo_traducao, $$.label };
                mapa_temporario[$$.label] = { .id = $$.label,
                        .tipo_traducao = $$.tipo_traducao };
  				
                $$.traducao = "\t" + retorna_var($2.label).temporario 
                        + " = " + $4.label +";" + "\n";
      		}
			| TK_TIPO_INT TK_ID TK_ATRIB E
      		{

                if(mapa_variaveis.find($2.label) != mapa_variaveis.end()){ 
                    yyerror("Variavel já foi declarada \n");
                }

                if($4.tipo != "Int"){
                    string varCast = cria_nome_nova_temp();
                    mapa_temporario[varCast] = { .id = varCast,
                            .tipo_traducao = "int" };
                    
                  	string expCast =  varCast + "= (int) " + $4.label +";";
                    $$.traducao = $4.traducao + "\t" + expCast + "\n";
                  
                    pilha_blocos.top().variaveis[$2.label] = { .id = $2.label,
                            .tipo_traducao = "int", varCast };
                }
  				else{
                	$$ = $4;

                    pilha_blocos.top().variaveis[$2.label] = { .id = $2.label,
                            .tipo_traducao = $4.tipo_traducao, $4.label };
                }
      		}
			;

E				:  OPERACAO_ARITMETICA
				;

OPERACAO_ARITMETICA : E TK_SOMA_ou_SUBTRACAO E
				{   
                    
                    $$.label = cria_nome_nova_temp();
                    if ($1.tipo == "Int" && $3.tipo == "Float") {
                        string varCast = cria_nome_nova_temp();
                        $$.tipo_traducao = "float";
                        $$.traducao += $3.traducao + '\t' + varCast + " = (float) "
                                + $1.label + ";\n" + '\t' + $$.label + " = "
                                + varCast + $2.traducao + $3.label + ";\n";
                        mapa_temporario[varCast] = { .id = varCast,
                                .tipo_traducao = "float" };
                        mapa_temporario[$$.label] = { .id = $$.label,
                                .tipo_traducao = "float" };
                    }
                     else if ($1.tipo == "Float" && $3.tipo == "Int") {
                        string varCast = cria_nome_nova_temp();
                        $$.tipo_traducao = "float";
                        $$.traducao += $3.traducao +'\t' + varCast + " = (float) " 
                                + $3.label + ";\n" + '\t' + $$.label + " = "
                                + varCast + $2.traducao + $1.label + ";\n";
                        mapa_temporario[varCast] = { .id = varCast, 
                                .tipo_traducao = "float" };
                        mapa_temporario[$$.label] = { .id = $$.label, 
                                .tipo_traducao = "float" };
                    }
                     else {
                        $$.tipo = $1.tipo;
                        $$.tipo_traducao = $1.tipo_traducao;
                        mapa_temporario[$$.label] = { .id = $$.label, 
                                .tipo_traducao = $1.tipo_traducao };
                        $$.traducao += $3.traducao +'\t' + $$.label + " = " + $1.label
                                + $2.traducao + $3.label + ";\n";
                    }

				}
                |
                E TK_DIVISAO_ou_MULTIPLICACAO E
				{   
                    
                    $$.label = cria_nome_nova_temp();
                    if ($1.tipo == "Int" && $3.tipo == "Float") {
                        string varCast = cria_nome_nova_temp();
                        $$.tipo_traducao = "float";
                        $$.traducao += $3.traducao + '\t' + varCast + " = (float) " + $1.label + ";\n" +
                        '\t' + $$.label + " = " + varCast + $2.traducao + $3.label + ";\n";
                        mapa_temporario[varCast] = { .id = varCast, .tipo_traducao = "float" };
                        mapa_temporario[$$.label] = { .id = $$.label, .tipo_traducao = "float" };
                    }
                     else if ($1.tipo == "Float" && $3.tipo == "Int") {
                        string varCast = cria_nome_nova_temp();
                        $$.tipo_traducao = "float";
                        $$.traducao += $3.traducao +'\t' + varCast + " = (float) " + $3.label + ";\n" +
                        '\t' + $$.label + " = " + varCast + $2.traducao + $1.label + ";\n";
                        mapa_temporario[varCast] = { .id = varCast, .tipo_traducao = "float" };
                        mapa_temporario[$$.label] = { .id = $$.label, .tipo_traducao = "float" };
                    }
                     else {
                        $$.tipo = $1.tipo;
                        $$.tipo_traducao = "int";
                        mapa_temporario[$$.label] = { .id = $$.label, .tipo_traducao = $1.tipo_traducao };
                        $$.traducao += $3.traducao +'\t' + $$.label + " = " + $1.label + $2.traducao + $3.label + ";\n";
                    }

				}
                |
                TK_NUM
                {
                    $$.tipo_traducao = $1.tipo_traducao;
                    $$.label = cria_nome_nova_temp();
                    mapa_temporario[$$.label] = { .id = $$.label, .tipo_traducao = $$.tipo_traducao };
                    $$.traducao = '\t' + $$.label + " = " + $1.traducao + ";\n";
                }
                |
                '(' E ')'
                {
                    $$.label = cria_nome_nova_temp();
                    $$.traducao= $2.traducao + '\t' + $$.label + " = " + $2.label + ";\n";
                    $$.tipo_traducao = $2.tipo_traducao;
                    $$.tipo = $2.tipo;
                    mapa_temporario[$$.label] = { .id = $$.label, .tipo_traducao = $$.tipo_traducao };
                }
                | TK_ID 
                {
                    string var = retorna_var($1.label).temporario;
                    $$.label = mapa_temporario[var].id;
                    $$.tipo_traducao = mapa_temporario[var].tipo_traducao;
                    $$.traducao = "";
                }
                ;

OPERACAO_RELACIONAL	:	E TK_RELACIONAL E
                    {
                        $$.label = cria_nome_nova_temp();
                        $$.tipo = "Bool"; $$.tipo_traducao = "bool";
                        mapa_temporario[$$.label] = {.id = $$.label,
                                .tipo_traducao = $$.tipo_traducao};

                        $$.traducao = $1.traducao + $3.traducao + '\t' 
                                + $$.label + " = " + $1.label + " " + $2.traducao + " " + $3.label + ";\n";
                    }
					| OPERACAO_RELACIONAL TK_RELACIONAL TK_BOOL
                    {
                      	$$.label = cria_nome_nova_temp();
                      	$$.tipo = "Bool";
                        $$.tipo_traducao = "bool";
                      	mapa_temporario[$$.label] = {.id = $$.label,
                                .tipo_traducao = $$.tipo_traducao};
                      	$$.traducao = $1.traducao + '\t' + $$.label + " = " + $1.label + 
                                "== " +  $2.traducao  + " ;\n";
                    }
                    ;

OPERACAO_LOGICO 	: OPERACAO_LOGICO TK_LOGICO OPERACAO_LOGICO
                    {
                          $$.label = cria_nome_nova_temp();
                          $$.tipo = "Bool"; $$.tipo_traducao = "bool";
						  mapa_temporario[$$.label] = { .id = $$.label, 
                          .tipo_traducao = $$.tipo_traducao };
                          $$.traducao = $1.traducao  + $3.traducao + '\t' + $$.label + " = "
                                + $1.label + " " + $2.traducao + " " +  $3.label + ";\n";	
                    }
				    |
                    OPERACAO_RELACIONAL 
                    |
                    TK_BOOL
                    {   
                        $$.tipo_traducao = $1.tipo_traducao;
                        $$.label = cria_nome_nova_temp();
                        mapa_temporario[$$.label] = { .id = $$.label, .tipo_traducao = $$.tipo_traducao };
                        $$.traducao = '\t' + $$.label + " = " + $1.traducao + ";\n";
                        
                    }
                    |
                    '(' OPERACAO_LOGICO ')'
                    {
                        $$.label = cria_nome_nova_temp();
                        $$.traducao= $2.traducao + '\t' + $$.label + " = " + $2.label + ";\n";
                        $$.tipo_traducao = $2.tipo_traducao;
                        $$.tipo = $2.tipo;
                        mapa_temporario[$$.label] = { .id = $$.label, .tipo_traducao = $$.tipo_traducao };
                    }
                    ;  

ATRIBUICAO      	:TK_ID TK_ATRIB TK_CHAR
                    {
                      //mapV mapa = buscaMapa($1.label);
                      $$.traducao = '\t' + retorna_var($1.label).temporario + " = " + $3.traducao + ";\n";
                    } 
                    /*
                    |
                    TK_ID TK_ATRIB TK_BOOL
                    {
                      //mapV mapa = buscaMapa($1.label);
                      $$.traducao = '\t' + mapa_variaveis[$1.label].temporario + " = " + $3.traducao + ";\n";
                    }
                    |*/
                    |
                    TK_ID TK_ATRIB E
                    {
                        /*
                        if(mapa_variaveis.find($2.label) == mapa_variaveis.end()){ 
                            yyerror("Variavel não foi declarada \n");
                        }
                        */
                        $1.tipo_traducao = retorna_var($1.label).tipo_traducao;
                        if($1.tipo_traducao != $3.tipo_traducao){
                            string variavel_cast = cria_nome_nova_temp();
                            if($1.tipo_traducao == "int"){
                                $$.tipo = "Int";
                                $$.tipo_traducao = "int";
                            	mapa_temporario[variavel_cast] = { .id = variavel_cast, .tipo_traducao = "int" };
                            	$$.traducao =  $3.traducao + "\t"  + variavel_cast + " = (int) " + $3.label + ";\n" +
															'\t' + retorna_var($1.label).temporario + " = " + variavel_cast + ";\n";
                            }else if($1.tipo_traducao == "float"){
                                $$.tipo = "Float";
                                $$.tipo_traducao = "float";
                                mapa_temporario[variavel_cast] = { .id = variavel_cast, .tipo_traducao = "float" };
                                $$.traducao =  $3.traducao +"\t" + variavel_cast + " = (float) " + $3.label + ";\n" +
                                '\t' + retorna_var($1.label).temporario + " = " + variavel_cast + ";\n";
                            }
                        } 
                      else{ 
                        $$.tipo_traducao = $3.tipo_traducao;
                        $$.tipo = $3.tipo;
                        $$.traducao =  $3.traducao + '\t' + retorna_var($1.label).temporario + " = " + $3.label + ";\n";
                      }
                      
                    }
  		    |
                    TK_ID TK_ATRIB OPERACAO_LOGICO
                    {	
                      $$.traducao = $3.traducao + '\t' + retorna_var($1.label).temporario + " = " + $3.label + ";\n";
                    }
                    |
                    TK_ID TK_ATRIB TK_CAST E
                    {
			/*
                            Tem que checar se o tipo do cast eh o msm do id
                        */
                        string variavel_cast= cria_nome_nova_temp(); 
                        mapa_temporario[variavel_cast] = { .id = variavel_cast, .tipo_traducao = $3.tipo_traducao };
                        $$.traducao =  $4.traducao +"\t" + variavel_cast +" = "+ $3.traducao + $4.label + ";\n" +
                        '\t' + retorna_var($1.label).temporario + " = " + variavel_cast + ";\n";
                    }
                    ;
        
IF                  : TK_IF '('OPERACAO_LOGICO ')'BLOCO 
                    ; 
%%

#include "lex.yy.c"

//FUNÇOES 
string cria_nome_nova_temp(){
	static int n = 0;
	n++;
    return "temp" + to_string(n);
}

/*
variavel cria_var(string nome_temp){
    variavel * var =  malloc(sizeof(variavel));
    var -> nome_temp = nome_temp;
	return var;
}*/

Variavel retorna_var( string label ){
    stack<Bloco> p = pilha_blocos;
    while (not p.empty()){
		    if (p.top().variaveis.find(label) != p.top().variaveis.end()) {
			      return p.top().variaveis.find(label) -> second;
		    }
	      p.pop();
	  }
	  yyerror("A variável "+ label + " não foi declarada.");
}

string declara_variaveis_temp(MapaTemp mapa_vars){
   	string s = "";
	for (MapaTemp::iterator it = mapa_vars.begin(); it!=mapa_vars.end(); ++it) {
    	s += '\t' + it->second.tipo_traducao + ' ' + it->second.id + ";\n";
	}
    return s;
}

MapaVar cria_mapavar(){ MapaVar m; return m; }
                           
int yyparse();

int main( int argc, char* argv[] )
{
	yyparse();
	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}	
