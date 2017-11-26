%{
#include <iostream>
#include <string>
#include <string.h>
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
  int tamanho;
}Variavel;

typedef struct
{
  string id;
  string tipo_traducao;
  bool tipo_atribuido;
}VariavelTemporaria;

typedef map<string, Variavel> MapaVar;
typedef map<string, VariavelTemporaria> MapaTemp;
typedef struct BLOCO
{
  bool quebravel;
  MapaVar variaveis;
  string rotulo_inicio;
  string rotulo_fim;
}Bloco;
typedef struct FUNCAO
{
    string nome_temporario;
    string tipo_traducao;
}Funcao;
static MapaVar mapa_variaveis;
static MapaTemp mapa_temporario;
static stack <Bloco> pilha_blocos; 
  
  
int yylex();
void yyerror(string);
string cria_nome_nova_temp();
string cria_nome_novo_rotulo();
string cria_nome_nova_funcao();
string declara_variaveis_temp(MapaTemp mapa_vars);
MapaVar cria_mapavar();
Variavel retorna_var(string label);
%}
%token TK_NUM TK_CHAR TK_ID TK_BOOL TK_STRING TK_VAR
%token TK_MAIN TK_TIPO_INT TK_TIPO_BOOL TK_TIPO_FLOAT TK_TIPO_CHAR TK_TIPO_STRING
%token TK_SOMA_ou_SUBTRACAO TK_DIVISAO_ou_MULTIPLICACAO
%token TK_MENOR_QUE TK_MAIOR_QUE TK_IGUAL TK_DIFERENTE TK_MENOR_IGUAL TK_LOGICO
%token TK_ATRIB TK_CAST TK_GLOBAL
%token TK_BEGIN TK_END TK_ERROR
%token TK_IN_OUT TK_CASE TK_SWITCH TK_BREAK TK_RETURN
%start S
//precedencia de operações
%left TK_RELACIONAL
%left TK_LOGICO
%left TK_SOMA_ou_SUBTRACAO
%left TK_DIVISAO_ou_MULTIPLICACAO
%nonassoc TK_IF
%nonassoc TK_ELSE
%nonassoc TK_FOR
%nonassoc TK_WHILE
%nonassoc TK_DO
%%
  
  /*
      VC TEM QUE FZR UMA CHECAGEM ANTES DE INICIAR UMA FUNCAO, TEM QUE VER SE A PILHA DE MAPAS SÒ TEM UM MAPA
  */
/*S         : TK_TIPO_INT TK_MAIN '('')'BLOCO
        {
          cout << "//Compilador Frankenstein/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << declara_variaveis_temp(mapa_temporario) << $5.traducao << "\n\treturn 0;\n}" << endl; 
        };*/
  
S         : ESCOPO_GLOBAL COMANDOS
          {
            cout << "//Compilador Frankenstein/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\n" << declara_variaveis_temp(mapa_temporario) << $2.traducao << "\n\treturn 0;\n}" << endl;
          /*
            declarar funções aqui tbm
          */
          }
        ;
ESCOPO_GLOBAL:
          {
              //EMPILHAR BLOCO para o main
                pilha_blocos.push({ .quebravel = false, .variaveis = cria_mapavar()});
          }
        ;
TIPO    : TK_TIPO_INT | TK_TIPO_BOOL | TK_TIPO_FLOAT | TK_TIPO_CHAR;
ELEMENTO       : TK_NUM | TK_BOOL | TK_CHAR;
DECLARACOES_GLOBAL    : DECLARACAO_GLOBAL DECLARACOES_GLOBAL
                      |
                      {
                          $$.traducao = "";
                      }
                      ;
DECLARACAO_GLOBAL    : TIPO TK_ID '=' ELEMENTO ';' 
                     {
                         
                     
                     }
                     ;
ARGUMENTO    : TIPO TK_ID ARGUMENTO_AUX
             {
                 $$.tipo = $1.tipo;
                 $$.tipo_traducao = $1.tipo_traducao;
                 $$.traducao = $1.tipo_traducao + " " + $2.label;
                 string argumento = cria_nome_nova_temp();
                 mapa_temporario[$2.label] = { .id = argumento,
                            .tipo_traducao = "float" };
                 pilha_blocos.top().variaveis[$2.label] = { .id = $2.label,
                        .tipo_traducao = $1.tipo_traducao, argumento };
             }
             ;
ARGUMENTO_AUX    : ',' ARGUMENTO
                 |
                 ;
EMPILHA_FUNCAO    :
                  {
                        if( pilha_blocos.size() > 0 ){
                            /*
                                DISPARAR ERRO AQUI
                            */
                        }
                        pilha_blocos.push({ .quebravel = false, .variaveis = cria_mapavar()});
                  }
                  ;
BLOCO     : '{' COMANDOS '}'
        {
              $$.traducao = $2.traducao; //todos os comandos sendo atribuido em $$
        };
FUNCAO    : TIPO TK_ID EMPILHA_FUNCAO'(' ARGUMENTOS ')' BLOCO
          {
              string nome_temp = cria_nome_nova_funcao();
              $$.traducao = $1.tipo_traducao + " (" + $4.traducao + ")" +"\n"
                +"{\n" + $6.traducao + "\n}";
              pilha_blocos.pop();
          }
          ;
COMANDOS  : COMANDO COMANDOS
        {
          $$.traducao = $1.traducao + $2.traducao; //um comando(expressao)
        }
        |
        {
          $$.traducao = ""; //EOF
        }
        ;
COMANDO     : DECLARACAO ';'
              | ATRIBUICAO ';'
              | IF
              | WHILE
              | DO_WHILE ';'
              | IN_OUT  ';'
              ;
ARGUMENTOS    : ARGUMENTO ARGUMENTOS_ADICIONAIS
ARGUMENTOS_ADICIONAIS :
                      | ',' ARGUMENTOS
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
                $$.tipo_traducao = "char *";
                pilha_blocos.top().variaveis[$2.label] = { .id = $2.label,
                        .tipo_traducao = $$.tipo_traducao, $$.label };
                mapa_temporario[$$.label] = { .id = $$.label,
                        .tipo_traducao = $$.tipo_traducao };
          
                $$.traducao = "\t" + retorna_var($2.label).temporario 
                        + " = " + $4.label +";" + "\n";
          }
      | TK_TIPO_STRING TK_ID
      {
         if(mapa_variaveis.find($2.label) != mapa_variaveis.end()){ 
                yyerror("Variavel já foi declarada \n");
            }
        $$.label = cria_nome_nova_temp();
        $$.tipo = "String";
        $$.tipo_traducao = "char *";
        mapa_temporario[$$.label] = { .id = $$.label,
                        .tipo_traducao = $$.tipo_traducao };
        pilha_blocos.top().variaveis[$2.label] = { .id = $2.label,
                        .tipo_traducao = $$.tipo_traducao, $$.label };
        $$.traducao = "";
      }
      | TK_TIPO_STRING TK_ID TK_ATRIB OP_STRING
      {
          if(mapa_variaveis.find($2.label) != mapa_variaveis.end()){ 
                    yyerror("Variavel já foi declarada \n");
                }

                $$ = $4;
                pilha_blocos.top().variaveis[$2.label] = { .id = $2.label,
                        .tipo_traducao = $$.tipo_traducao, .temporario = $$.label, .tamanho = $4.tamanho};
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
          | TK_VAR TK_ID 
      {
         if(mapa_variaveis.find($2.label) != mapa_variaveis.end()){ 
              yyerror("Variavel já foi declarada \n");
          }
          
          $$.label = cria_nome_nova_temp();
          $$.tipo = "";
          $$.tipo_traducao = "";
          pilha_blocos.top().variaveis[$2.label] = { .id = $2.label,
                        .tipo_traducao = $$.tipo_traducao, $$.label };
          $$.traducao = "\t"+$$.tipo_traducao + " " + $$.label + ";"+"\n";  
      }
      ;
OP_STRING       : CONCATENA
                ;
CONCATENA       : ST
                | ST 'm' ST
                {
                     
                     if($1.tipo == "String" && $3.tipo == "String"){
                         $$.label = cria_nome_nova_temp();
                         $$.tipo = "String";
                         $$.tipo_traducao = "char *";
                
                         mapa_temporario[$$.label] = { .id = $$.label,
                             .tipo_traducao = $$.tipo_traducao };
                         int tamanho_novo = $1.tamanho + $3.tamanho;
                         $$.traducao = "\t" + $$.label + " = "
                             + "malloc(" + to_string(tamanho_novo) + "* sizeof(" + $$.label + "));\n"
                             + "\t$$.label = strcat(" + $$.label +"," + $1.label + ");\n"
                             + "\t$$.label = strcat(" + $$.label +"," + $3.label + ");\n"
                             ;        
                     }

                }
                ;

ST            : TK_STRING
                {
                    $$.label = cria_nome_nova_temp();
                    $$.tipo = "String";
                    $$.tipo_traducao = "char *";
                
                    mapa_temporario[$$.label] = { .id = $$.label,
                           .tipo_traducao = $$.tipo_traducao };
          
                    $$.traducao = "\t" + $$.label + " = "
                    + "\"" + $1.label + "\";" ;
                }
                ;

E       :  OPERACAO_ARITMETICA 

        ;
OPERACAO_ARITMETICA:E TK_SOMA_ou_SUBTRACAO E
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
OPERACAO_RELACIONAL : E TK_RELACIONAL E
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
OPERACAO_LOGICO   : OPERACAO_LOGICO TK_LOGICO OPERACAO_LOGICO
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
ATRIBUICAO        :TK_ID TK_ATRIB TK_CHAR
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
                        } else if($1.tipo_traducao == ""){ //TIPO VAR 
                                $$.tipo = "Var";
                                $$.tipo_traducao = $3.tipo_traducao;
                                $$.traducao = '\t' + retorna_var($1.label).temporario + " = " + $3.traducao + ";\n";
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
        
IF                  : TK_IF '('OPERACAO_LOGICO ')'EMPILHA_IF BLOCO{
                        string nega_cond = cria_nome_nova_temp();
                        string rotulo_fim = cria_nome_novo_rotulo();
                        mapa_temporario[nega_cond] = { .id = nega_cond, .tipo_traducao = "bool" };
                        $$.traducao = $3.traducao + "\t" + nega_cond + " =! "+$3.label+";\n"
                                + "\t" + "if(" + nega_cond + ")"  + "\t" "goto " + rotulo_fim + ";\n"
                                + $6.traducao + "\n" + "\t" + rotulo_fim + ":"; 
                        pilha_blocos.pop();
                    }
                    | TK_IF '('OPERACAO_LOGICO')'EMPILHA_IF BLOCO TK_ELSE EMPILHA_ELSE BLOCO
                    { //If(a<b){}Else{}
                        string nega_cond = cria_nome_nova_temp();
                        string rotulo_fim = cria_nome_novo_rotulo();
                        string rotulo_fim_else = cria_nome_novo_rotulo();
                        mapa_temporario[nega_cond] = { .id = nega_cond, .tipo_traducao = "bool" };
                        $$.traducao = $3.traducao + "\t" + nega_cond + " =!" + $3.label + ";\n"
                                + "\t" + "if(" + nega_cond + ")"  + "\t" "goto " + rotulo_fim + ";\n"
                                + $6.traducao + "\t" + rotulo_fim + ":"
                                + "\n\tif (" + $3.label + ")\tgoto " + rotulo_fim + ";\n"+ $9.traducao 
                                + "\t" + rotulo_fim_else + ":\n" ; 
                        pilha_blocos.pop();
                    }
                    | TK_IF '('OPERACAO_LOGICO')'EMPILHA_IF BLOCO TK_ELSE IF
                    {    string nega_cond = cria_nome_nova_temp();
                        string rotulo_fim = cria_nome_novo_rotulo();
                        string rotulo_fim_else = cria_nome_novo_rotulo();
                        mapa_temporario[nega_cond] = { .id = nega_cond, .tipo_traducao = "bool" };
                        $$.traducao = $3.traducao + "\t" + nega_cond + " =!" + $3.label + ";\n"
                                + "\t" + "if(" + nega_cond + ")"  + "\t" "goto " + rotulo_fim + ";\n"
                                + $6.traducao + "\t" + rotulo_fim + ":"
                                + "\n\tif (" + $3.label + ")\tgoto " + rotulo_fim + ";\n"+ $8.traducao; 
                        pilha_blocos.pop();
                    }
                    | TK_IF '('TK_ID')'EMPILHA_IF BLOCO
                    {
                     //checar se tk_id é bool
                        string nega_cond = cria_nome_nova_temp();
                        string rotulo_fim = cria_nome_novo_rotulo();
                        mapa_temporario[nega_cond] = { .id = nega_cond, .tipo_traducao = "bool" };
                        $$.traducao ="\t" + nega_cond + "!=" + retorna_var($3.label).temporario
                                + ";\n\tif(" + nega_cond + ")"  + "\t" "goto " + rotulo_fim + ";\n"
                                + $6.traducao + "\t" + rotulo_fim + ":"; 
                        pilha_blocos.pop();
                    }
                    | TK_IF '('TK_ID')'EMPILHA_IF BLOCO TK_ELSE EMPILHA_ELSE BLOCO
                    { //If(a<b){}Else{}
                        string nega_cond = cria_nome_nova_temp();
                        string rotulo_fim = cria_nome_novo_rotulo();
                        string rotulo_fim_else = cria_nome_novo_rotulo();
                        mapa_temporario[nega_cond] = { .id = nega_cond, .tipo_traducao = "bool" };
                        $$.traducao = "\tif(" + nega_cond + ")" + "\t" "goto " + rotulo_fim + ";\n"
                                + $6.traducao + "\t" + rotulo_fim + ":"
                                + "\n\tif (" + $3.label + ")\tgoto " + rotulo_fim + ";\n"+ $9.traducao 
                                + "\t" + rotulo_fim_else + ":\n" ; 
                        pilha_blocos.pop();
                    }
                    ;
                    ;
EMPILHA_IF          :
                    {
                      pilha_blocos.push({ .quebravel = false, .variaveis = cria_mapavar()});
                                         
                    }
                    ;
EMPILHA_ELSE          :
                      {
                        pilha_blocos.pop();
                        pilha_blocos.push({ .quebravel = false, .variaveis = cria_mapavar()});
                      }
                      ;
WHILE                 : TK_WHILE '('OPERACAO_LOGICO')' EMPILHA_WHILE_FOR BLOCO
                      {
                          string rotulo_inicio_while = cria_nome_novo_rotulo();
                          string rotulo_fim_while = cria_nome_novo_rotulo();
                          string nega_cond = cria_nome_nova_temp();
                          mapa_temporario[nega_cond] = { .id = nega_cond, .tipo_traducao = "bool" };
                          $$.traducao = $3.traducao + "\t" + nega_cond + " =! $3.label;" "\n"
                                  + "\t" + "if(" + nega_cond + ")"  + "\t" "goto " + rotulo_fim_while + ";\n\t"
                                  + rotulo_inicio_while + ":\n" + $6.traducao + "\t" + "if(" + $3.label +")\t goto " 
                                  + rotulo_inicio_while + ";\n\t" + rotulo_fim_while + ":";
                          pilha_blocos.pop();
                      }
                      ;

DO_WHILE              : TK_DO BLOCO TK_WHILE '('OPERACAO_LOGICO')' EMPILHA_WHILE_FOR
                      {
                          string rotulo_inicio_while = cria_nome_novo_rotulo();
                          string nega_cond = cria_nome_nova_temp();
                          mapa_temporario[nega_cond] = { .id = nega_cond, .tipo_traducao = "bool" };
                          $$.traducao = "\t" + rotulo_inicio_while + ":\n" + $2.traducao + "\t"  
                                  + "if(" + $5.label +")\t goto " 
                                  + rotulo_inicio_while + ";\n";
                          pilha_blocos.pop();
                      }

EMPILHA_WHILE_FOR     :
                      {
                        pilha_blocos.push({ .quebravel = true, .variaveis = cria_mapavar()});
                      }
                      
FOR                   : TK_FOR '(' ATRIBUICAO ';' OPERACAO_LOGICO ';' ATRIBUICAO ')' EMPILHA_WHILE_FOR BLOCO 
                      {
                        //verificar se todos os tk_id são iguais
                          if($3.label != $5.label || $3.label != $7.label || $5.label != $7.label){ yyerror();}
          
                          string i = cria_nome_nova_temp();
                          mapa_temporario[i] = {.id = $3.label , .tipo = Bool};
    
                          pilha_blocos.top().variaveis[i] = ({ .id = "i" , .tipo_traducao = $3.tipo_traducao})
                          pilha_blocos.push({ .quebravel = true, .variaveis = cria_mapavar()});
                          $$.traducao = $1.label + "  (" + $3.traducao + "  ;" + $5.traducao + "  ;" + $7.traducao + " ){" + "\n" 
                          + "";
                          pilha_bloco.pop();
                      }

SWITCH                : TK_SWITCH '('VARIAVEL_SWITCH')''{'BLOCO_CASE'}'
                      {
                        $$.traducao = $3.traducao + $6.traducao + "\n";
  				              pilha_bloco.pop();
                      }

VARIAVEL_SWITCH       : TK_ID
                      {
                        /*
                        MapaVar mapa_var = retorna_var($1.label); 
                        string i = cria_nome_nova_temp();
                        mapa_temporario[i] = {.id = $3.label , .tipo = mapa_var[$1.label].tipo};
                        $$.traducao = mapa_var;
                        */
                      }

BLOCO_CASE            : CASE CASE_ADICIONAIS
                      {
                        $$.traducao = $1.traducao + $2.traducao;
                      }
                      | CASE
                      {
                        $$.traducao = $1.traducao;
                      }
                      | DEFAULT
                      {
                        $$.traducao = $1.traducao;
                      }

CASE                  : TK_CASE TK_NUM ':' COMANDOS
                      {
                        /*string rotulo = cria_nome_novo_rotulo(); 
  
                        $$.traducao = "\tif(" + $2.label  ")"  + "\t" "goto " + rotulo + ";\n"
                                + $6.traducao + "\t" + rotulo + ":";
                        */ 
                      }

CASE_ADICIONAIS       :
                      {
                      }
DEFAULT               :
                      {

                      }

IN_OUT      :TK_IN_OUT '(' TK_ID ')'
      {
          
          if($1.label == "Scan"){
        
              Variavel var = retorna_var($3.label);
              string tempLabel = var.temporario;
              $$.traducao = "\tcin >> " + tempLabel + ";";
          }
          else if ($1.label == "Print"){
              Variavel var = retorna_var($3.label); 
              string tempLabel = var.temporario;
              $$.traducao = $1.traducao + $3.traducao + "\t"
                    + "cout<< " + tempLabel + " << endl;\n\n";
        }
      }
      ;

%%
#include "lex.yy.c"
//FUNÇOES 
string cria_nome_nova_temp(){
  static int n = 0;
  n++;
    return "temp" + to_string(n);
}
string cria_nome_novo_rotulo(){
  static int n = 0;
  n++;
  return "rotulo" + to_string(n);
}
string cria_nome_nova_funcao(){
  static int n = 0;
  n++;
  return "funcao" + to_string(n);
}
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
  for (MapaTemp::iterator it = mapa_vars.begin(); it!=mapa_vars.end(); ++it){
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