all: 	
		clear
		lex lexica.l
		yacc --verbose --debug -d sintatica.y
		g++ -std=c++0x -o glf y.tab.c -lfl

		./glf < exemplo.rj | tee log
