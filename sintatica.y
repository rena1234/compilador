%{
#include <iostream>
#include <string>
#include <fstream>
#include <cstdio>
#include <sstream>
#include <map>
#include <vector>

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
	string tipo;
	string nome_temp;
}variavel;

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

string declara_var_temp(){
    string s = ""

}
