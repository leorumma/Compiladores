%{
#include <stdio.h>
#include <string>
#include <iostream>


using namespace std;

enum TOKEN { _ID = 256, _FOR, _IF, _INT, _FLOAT, _MAIG, _MEIG, _IG, _DIF, _STRING, _COMENTARIO, _PRINT };

string lexema;

int token;

void print( string st );

void F();

void A();

void S();

void C();

void E_linha();

void casa( int esperado );

void T();

void E();

void P();

void T_linha();

int main();

void erro( const char* msg );

%}

D	[0-9]
L	[A-Za-z_]

WS  [ \t\n]
IF [iI][fF]
FOR [fF][oO][rR]
INT {D}+
FLOAT   {INT}("."{INT})?([Ee]("+"|"-")?{INT})?
ID  ("_"|"$"|{L})({L}|{D}|"_"|"$")*
MAIG ">="
MEIG "<="
IG "=="
DIF "!="
STRING  \"(\"\"|\\.|[^"\\])*\"
COMENTARIOMULTILINE "/*"([^*]|\*+[^*/])*\*+"/"
COMENTARIOSINGLELINE  "//"[^\r\n]*

%%
    
{WS}	{ 
  /* ignora espaço */ 
  }    

{IF}	{ 
  return _IF; 
  }

{FOR}   { 
  return _FOR;
  }

{INT} { 
  lexema = yytext;
  return _INT; 
  }

{FLOAT} { 
  lexema = yytext; 
  return _FLOAT; 
  }

{MAIG}  { 
  return _MAIG; 
  }

{MEIG}  { 
  return _MEIG; 
  }

{IG}  { 
  return _IG; 
  }

{DIF} { 
  return _DIF; 
  }

"print" {
  lexema = yytext; 
  return _PRINT;
  }

{STRING}  {
  lexema = yytext; 
  return _STRING;
  }

{COMENTARIOMULTILINE}  {
    return _COMENTARIO;
  }

{COMENTARIOSINGLELINE}  { 
  return _COMENTARIO; 
  }

{ID}  {
  lexema = yytext; 
  return _ID; 
  }

. { 
  return yytext[0]; 
  }
  
%%

/*
  GRAMÁTICA:

  S -> C ; S | ε

  C -> A | P

  A  -> id { Print( lexema ); } = E { Print( "="); }

  P -> print E 

  E -> T E'
  E' -> + T E' 
       | -T E' 
       | ε 

  T -> F T'
  T' -> * F T' | / F T' | ε

  F -> id    { Print( lexema ); casa( ID); }
     | num
     | str
     | ( E )

Entrada:    a = a + 1;

a a @ 1 + =

*/

void erro( string msg ) {
  cout << "Erro: Funcao não definida:" << msg << endl;
  exit( 1 );
}

int next_token() {
  return yylex();
}

void casa( int esperado ) {
  if( token == esperado )
    token = next_token();
}


void E_linha() {
   switch( token ) {
     case '+' : casa( '+' ); T();  print( "+" ); E_linha(); break;
     case '-' : casa( '-' ); T();  print( "-" ); E_linha(); break;
   } 
  return;
}


void print( string st ) {
  cout << st << " ";
}

void F() {
  switch( token ) {
    case _ID: print( lexema  + "  @" );  casa(_ID); break;
    case _INT: print( lexema ); casa(_INT); break;
    case _FLOAT: print( lexema ); casa(_FLOAT); break;
    case _STRING: print( lexema ); casa( _STRING); break;
    case '(': 
        casa( '(' );    
        E(); 
        casa( ')' ); 
        break;
    default:
      erro (lexema);
  }
}

void A() {
  print( lexema ); 
  casa(_ID );
  casa( '=' );
  E();
  print( "=");
}

void S() {
  if( token ==_ID || token == _PRINT ) {
    C();
    casa( ';' );
    S();
  }
  else
    return;
}

void C() {
  if( token ==_ID )
    A();
  else
    P();
}

void T() {
  F();
  T_linha();
}

void E() {
  T();
  E_linha();
}

void P() {
 casa(_PRINT);
 E();
 print( "print" );
 print( "#" );
}

void T_linha() {
  switch( token ) {
    case '*' : casa( '*' ); F(); print( "*"); T_linha(); break;
    case '/' : casa( '/' ); F(); print( "/"); T_linha(); break;
  }
}

auto p = &yyunput;

int main() {
  token = next_token();
  S();  
  return 0;
}