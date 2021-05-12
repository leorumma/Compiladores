#include <stdio.h>
#include <string>

using namespace std;

// enum TOKEN { _ID = 256, _FOR, _IF, _INT, _FLOAT, _MAIG, _MEIG, _IG, _DIF, _STRING, _COMENTARIO };

extern "C" int yylex();  
extern "C" FILE *yyin;

void yyerror(const char* s);  

#include "lex.yy.c"

auto p = &yyunput; // Para evitar uma warning de 'unused variable'

int main() {
  token = next_token();
  S();  
  return 0;
}