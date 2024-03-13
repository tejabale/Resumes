%{
// This part goes directly into the generated parser

#include "scanner.hh"
#include "parser.tab.hh"

// YY_DECL is bound to the type of the scanner. The default is 
// #define YY_DECL int Scanner::yylex()
// which is generated anyway.

//If you want the type of the generated scanner to be different, do this

#undef  YY_DECL
#define YY_DECL int IPL::Scanner::yylex( IPL::Parser::semantic_type * const lval, IPL::Parser::location_type *loc )

//We want these to be the first action after a token is recognized. 

#define YY_USER_ACTION loc->step(); loc->columns(yyleng);

// token_type is a short hand for IPL::Parser::token

#define token IPL::Parser::token

%}


/* %option debug */
%option nodefault
%option yyclass="Scanner"
%option noyywrap
%option c++

%%

%{ /** Code executed at the beginning of yylex **/

      yylval = lval;

%}

[ \t]                             ;
[\n]                              loc->lines();
"/*"([^*]|(\*+[^*/]))*\*+\/      //skip
"struct"                                     {
       yylval->emplace< std::string >( YYText() );
       return token::STRUCT;
}
"main"                                       {
       yylval->emplace< std::string >( YYText() );
       return token::MAIN;
}
"printf"                                       {
       yylval->emplace< std::string >( YYText() );
       return token::PRINTF;
}
"void"                                       {
       yylval->emplace< std::string >( YYText() );
       return token::VOID;
}
"int"                                        {
       yylval->emplace< std::string >( YYText() );
       return token::INT;
}
"float"                                      {
       yylval->emplace< std::string >( YYText() );
       return token::FLOAT;
}
"return"                                     {
       yylval->emplace< std::string >( YYText() );
       return token::RETURN;
}
"if"                                         {
       yylval->emplace< std::string >( YYText() );
       return token::IF;
}
"else"                                       {
       yylval->emplace< std::string >( YYText() );
       return token::ELSE;
}
"while"                                      {
       yylval->emplace< std::string >( YYText() );
       return token::WHILE;
}
"for"                                        {
       yylval->emplace< std::string >( YYText() );
       return token::FOR;
}

"||"                                          {
       yylval->emplace< std::string >( YYText() );
       return token::OR_OP;
}
"&&"                                          {
       yylval->emplace< std::string >( YYText() );
       return token::AND_OP;
}
"=="                                          {
       yylval->emplace< std::string >( YYText() );
       return token::EQ_OP;
}
"!="                                          {
       yylval->emplace< std::string >( YYText() );
       return token::NE_OP;
}

"<="                                          {
       yylval->emplace< std::string >( YYText() );
       return token::LE_OP;
}
">="                                          {
       yylval->emplace< std::string >( YYText() );
       return token::GE_OP;
}
"++"                                          {
       yylval->emplace< std::string >( YYText() );
       return token::INC_OP;
}

"->"                                          {
       yylval->emplace< std::string >( YYText() );
       return token::PTR_OP;
}

[[:alpha:]_][[:alnum:]_]*                    {
       yylval->emplace< std::string >( YYText() );
       return token::IDENTIFIER;
}

[1-9][0-9]*|0[bB][01]+|0[0-7]*|0[xX][0-9a-fA-F]+                    {
       yylval->emplace< std::string >( YYText() );
       return token::INT_CONSTANT;
}
"."                             return '.';
[0-9]*"."[0-9]*([eE][+-][0-9]+|[eE][0-9]+)?                         {
       yylval->emplace< std::string >( YYText() );
       return token::FLOAT_CONSTANT;
}
\"(\\(.|\n)|[^\\"\n])*\"                                         {
       yylval->emplace< std::string >( YYText() );
       return token::STRING_LITERAL;
}
"{"                             return '{';
"}"                             return '}';
"("                             return '(';
")"                             return ')';
"["                             return '[';
"]"                             return ']';
","                             return ',';
";"                             return ';';
"*"                             return '*';
"="                             return '=';
"!"                             return '!';
"&"                             return '&';
"<"                             return '<';
">"                             return '>';
"+"                             return '+';
"-"                             return '-';
"/"                             return '/';
"\n"                            
<<EOF>>                         yyterminate();
.                               {
       yylval->emplace< std::string >( YYText() );
       return token::OTHERS;
}
%%

