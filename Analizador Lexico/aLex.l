%{
/*
	-Materia: Compiladores.

	-Grupo: 02.

	- Integrantes: 
		German Lopez Rodrigo.
		Lemuz Fuentes Omar Alejandro.

	- Descripción:
		El siguiente programa crea un Analizador Léxico utilizando
		estructuras de datos para la creacion de las Tablas y el uso
		de la herramienta Lex para utilizar expresiones regulares
		para validar que palabras son validas para el Analizador. 
*/
#include <stdio.h>
#include <stdlib.h>

FILE *tokens;
FILE *errores;
FILE *salida;
FILE *tablas;

/* Constantes Enteras utilizadas para llevar un control del Analizador Lexico.*/
int numlinea = 1, numcaracter = 0, numSymbol=0, numChain=0, numOpArit=0, numOpAsig=0,aux=-1;

/* Arreglo de Cadenas con las Palabras Reservadas*/
char *palabrasRerservadas[11] = {"Cadena","Bul","Cierto","Entero","Falso","Haz","Mientras","Para","Real","Si","Sino"};

/* Arreglo de Cadenas con los Operadores Relacionales*/
char *operadoresRelacionales[6] = {".DIF.",".IGL.",".MN.",".MNI.",".MY.",".MYI."};

/* Estructura de la Tabla de Simbolos*/
typedef struct s_nodo{
	int pos;
	char name[9];
	char tipo;
	struct s_nodo *siguiente;
	struct s_nodo *anterior;
} Symbol;

typedef Symbol *symbol_Nodo;
typedef Symbol *TSimbolos;

TSimbolos table_symbols = NULL;
TSimbolos table_OpArit = NULL;
TSimbolos table_OpAsig = NULL;

/* Estructura de la Tabla de Cadenas*/
typedef struct c_nodo{
	int pos;
	char *text;
	struct c_nodo *siguiente;
	struct c_nodo *anterior;
} Chain;

typedef Chain *chain_Nodo;
typedef Chain *TCadenas;

TCadenas table_Chains = NULL;

/* Funciones de la Tabla de Simbolos*/

/* Función que añade un nuevo identificador a la tabla de simbolos*/
void addSymbol(TSimbolos *tabla, int pos,char name[9]){
	symbol_Nodo nuevo, actual;
	/* Crear un nodo nuevo */
	nuevo = (symbol_Nodo)malloc(sizeof(Symbol));
	nuevo->pos = pos;
	strcpy(nuevo->name, name);

	/* Colocamos actual en la primera posición de la lista */
	actual = *tabla;

	if(actual) while(actual->anterior) actual = actual->anterior;
	/* Si la lista está vacía*/
	if(!actual) {
		/* Añadimos la lista a continuación del nuevo nodo */
		nuevo->siguiente = actual;
		nuevo->anterior = NULL;
		if(actual) actual->anterior = nuevo;
		if(!*tabla) *tabla = nuevo;
	}
	else {
		while(actual->siguiente) actual = actual->siguiente;
		/* Insertamos el nuevo nodo después del nodo anterior */
		nuevo->siguiente = actual->siguiente;
		actual->siguiente = nuevo;
		nuevo->anterior = actual;
		if(nuevo->siguiente) nuevo->siguiente->anterior = nuevo;
	}
}

/* Función que verifica si existe un identificador en la tabla de simbolos.*/
int searchSymbol(TSimbolos tabla,char name[9]){
	symbol_Nodo nodo = tabla;
	while(nodo != NULL){
		if(strcmp(name, nodo->name) != 0)	
			nodo = nodo->siguiente;
		else
			return nodo->pos;
	}
	return -1;
}

/* Función para mostrar la Tabla de Simbolos de forma legible en un archivo.*/
void showTableSymbols(TSimbolos tabla){
	symbol_Nodo nodo = tabla;

	if(tabla){
		nodo = tabla;
		while(nodo->anterior) nodo = nodo->anterior;
		fprintf(tablas,"Tabla de identificadores:\t\n");
		fprintf(tablas,"----------------------------------------------\n");
		fprintf(tablas,"   Posición\tIdentificador\tTipo\n");
		while(nodo) {
			fprintf(tablas,"     %d\t\t%s\t%c\n", nodo->pos,nodo->name,nodo->tipo);
			nodo = nodo->siguiente;
		}
		fprintf(tablas,"\n\n");
	}
}

/* Funciones de la Tabla de Cadenas*/

/* Función que añade una nueva cadena a la tabla de Cadenas*/
void addChain(TCadenas *tabla, int pos,char *text) {
	chain_Nodo nuevo, actual;

	/* Crear un nodo nuevo */
	nuevo = (chain_Nodo)malloc(sizeof(Chain));
	nuevo->pos = pos;
	nuevo->text= (char *)malloc(strlen(text) * sizeof(char));
	strcpy(nuevo->text, text);
	/* Colocamos actual en la primera posición de la lista */
	actual = *tabla;

	if(actual) while(actual->anterior) actual = actual->anterior;
	/* Si la lista está vacía*/
	if(!actual) {
		/* Añadimos la lista a continuación del nuevo nodo */
		nuevo->siguiente = actual;
		nuevo->anterior = NULL;
		if(actual) actual->anterior = nuevo;
		if(!*tabla) *tabla = nuevo;
	}
	else {
	while(actual->siguiente)
		actual = actual->siguiente;
		/* Insertamos el nuevo nodo después del nodo anterior */
		nuevo->siguiente = actual->siguiente;
		actual->siguiente = nuevo;
		nuevo->anterior = actual;
		if(nuevo->siguiente) nuevo->siguiente->anterior = nuevo;
	 }
}

/* Función para mostrar la Tabla de Cadenas de forma legible en un archivo.*/
void showTableChains(TCadenas tabla){
	chain_Nodo nodo = tabla;

	if(tabla){
		nodo = tabla;
		while(nodo->anterior) nodo = nodo->anterior;
		fprintf(tablas,"Tabla de Cadenas:\t\n");
		fprintf(tablas,"----------------------------------------------\n");
		fprintf(tablas,"  Posición\t\tTexto\n");
		while(nodo) {
			fprintf(tablas,"     %d\t\t%s\n", nodo->pos,nodo->text);
			nodo = nodo->siguiente;
		}
		fprintf(tablas,"\n\n");
	}
}

/* Funciones Para Imprimir las Tablas*/

/* Función para mostrar la Tabla de Palabras Reservadas de forma legible en un archivo.*/
void showTablePalRes(){
	fprintf(tablas,"Tabla de palabras reservadas:\t\n");
	fprintf(tablas,"----------------------------------------------\n");
	fprintf(tablas,"   Posición\tPalabra reservadas\n");
	fprintf(tablas,"   \t0\tBul\t\n");
	fprintf(tablas,"   \t1\tCadena\t\n");
	fprintf(tablas,"   \t2\tCierto\t\n");
	fprintf(tablas,"   \t3\tEntero\t\n");
	fprintf(tablas,"   \t4\tFalso\t\n");
	fprintf(tablas,"   \t5\tHaz\t\n");
	fprintf(tablas,"   \t6\tMientras\t\n");
	fprintf(tablas,"   \t7\tPara\t\n");
	fprintf(tablas,"   \t8\tReal\t\n");
	fprintf(tablas,"   \t9\tSi\t\n");
	fprintf(tablas,"   \t10\tSino\t\n");
	fprintf(tablas,"\n\n");
}

/* Función para mostrar la Tabla de Operadores Relacionales de forma legible en un archivo.*/
void showtableOpRel(){
	fprintf(tablas,"Tabla de operadores relacionales:\t\n");
	fprintf(tablas,"----------------------------------------------\n");
	fprintf(tablas,"   Posición\tPalabra reservadas\n");
	fprintf(tablas,"   \t0\t.DIF.\t\n");
	fprintf(tablas,"   \t1\t.IGL.\t\n");
	fprintf(tablas,"   \t2\t.MN.\t\n");
	fprintf(tablas,"   \t3\t.MNI.\t\n");
	fprintf(tablas,"   \t4\t.MY.\t\n");
	fprintf(tablas,"   \t5\t.MYI.\t\n");
	fprintf(tablas,"\n\n");
}

/* Función para mostrar la Tabla de Operadores Aritmeticos de forma legible en un archivo.*/
void showTableOpArit(TSimbolos tabla){
	symbol_Nodo nodo = tabla;
	if(tabla){
		nodo = tabla;
		while(nodo->anterior) nodo = nodo->anterior;
		fprintf(tablas,"Tabla de operadores aritméticos:\t\n");
		fprintf(tablas,"----------------------------------------------\n");
		fprintf(tablas,"   Posición\tOperador aritmético\n");
		while(nodo) {
			fprintf(tablas,"     %d\t\t%s\t%c\n", nodo->pos,nodo->name,nodo->tipo);
			nodo = nodo->siguiente;
		}
		fprintf(tablas,"\n\n");
	}
}

/* Función para mostrar la Tabla de Operadores de Asignacion de forma legible en un archivo.*/
void showTableOpAsig(TSimbolos tabla){
	symbol_Nodo nodo = tabla;
	if(tabla){
		nodo = tabla;
		while(nodo->anterior) nodo = nodo->anterior;
		fprintf(tablas,"Tabla de operadores de asignación:\t\n");
		fprintf(tablas,"----------------------------------------------\n");
		fprintf(tablas,"   Posición\tOperador de asignación\n");
		while(nodo) {
			fprintf(tablas,"     %d\t\t%s\t%c\n", nodo->pos,nodo->name,nodo->tipo);
			nodo = nodo->siguiente;
		}
		fprintf(tablas,"\n\n");
	}
}

%}

dig [0-9]
letrasAny [a-zA-Z]
coment \$\$.*\n
palRes Bul|Cadena|Cierto|Entero|Falso|Haz|Mientras|Para|Real|Si|Sino
ident [a-z]{letrasAny}{1,7}
simbEsp [\(|\)|\,|\[|\]|\;|\{|\}]
opAsig ([:|+|\-|*|\/|&|\^|!|%]|[<<|>>]{2,2})=
opRel \.DIF\.|\.IGL\.|\.MN.|\.MNI\.|\.MY.|\.MYI\.
opArit [+|\-|*|\/|%|=]
cteNumEntera {dig}+
cteNumFloat {dig}*\.{dig}+
cteNumFloat2 {dig}+\.{dig}*
cteNumScie ({cteNumFloat}|{cteNumFloat}|{cteNumEntera})[E|e][+|\-]?{dig}+
cteNumReal ({cteNumFloat}|{cteNumFloat2}|{cteNumScie})
cteCadena \x22.*\x22
salto \n
space \t|" "
error .

%%

{palRes} {
			/* Se busca la posición de la palabra reservada detectada*/
			for (int i = 0; i < 11;i++){
				if(strncmp(yytext, palabrasRerservadas[i], yyleng) == 0){
					fprintf(tokens,"0,%d\n",i);
					break;
				}
			}
				
			numcaracter = numcaracter + yyleng;
		 }

{ident} {
			/*Se busca si existe el identificador en la tabla de Simbolos, si existe regresa su posición*/
			aux = searchSymbol(table_symbols,yytext);
			if(aux == -1){
				addSymbol(&table_symbols,numSymbol++,yytext);
				aux = numSymbol-1;
			}
			fprintf(tokens,"1,%d\n",aux);
			numcaracter = numcaracter + yyleng;
		}

{simbEsp} {
			fprintf(tokens,"2,%c\n", yytext[0]);
			numcaracter = numcaracter + yyleng;
		  }

{opAsig} {
			/*Se busca si existe el operador de asignacion en la tabla de Operadores de Asignacipon, si existe regresa su posición*/
			aux = searchSymbol(table_OpAsig,yytext);
			if(aux == -1){
				addSymbol(&table_OpAsig,numOpAsig++,yytext);
				aux = numOpAsig-1;
			}
			fprintf(tokens,"3,%d\n",aux);
			numcaracter = numcaracter + yyleng;
		 }	

{opRel}  {
			/* Se busca la posición del Operador Relacional detectado*/
			for (int i = 0; i < 7;i++)
				if(strncmp(yytext, operadoresRelacionales[i], yyleng) == 0)
					fprintf(tokens,"4,%d\n",i);
			
			numcaracter = numcaracter + yyleng;
		 }

{opArit} {
			/*Se busca si existe el operador aritmético  en la tabla de Operadores Aritméticos, si existe regresa su posición*/
			aux = searchSymbol(table_OpArit,yytext);
			if(aux == -1){
				addSymbol(&table_OpArit,numOpArit++,yytext);
				aux = numOpArit-1;
			}
			fprintf(tokens,"5,%d\n", aux);
			numcaracter = numcaracter + yyleng;
		 }

{cteCadena} {
				/* Se añade la nueva cadena detectada en la Tabla de Cadenas*/
				addChain(&table_Chains,numChain++,yytext);
				fprintf(tokens,"6,%d\n",numChain-1);
				numcaracter = numcaracter + yyleng;
			}

{cteNumEntera}	{
					fprintf(tokens,"7,%s\n",yytext);
					numcaracter = numcaracter + yyleng;
				}

{cteNumReal} {
				fprintf(tokens,"8,%s\n",yytext);
				numcaracter = numcaracter + yyleng;
			 }		

{coment}	{numcaracter = numcaracter + yyleng;}

{space}		{numcaracter = numcaracter + yyleng;}

{salto}	numlinea++; numcaracter = 0;

{error}	{fprintf(errores, "Error => %s encontrado en la linea %d, columna %d\n", yytext, numlinea, numcaracter); numcaracter = numcaracter + yyleng;}
%%

int main(int argc, char *argv[]){
	yyin = fopen(argv[1], "r");
	tokens = fopen("tokens.txt", "w");
	errores = fopen("errores.txt", "w");
	tablas = fopen("tablas.txt", "w");
	yylex();
	showTablePalRes();
	showtableOpRel();
	showTableSymbols(table_symbols);
	showTableChains(table_Chains);
	showTableOpArit(table_OpArit);
	showTableOpAsig(table_OpAsig);
	fclose(tokens);
	fclose(errores);
	fclose(tablas);
	return 0;
}