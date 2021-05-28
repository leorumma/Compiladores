DIGITO	[0-9]
LETRA	[A-Za-z_]
NUM {DIGITO}+("."{DIGITO}+)?
ID  {LETRA}({LETRA}|{DIGITO})*
STR  (\"([^"\n]|\"\"|\\\")*\")|('([^'\n]|''|\\')*')
NEG "!"

%%

"\t"       { coluna += 4; }

"\n"       { linha++; coluna = 1; }

" "        { coluna++; }

{NUM}    {yylval.c = novo + yytext;
        return NUM;}

"[]"       { return token(ARRAY); }

"{}"       { return token(OBJECT); }

"let"   {yylval.c = novo + "let";
    return LET;}

"if"   {yylval.c = novo + "if";
    return IF;}

"else"  {yylval.c = novo + "else";
    return ELSE;}

"for"  {yylval.c = novo + "for";
    return FOR;}

"while"  {yylval.c = novo + "while";
    return WHILE;}

">="  {yylval.c = novo + "maig";
    return MAIOR_IGUAL;}

"<="  {yylval.c = novo + "meig";
    return MENOR_IGUAL;}

"=="  {yylval.c = novo + "igual";
    return IGUAL;}

"!="  {yylval.c = novo + "diferente";
    return DIFERENTE;}

{NEG}  {yylval.c = novo + "neg";
    return NEG;}

{STR}  {yylval.c = novo + yytext;
    return STR;}

{ID}  {yylval.c = novo + yytext;
    return ID;}

.    {yylval.c = novo + yytext;
    return yytext[0];}

%%