%{
#include <stdio.h>
#include <string>

using namespace std;

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
  return _INT; 
  }

{FLOAT} { 
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

{STRING}  {
  return _STRING;
  }

{COMENTARIOMULTILINE}  {
    return _COMENTARIO;
  }

{COMENTARIOSINGLELINE}  { 
  return _COMENTARIO; 
  }

{ID}  { 
  return _ID; 
  }

. { 
  return yytext[0]; 
  }

%%