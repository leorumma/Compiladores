%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <vector>
#include <algorithm>
#include <map>

using namespace std;

struct Atributos {
    vector<string> c;
    int l;
};

#define  YYSTYPE Atributos

int yylex();
int yyparse();
void yyerror(const char *);

vector<string> concatena( vector<string> a, vector<string> b);
vector<string> operator+( vector<string> a, vector<string> b);
vector<string> operator+( vector<string> a, string b);
vector<string> operator+( string a, vector<string> b);

string gera_label( string prefixo );

void imprime( vector<string> codigo);
vector<string> resolve_enderecos( vector<string> entrada );

vector<string> novo;

int linha = 1, coluna = 1;
int token(int tk);

void generate_var(Atributos var);
void check_var(Atributos var);
map<string, int> vars;

%}

%token NUM ID LET STR IF ELSE WHILE FOR NEG MAIOR_IGUAL MENOR_IGUAL IGUAL DIFERENTE ARRAY OBJECT

%left '>' '<' '+' '-' '*' '/' MAIOR_IGUAL MENOR_IGUAL IGUAL DIFERENTE
%nonassoc IF ELSE WHILE FOR

//A gramatica vai começar aqui!!
%start S

%%

S   :   CMDs {
            imprime(resolve_enderecos($1.c));
        }
    ;

CMDs    :   CMD ';' CMDs {
                $$.c = $1.c + $3.c;
            }

        |   FLUXOCOMANDOS CMDs {
                $$.c = $1.c + $2.c;
            }

        |   {
                $$.c = novo;
            }
        ;

CMD :   ATRIBUIR {
            $$.c = $1.c + "^";
        }

    |   LET DECLVARs {
            $$ = $2;
        }
    ;

FLUXOCOMANDOS   :   IF '(' R ')' BODY OPT_ELSE {
                        string then = gera_label("then_if");
                        string end = gera_label("end_if");
                        $$.c = $3.c + "!" + then + "?" + $5.c + end + "#" + (":" + then) + $6.c + (":" + end);
                    }

                |   WHILE '(' E ')' BODY {
                      string end = gera_label("end_while");
                      string begin = gera_label("begin_while");
                      $$.c = novo + (":" + begin) + $3.c + "!" + end + "?" + $5.c + begin + "#" + (":" + end);
                    }

                |   FOR '(' CMD ';' R ';' ATRIBUIR ')' BODY {
                       string end = gera_label("end_for");
                       string begin = gera_label("begin_for");
                       $$.c = $3.c + (":" + begin) + $5.c + "!" + end + "?" + $9.c + $7.c + "^" + begin + "#" + (":" + end);
                    }
                ;

OPT_ELSE : ELSE BODY  { $$ = $2; }
		 |            { $$.c = novo; }
		 ;

BODY : CMD ';'     { $$ = $1; }
	 | BLOCK
	 | FLUXOCOMANDOS
	 ;

BLOCK : '{' CMDs '}' { $$ = $2; }
	  ;

DECLVARs : DECLVAR ',' DECLVARs {
                $$.c = $1.c + $3.c;
            }

         | DECLVAR {
            $$ = $1;
            }
         ;

DECLVAR : LVALUE '=' R {
                generate_var($1);
                $$.c = $1.c + "&" + $1.c + $3.c + "=" + "^";
          }

        | LVALUE {
            generate_var($1);
            $$.c = $1.c + "&";
          }
        ;

ATRIBUIR : LVALUE '=' ATRIBUIR {
                        check_var($1);
                        $$.c = $1.c + $3.c + "=";
                      }

         | LVALUEPROP '=' ATRIBUIR {
                $$.c = $1.c + $3.c + "[=]";
            }

         | R { $$ = $1; }
         ;

R   : E '<' E { $$.c = $1.c + $3.c + "<"; }
    | E '>' E { $$.c = $1.c + $3.c + ">"; }
    | E IGUAL E { $$.c = $1.c + $3.c + "=="; }
    | E MENOR_IGUAL E { $$.c = $1.c + $3.c + "<="; }
    | E MAIOR_IGUAL E { $$.c = $1.c + $3.c + ">="; }
    | E DIFERENTE E { $$.c = $1.c + $3.c + "!="; }
    | E { $$ = $1; }
    ;

E : LVALUE '=' E       { $$.c = $1.c + $3.c + "=" ; }
  | LVALUEPROP '=' E   { $$.c = $1.c + $3.c + "[=]"; }
  | E '+' E        { $$.c = $1.c + $3.c + "+"; }
  | E '-' E       { $$.c = $1.c + $3.c + "-"; }
  | E '*' E        { $$.c = $1.c + $3.c + "*"; }
  | E '/' E         { $$.c = $1.c + $3.c + "/"; }
  | '-' E         { $$.c = "0" + $2.c + "-"; }
  | LVALUE             { $$.c = $1.c + "@"; }
  | LVALUEPROP         { $$.c = $1.c + "[@]"; }
  | F                  { $$ = $1; }
  ;

LVALUE : ID
	   ;

LVALUEPROP : E '[' E ']'    { $$.c = $1.c + $3.c; }
		   | E '.' ID    { $$.c = $1.c + $3.c; }
		   ;

F : ID  {$$.c = $1.c + "@"; }
  | NUM {$$.c = $1.c; }
  | STR {$$.c = $1.c; }
  | '(' E ')' {$$ = $2; }
  | OBJECT { $$.c = novo + $1.c; }
  | ARRAY { $$.c = novo + $1.c; }
  ;

%%

#include "lex.yy.c"

void yyerror( const char* st ) {
    puts( st );
    printf( "Proximo a: %s\n", yytext );
}

vector<string> concatena( vector<string> a, vector<string> b ) {
  a.insert( a.end(), b.begin(), b.end() );
  return a;
}

vector<string> operator+( vector<string> a, vector<string> b) {
    return concatena( a, b);
}

vector<string> operator+( vector<string> a, string b) {
    a.push_back( b );
    return a;
}

vector<string> operator+( string a, vector<string> b) {
  vector<string> c;
  c.push_back(a);
  return c + b;
}

void generate_var(Atributos var){
  if(vars.count(var.c.back()) == 0){
	vars[var.c.back()] = var.l;
  }
  else {
	cout << "Erro: a variável '" << var.c.back() << "' já foi declarada na linha " << vars[var.c.back()] << "." << endl;
	exit(1);
  }
}

void check_var(Atributos var){
  if(vars.count(var.c.back()) == 0){
	cout << "Erro: a variável '" << var.c.back() << "' não foi declarada." << endl;
	exit(1);
  }
}

string gera_label( string prefixo ) {
  static int n = 0;
  return prefixo + "_" + to_string( ++n ) + ":";
}

vector<string> resolve_enderecos( vector<string> entrada ) {
  map<string,int> label;
  vector<string> saida;
  for( int i = 0; i < entrada.size(); i++ ) 
    if( entrada[i][0] == ':' ) 
        label[entrada[i].substr(1)] = saida.size();
    else
      saida.push_back( entrada[i] );
  
  for( int i = 0; i < saida.size(); i++ ) 
    if( label.count( saida[i] ) > 0 )
        saida[i] = to_string(label[saida[i]]);
    
  return saida;
}

void imprime( vector<string> codigo ) {
    for( int i = 0; i < codigo.size(); i++ ){
        cout << codigo[i] << endl;
    }
    cout << "." << endl;
}

int token(int tk) {
    yylval.c = novo + yytext;
    yylval.l = linha;
    coluna += strlen(yytext);
    return tk;
}

int main( int argc, char* argv[] ) {
  yyparse();
  return 0;
}