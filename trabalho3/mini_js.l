DELIM [\t\n ]
DIGITO	[0-9]
LETRA	[A-Za-z_]
DOUBLE {DIGITO}+("."{DIGITO}+)?
ID  {LETRA}({LETRA}|{DIGITO})*
STR  (\"([^"\n]|\"\"|\\\")*\")|('([^'\n]|''|\\')*')

%%

{DELIM} {}

{DOUBLE}    {yylval.c = novo + yytext;
        return NUM;}

"let"   {yylval.c = novo + "let";
    return LET;}

"if"   {yylval.c = novo + "if";
    return IF;}

{STR}  {yylval.c = novo + yytext;
    return STR;}

{ID}  {yylval.c = novo + yytext;
    return ID;}

.    {yylval.c = novo + yytext;
    return yytext[0];}

%%