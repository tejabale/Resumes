%skeleton "lalr1.cc"
%require  "3.0.1"

%defines 
%define api.namespace {IPL}
%define api.parser.class {Parser}

%define parse.trace




%code requires{

   #include "ast.hh"
   #include "location.hh"
   #include "symbtab.hh"
   #include "type.hh"

   namespace IPL {
      class Scanner;
   }

  // # ifndef YY_NULLPTR
  // #  if defined __cplusplus && 201103L <= __cplusplus
  // #   define YY_NULLPTR nullptr
  // #  else
  // #   define YY_NULLPTR 0
  // #  endif
  // # endif



}

%printer { std::cerr << $$; } STRUCT
%printer { std::cerr << $$; } IDENTIFIER
%printer { std::cerr << $$; } VOID
%printer { std::cerr << $$; } INT
%printer { std::cerr << $$; } FLOAT
%printer { std::cerr << $$; } RETURN
%printer { std::cerr << $$; } OR_OP
%printer { std::cerr << $$; } AND_OP
%printer { std::cerr << $$; } EQ_OP
%printer { std::cerr << $$; } NE_OP
%printer { std::cerr << $$; } LE_OP
%printer { std::cerr << $$; } GE_OP
%printer { std::cerr << $$; } IF
%printer { std::cerr << $$; } ELSE
%printer { std::cerr << $$; } INC_OP
%printer { std::cerr << $$; } PTR_OP
%printer { std::cerr << $$; } WHILE
%printer { std::cerr << $$; } FOR
%printer { std::cerr << $$; } INT_CONSTANT
%printer { std::cerr << $$; } FLOAT_CONSTANT
%printer { std::cerr << $$; } STRING_LITERAL
%printer { std::cerr << $$; } MAIN
%printer { std::cerr << $$; } PRINTF
%printer { std::cerr << $$; } OTHERS





%parse-param { Scanner  &scanner  }
%locations
%code{

   #include <iostream>
   #include <cstdlib>
   #include <fstream>
   #include <string>
   #include "scanner.hh"

   extern SymbTab gst;
   std::map<string,abstract_astnode*> ast;

   std::map<int,std::vector<std::string>> LC;
   std::map<int, std::string> LC_fun;


   std::vector<std::string> final_code;
   std::map<std::string , std::vector<std::string> > code;
   vector<table_entries> d_list;
   std::string current_func;
   int is_struct = 0;

   int lc_num = 0;
   int l_num = 2;

   vector<std::string> rstack = {"esi" , "edi" , "edx" , "ecx" , "ebx"};
   std::vector<std::string> restore_stack;
   std::string ureg;   

   std::map<int,int> off_val;

   
   std::string asm_fun;
   std::vector<int> while_L;
   std::vector<int> for_L;
   std::vector<std::string> if_L;



  


#undef yylex
#define yylex IPL::Parser::scanner.yylex

   


}




%define api.value.type variant
%define parse.assert

%start program



%token '\n'
%token <std::string> STRUCT
%token <std::string> IDENTIFIER
%token <std::string> VOID
%token <std::string> INT
%token <std::string> FLOAT
%token <std::string> RETURN
%token <std::string> OR_OP
%token <std::string> AND_OP
%token <std::string> EQ_OP
%token <std::string> NE_OP
%token <std::string> LE_OP
%token <std::string> GE_OP
%token <std::string> IF
%token <std::string> ELSE
%token <std::string> INC_OP
%token <std::string> PTR_OP
%token <std::string> WHILE
%token <std::string> FOR
%token <std::string> INT_CONSTANT
%token <std::string> FLOAT_CONSTANT
%token <std::string> STRING_LITERAL
%token <std::string> MAIN
%token <std::string> PRINTF
%token <std::string> OTHERS
%token '{'
%token '}'
%token '('
%token ')'
%token '['
%token ']'
%token ','
%token ';'
%token '*'
%token '='
%token '<'
%token '>'
%token '+'
%token '-'
%token '/'
%token '.'
%token '!'
%token '&'


%nterm <statement_astnode*> compound_statement assignment_statement statement selection_statement iteration_statement procedure_call printf_call
%nterm <exp_astnode*> expression unary_expression primary_expression logical_and_expression equality_expression relational_expression additive_expression multiplicative_expression postfix_expression
%nterm <vector<exp_astnode*>> expression_list
%nterm <std::string> unary_operator type_specifier
%nterm <seq_astnode*> statement_list
%nterm <assignE_astnode*> assignment_expression
%nterm <table_entries> declarator_arr declarator parameter_declaration fun_declarator function_definition struct_specifier main_definition
%nterm <vector<table_entries>> parameter_list declaration_list declarator_list declaration

%%
program: 
    main_definition
  | translation_unit main_definition

translation_unit:
         struct_specifier 
       { 
	    
       }
       | function_definition
       { 
	    
       }
       | translation_unit struct_specifier
       { 
	    
       }
       | translation_unit function_definition
       { 
	    
       }
       ;
      

struct_specifier:
         STRUCT IDENTIFIER 
         {
           string name = $1 + " " + $2;
           table_entries t;
           t.name = name;
           t.varfun = "struct";
           t.scope = "global";
           t.width = 0;
           t.offset = -1;
           t.return_type = "-";
           if( gst.Entries.count(name) != 0 ){
            error(@$ , name + " is already declared");
          }
           gst.Entries[name] = t;
           current_func = name;
           is_struct = 1;
         } 
         '{' declaration_list '}' ';'
       { 
	         

           vector<table_entries> vec_t = $5;

           int tracker = 0;

           for(size_t i=0; i< vec_t.size(); i++){
             vec_t[i].offset = tracker;
             tracker += vec_t[i].width;
           }

           for(size_t i=0; i< vec_t.size(); i++){
             gst.Entries[current_func].symtab_pointer->Entries[vec_t[i].name].offset = vec_t[i].offset;
             gst.Entries[current_func].width += vec_t[i].width;
           }

           is_struct = 0;

       }
       ;

function_definition:
         type_specifier fun_declarator 
         { 
           gst.Entries[current_func].return_type = $1; 
           asm_fun = current_func; 

           vector<std::string> vec;
           vec.push_back("pushl %ebp");
           vec.push_back("movl %esp, %ebp");
           code[current_func] = vec;

         } 
         compound_statement
       { 

          if($1[0] == 's'){
            if( gst.Entries.count($1) == 0){
              error( @$ , $1 + " is not defined" );
            }
          }

          $$ = $2;
          gst.Entries[current_func].scope = "global";

          d_list.clear();

          ast[$2.name] = $4;
          off_val.clear();

          if(lc_num > 0){
            LC[lc_num-1].push_back(".text");
            LC[lc_num-1].push_back(".global " + current_func);
            LC[lc_num-1].push_back(".type " + current_func + "," + " @function");
          }


          if($1 == "void"){
            int number_locals = 0;
            for(const auto &entry : gst.Entries[current_func].symtab_pointer->Entries){
              if(entry.second.scope == "local"){
                number_locals++;
              }
            }
            code[asm_fun].push_back("addl $" + to_string(4*number_locals) +", %esp");
            code[asm_fun].push_back("leave");
            code[asm_fun].push_back("ret");        
            //code[asm_fun].push_back(".size " + (current_func) + ", . -" +  (current_func) );
            if(current_func != "main"){
              code[asm_fun].push_back(".section   .rodata" );
            }
          }
       }
       ;
       
main_definition
  : INT MAIN '(' ')'{

        table_entries t;
        t.name = "main";
        t.varfun = "fun";
        t.width = 0;
        t.offset = 0;
        t.return_type = "int";

        if( gst.Entries.count(t.name) != 0 ){
            error(@$ , t.name + " function is already declared");
        }

        gst.Entries[t.name] = t;
        gst.Entries[t.name].symtab_pointer = new SymbTab();

        current_func = t.name;

        vector<std::string> vec;
        vec.push_back("pushl %ebp");
        vec.push_back("movl %esp, %ebp");
        asm_fun = current_func;
        code[current_func] = vec;
       


    } 
     compound_statement
    {
      gst.Entries[current_func].scope = "global";
      d_list.clear();
      ast[current_func] = $6;
      $$ = gst.Entries[current_func];

      if(lc_num>0){
        LC[lc_num-1].push_back(".text");
        LC[lc_num-1].push_back(".global " + current_func);
        LC[lc_num-1].push_back(".type " + current_func + "," + " @function");
      }
      off_val.clear();
      


    }


type_specifier:
         VOID
       {
       	  $$ = "void";
       }
       | INT
       {
       	  $$ = "int";
       }
       | STRUCT IDENTIFIER
       {
       	  $$ = "struct " + $2;
       }
       ;

fun_declarator:
         IDENTIFIER  '(' parameter_list ')'
       {

          table_entries t;
          t.name = $1;
          t.varfun = "fun";
          t.width = 0;
          t.offset = 0;

          if( gst.Entries.count(t.name) != 0 ){
            error(@$ , t.name + " function is already declared");
          }

          gst.Entries[t.name] = t;
          gst.Entries[t.name].symtab_pointer = new SymbTab();

          vector<table_entries> vec_t = $3;

          for(size_t i=0; i< vec_t.size(); i++){
            if( gst.Entries[t.name].symtab_pointer->Entries.count(vec_t[i].name) == 0){
              gst.Entries[t.name].symtab_pointer->Entries[vec_t[i].name] = vec_t[i];
            }
            else{
              error(@$ , vec_t[i].name + " is already declared");
            }
          }

          current_func = t.name;
          $$ = gst.Entries[t.name];


       }
       | IDENTIFIER '(' ')'
       {


          table_entries t;
          t.name = $1;
          t.varfun = "fun";
          t.width = 0;
          t.offset = 0;

          if( gst.Entries.count(t.name) != 0 ){
            error(@$ , t.name + " function is already declared");
          }

          gst.Entries[t.name] = t;
          gst.Entries[t.name].symtab_pointer = new SymbTab();

          current_func = t.name;
          $$ = gst.Entries[t.name];
       	  
       }
       ;

parameter_list:
         parameter_declaration
       {
            table_entries t;
            t = $1;
       	    vector<table_entries> vec_t;
            t.offset = 12;
            vec_t.push_back(t);
            $$ = vec_t;
       }
       | parameter_list ',' parameter_declaration
       {
          table_entries t;
          t = $3;
          t.offset = 12;

          int add = t.width;

          vector<table_entries> vec_t = $1;

          for(size_t i = 0 ; i < vec_t.size() ; i++){
            vec_t[i].offset = add + vec_t[i].offset ;
          }


       	  $$ = vec_t;
          $$.push_back(t);
       }
       ;

parameter_declaration:
         type_specifier declarator
       {  

          if($1[0] == 's'){
            if( gst.Entries.count($1) == 0){
              error( @$ , $1 + " is not defined" );
            }
          }
       	  $$ = $2;
          $$.scope = "param";

          if($1 == "void" &&  $2.return_type[0] != '*' ){

            error(@$ , "cannot declare variable of type void");

          }

          if($$.return_type[0] == '*'){
            $$.width = $$.width * 4;
          }
          else{
            if($1 == "void"){
              $$.width = $$.width * 4;
            }
            else if($1 == "int"){
              $$.width = $$.width * 4;
            }
            else if($1 == "float"){
              $$.width = $$.width * 4;
            }
            else{
              for (auto it = gst.Entries.begin(); it != gst.Entries.end(); ++it){
                if(it->first == $1){
                    $$.width = $$.width *  it->second.width;
                    break;
                }
              }   
            }
            
          }
          $$.return_type = $1 + $$.return_type;

          
       }
       ;

declarator_arr:
         IDENTIFIER
       {
       	  table_entries t;
          t.name = $1;
          t.varfun = "var";
          t.width = 1;
          $$ = t;
       }
       | declarator_arr '[' INT_CONSTANT ']'
       {
       	  $$ = $1;
          $$.width = $$.width * stoi($3);
          $$.return_type = $$.return_type + "[" + $3 + "]";
       }
       ;

declarator:
         declarator_arr
       {
       	   $$ = $1;
       }
       | '*' declarator
       {
       	  $$ = $2;
          $$.return_type = "*" + $$.return_type;
       }
       ;

compound_statement:
         '{' '}'
       {
       	  $$ = new seq_astnode();
       }
       | '{' statement_list '}'
       {
       	  $$ = $2;

       }
       | '{' declaration_list 
       {
          vector<table_entries> vec_t = $2;

          int tracker = 0;

          for(size_t i=0; i< vec_t.size(); i++){
            vec_t[i].offset = tracker - vec_t[i].width;
            tracker = vec_t[i].offset;
            gst.Entries[current_func].symtab_pointer->Entries[vec_t[i].name].offset = vec_t[i].offset;
          }

          d_list = vec_t;
          code[current_func].push_back("subl $" + to_string(4*vec_t.size()) +", %esp");

       } 
          statement_list '}'
       {
       	  $$ = $4;
          vector<table_entries> vec_t = $2;

       }
       ;

statement_list:
         statement
       {
       	  $$ = new seq_astnode();
          $$->statement_astnodes.push_back($1);
       }
       | statement_list statement
       {
       	  $$ = $1;
            $$->statement_astnodes.push_back($2);
       }
       ;

statement:
         ';'
       {
            $$ = new empty_astnode();
       }
       | '{' statement_list '}'
       {
       	  $$ = $2;
       }
       | selection_statement
       {
       	  $$ = $1;
       }
       | iteration_statement
       {
       	  $$ = $1;
       }
       | assignment_statement
       {
       	  $$ = $1;
       }
       | procedure_call
       {
       	  $$ = $1;
       }
       | printf_call
       {
         $$ = $1;
       }
       | RETURN expression ';'
       {
          exp_astnode* lexp;
          lexp = $2;
          ExpType e1;
          string ftype = gst.Entries[current_func].return_type;

          e1.insert(ftype);

          if( ftype != $2->e.tostringtype()){
            
              if( $2->e.tostringtype() == "int" && ftype == "float"){
                e1.insert("float");
                lexp = new op_unary_astnode("TO_FLOAT" , $2);
              }
              else if( $2->e.tostringtype() == "float" && ftype == "int"){
                e1.insert("int");
                lexp = new op_unary_astnode("TO_INT" , $2);
              }
              else if( ($2->e.tostringtype() == "void*" && (e1.number_stars + e1.number_of_boxes > 0) ) || (  e1.tostringtype() == "void*"   &&  ($2->e.number_stars + $2->e.number_of_boxes > 0) )  ){
               
                  e1.insert(ftype);
              }
              else{
                error(@$ , "cannot cast " + $2->e.tostringtype() + " to " + ftype);
              }
          }

          lexp->e = e1;
       	  $$ = new return_astnode(lexp);
          code[asm_fun].insert(code[asm_fun].end() , $2->expCode.begin() , $2->expCode.end());
          int number_locals = 0;
          for(const auto &entry : gst.Entries[current_func].symtab_pointer->Entries){
            if(entry.second.scope == "local"){
              number_locals++;
            }
          }
          code[asm_fun].push_back("addl $" + to_string(4*number_locals) +", %esp");
          code[asm_fun].push_back("leave");
          code[asm_fun].push_back("ret");        
          //code[asm_fun].push_back(".size " + (current_func) + ", . -" +  (current_func) );
          if(current_func != "main"){
            code[asm_fun].push_back(".section   .rodata" );
          }
          
       }
       ;

assignment_expression:
         unary_expression '=' expression
       {
          ExpType e1;
          exp_astnode* lexp;
          exp_astnode* rexp;
          lexp = $1;
          rexp = $3;

          if($1->e.lvalue == 0){
            error( @$ , "lvalue is required as an left operand of assignment" );
          }
          else{

             if( $1->e.tostringtype() == "int" && $3->e.tostringtype() == "int"){
                e1.insert("int");
              }
              else if( $1->e.tostringtype() == "float" && $3->e.tostringtype() == "float"){
                e1.insert("float");
              }
              else if( $1->e.tostringtype() == "int" && $3->e.tostringtype() == "float"){
                e1.insert("float");
                lexp = new op_unary_astnode("TO_FLOAT" , $1);
              }
              else if( $1->e.tostringtype() == "float" && $3->e.tostringtype() == "int"){
                e1.insert("float");
                rexp = new op_unary_astnode("TO_FLOAT" , $3);
              }
              else if( $1->e.tostringtype() == $3->e.tostringtype() ){
                e1.insert($1->e.tostringtype());
              }
              else if( ( $1->e.tostringtype() == "void*" && ($3->e.number_stars + $3->e.number_of_boxes > 0) ) || (  $3->e.tostringtype() == "void*"   &&  ($1->e.number_stars + $1->e.number_of_boxes > 0) )  ){
                if($3->e.tostringtype() == "void*"){
                  e1.insert($1->e.tostringtype());
                }
                else{
                  e1.insert($3->e.tostringtype());
                }
                
              }
              else if( ($1->e.number_stars + $1->e.number_of_boxes > 0) && ($3->e.is_zero == 1) ){

                e1.insert($1->e.tostringtype());
                  
              }
              else if(($3->e.number_stars + $3->e.number_of_boxes > 0) && ($1->e.number_stars + $1->e.number_of_boxes > 0)){
                 ExpType exp1 = $1->e;
                 ExpType exp2 = $3->e;

                 if(exp1.number_of_boxes > 0){
                   exp1.number_of_boxes--;
                   exp1.number_stars++;
                   exp1.num.erase(exp1.num.begin());
                 }

                 if(exp2.number_of_boxes > 0){
                   exp2.number_of_boxes--;
                   exp2.number_stars++;
                   exp2.num.erase(exp2.num.begin());
                 }

                 if(exp1.tostringtype() == exp2.tostringtype() ){
                   e1.insert($1->e.tostringtype());
                 }
                 else{
                  error(@$ , "cannot cast " + $3->e.tostringtype() + " to " + $1->e.tostringtype());
                 }


              }
              else{
                error(@$ , "cannot cast " + $3->e.tostringtype() + " to " + $1->e.tostringtype());
              }

          }
          e1.lvalue = 1;
       	  $$ = new assignE_astnode(lexp , rexp);
          
          string temp = "";
          for(size_t i=5 ; i<($1->expCode[0]).length(); i++){
            if( ($1->expCode[0])[i] == '(') break;
            temp += ($1->expCode[0])[i];
          }

          int offset = stoi(temp);
          off_val[offset] = $3->expval;

          $$->expCode.insert($$->expCode.end() , $3->expCode.begin() , $3->expCode.end());
          $$->expCode.push_back("movl %eax, " + temp + "(%ebp)");
          
       }
       ;

assignment_statement:
         assignment_expression ';'
       {
       	  $$ = new assignS_astnode($1->lexp , $1->rexp);
          code[asm_fun].insert(code[asm_fun].end() , $1->expCode.begin() , $1->expCode.end());
       }
       ;

procedure_call:
         IDENTIFIER '(' ')' ';'
       {

          if(gst.Entries.count($1) == 0){
            if($1 != "printf" && $1 != "scanf"){
              error( @$ , $1 + " was not declared in this scope");
            }
          }
          else{
            int number_param = 0;
            map<std::string , table_entries> m = gst.Entries[$1].symtab_pointer->Entries;

            for (const auto &entry : m){

              if (entry.second.scope == "param"){
                number_param++;
              }

            }

            if(number_param != 0){
                error( @$ , "too many arguments to function " + $1);
            } 

          }

          code[asm_fun].push_back("call " + $1);





          $$ = new proccall_astnode($1);


       }
       | IDENTIFIER '(' expression_list ')' ';'
       {

          if(gst.Entries.count($1) == 0){
            if($1 != "printf" && $1 != "scanf"){
              error( @$ , $1 + " was not declared in this scope");
            }
          }

          else{

            size_t number_param = 0;

            map<int , table_entries> paralist;

            for (const auto &entry : gst.Entries[$1].symtab_pointer->Entries){
              if (entry.second.scope == "param"){
                number_param++;
                paralist[entry.second.offset] = entry.second;
              }

            }


            if(number_param == $3.size()){
              

              vector<table_entries> parrev;
              vector<table_entries> par;

              for (const auto &entry : paralist){    
                parrev.push_back(entry.second);
              }

              int size = parrev.size();
              for(int i= size-1 ; i >= 0 ; i--){
                par.push_back(parrev[i]);
              }
              

              for(size_t i= 0; i <par.size() ; i++){

                ExpType temp;
                temp.insert(par[i].return_type);

                if(par[i].return_type != $3[i]->e.tostringtype() ){
                  if(  (par[i].return_type == "float" || par[i].return_type == "int") &&  ( $3[i]->e.tostringtype() == "float" || $3[i]->e.tostringtype() == "int")  ){
                    if(par[i].return_type == "float" && $3[i]->e.tostringtype() == "int" ){
                      $3[i] = new op_unary_astnode("TO_FLOAT" , $3[i]);
                    }
                    else if(par[i].return_type == "int" && $3[i]->e.tostringtype() == "float" ){
                      $3[i] = new op_unary_astnode("TO_INT" , $3[i]);
                    }
                    continue;
                  }
                  else if(par[i].return_type == "void*"){

                    ExpType forvoid = $3[i]->e;
                    if(forvoid.number_of_boxes>0){
                      forvoid.number_of_boxes--;
                      forvoid.num.erase(forvoid.num.begin());
                      forvoid.number_stars++;
                    }
                    if(forvoid.number_stars > 0){
                      continue;
                    }
                    else{
                      error( @$ , "cannot convert " + forvoid.tostringtype() + " to " +   par[i].return_type );
                    }

                  }
                  else if($3[i]->e.tostringtype() == "void*"){

                    ExpType forvoid = temp;
                    if(forvoid.number_of_boxes>0){
                      forvoid.number_of_boxes--;
                      forvoid.num.erase(forvoid.num.begin());
                      forvoid.number_stars++;
                    }

                    if(forvoid.number_stars > 0){
                      continue;
                    }
                    else{
                      error( @$ , "cannot convert " + $3[i]->e.tostringtype() + " to " +   forvoid.tostringtype() );
                    }
                  }
                  else if(temp.number_of_boxes > 0 || $3[i]->e.number_of_boxes>0){
                    ExpType ee = $3[i]->e;
                    ExpType ee2 = temp;

                    if(ee2.number_of_boxes > 0){
                      ee2.number_of_boxes--;
                      ee2.number_stars++;
                      ee2.num.erase(ee2.num.begin());
                    }
                    if(ee.number_of_boxes > 0){
                      ee.number_of_boxes--;
                      ee.number_stars++;
                      ee.num.erase(ee.num.begin());
                    }
                    if(ee.tostringtype() == ee2.tostringtype()){
                      continue;
                    }
                    else{
                      error( @$ , "cannot convert " + ee.tostringtype() + " to " +   ee2.tostringtype() );
                    }
                  }
                  else{
                      error( @$ , "cannot convert " + $3[i]->e.tostringtype() + " to " +   par[i].return_type );
                  }
                }
                

              }

            }

            else{
                error( @$ , "wrong number of arguments to function " + $1);
            } 

          } 

       	  $$ = new proccall_astnode($1 , $3);

          vector<exp_astnode*> expvec = $3;
          for(size_t i=0; i<expvec.size(); i++){
            code[asm_fun].insert(code[asm_fun].end(), expvec[i]->expCode.begin(), expvec[i]->expCode.end() );
            code[asm_fun].push_back("pushl %eax");
          }

          code[asm_fun].push_back("call " + $1);
          code[asm_fun].push_back("addl $" + to_string(4*expvec.size()) + ", %esp" );

       }
       ;

printf_call: 
    PRINTF '(' STRING_LITERAL ')' ';'
    {
      vector<std::string> vec;
      vec.push_back(".string " + $3);
      LC[lc_num++] = vec;
      LC_fun[lc_num-1] = current_func;
      vector<exp_astnode*> explist;
      $$ = new printf_astnode($3, explist);
      code[asm_fun].push_back("pushl $.LC" + to_string(lc_num-1));
      code[asm_fun].push_back("call printf");
      code[asm_fun].push_back("addl $4, %esp");


    }
  | PRINTF '(' STRING_LITERAL ',' expression_list ')' ';' 
    {
      vector<std::string> vec;
      vec.push_back(".string " + $3);
      LC[lc_num++] = vec;
      LC_fun[lc_num-1] = current_func;
      $$ = new printf_astnode($3 , $5);
      size_t k = $5.size();
      for(size_t i=0; i<$5.size(); i++){
        exp_astnode* es = $5[k-i-1];

        code[asm_fun].insert(code[asm_fun].end() , es->expCode.begin() , es->expCode.end());
        code[asm_fun].push_back("pushl %eax");
        
      }

      code[asm_fun].push_back("pushl $.LC" + to_string(lc_num-1));
      code[asm_fun].push_back("call printf");
      code[asm_fun].push_back("addl $" + to_string(4*(k+1)) + ", %esp");

      
    }
expression:
         logical_and_expression
       {
       	  $$ = $1;
       }
       | expression OR_OP logical_and_expression
       {

          ExpType e1;

          if( ($1->e.type[0] == 's' && $1->e.number_stars == 0 && $1->e.number_of_boxes == 0) || ($3->e.type[0] == 's' && $3->e.number_stars == 0 && $3->e.number_of_boxes == 0)){
            error( @$ , "used struct type value where scaler is required"); 
          }
          else{
            e1.insert("int");
            e1.lvalue = 0;
          }

       	  $$ = new op_binary_astnode("OR_OP" , $1 , $3);
          $$->e = e1;
          $$->expval = $1->expval || $3->expval;

          code[asm_fun].insert(code[asm_fun].end() , $1->expCode.begin() , $1->expCode.end());
          code[asm_fun].push_back("cmpl $0, %eax");
          code[asm_fun].push_back("jne .L" + to_string(l_num));

          code[asm_fun].insert(code[asm_fun].end() , $3->expCode.begin() , $3->expCode.end());
          code[asm_fun].push_back("cmpl $0, %eax");
          code[asm_fun].push_back("jne .L" + to_string(l_num));
          code[asm_fun].push_back("movl $0, %eax");  
          code[asm_fun].push_back("jmp .L" + to_string(l_num+1));



          code[".L" + to_string(l_num)].push_back("movl $1, %eax");
          code[".L" + to_string(l_num)].push_back("jmp .L" +  to_string(l_num+1));
          asm_fun = ".L" + to_string(l_num+1);
          l_num += 2;
       	  
       }
       ;

logical_and_expression:
         equality_expression
       {
       	  $$ = $1;
       }
       | logical_and_expression AND_OP equality_expression
       {

          ExpType e1;

          if( ($1->e.type[0] == 's' && $1->e.number_stars == 0 && $1->e.number_of_boxes == 0) || ($3->e.type[0] == 's' && $3->e.number_stars == 0 && $3->e.number_of_boxes == 0)){
            error( @$ , "used struct type value where scaler is required"); 
          }
          else{
            e1.insert("int");
            e1.lvalue = 0;
          }

       	  $$ = new op_binary_astnode("AND_OP" , $1 , $3);
          $$->e = e1;
          $$->expval = $1->expval && $3->expval;

          code[asm_fun].insert( code[asm_fun].end() , $1->expCode.begin() , $1->expCode.end());
          code[asm_fun].push_back("cmpl $0, %eax");
          code[asm_fun].push_back("je .L" + to_string(l_num));

          code[asm_fun].insert( code[asm_fun].end() , $3->expCode.begin() , $3->expCode.end());
          code[asm_fun].push_back("cmpl $0, %eax");
          code[asm_fun].push_back("je .L" + to_string(l_num));
          code[asm_fun].push_back("movl $1, %eax");  
          code[asm_fun].push_back("jmp .L" + to_string(l_num+1));



          code[".L" + to_string(l_num)].push_back("movl $0, %eax");
          code[".L" + to_string(l_num)].push_back("jmp .L" +  to_string(l_num+1));
          asm_fun = ".L" + to_string(l_num+1);
          l_num += 2;
          
          


       }
       ;

equality_expression:
         relational_expression
       {
       	  $$ = $1;
       }
       | equality_expression 
       {
          ureg = rstack[rstack.size()-1];
          restore_stack.push_back(ureg);
          rstack.pop_back();
       }
       EQ_OP relational_expression
       {
          exp_astnode* lexp;
          exp_astnode* rexp;
          lexp = $1;
          rexp = $4;

          ExpType e1;
          string OP = "EQ_OP_";
          e1 = $1->e;

          if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "int"){
            OP += "INT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("int");
            lexp = new op_unary_astnode("TO_FLOAT" , $1);
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "int"){
            OP += "FLOAT";
            e1.insert("int");
            rexp = new op_unary_astnode("TO_FLOAT" , $4);
          }
          else if( ( $1->e.tostringtype() == "void*" && ($4->e.number_stars + $4->e.number_of_boxes > 0) ) || (  $4->e.tostringtype() == "void*"   &&  ($1->e.number_stars + $1->e.number_of_boxes > 0) )  ){
            OP += "INT";
            e1.insert("int");
            
          }
          else if( (($1->e.number_stars + $1->e.number_of_boxes > 0) && $4->e.is_zero == 1) || (($4->e.number_stars + $4->e.number_of_boxes > 0) && $1->e.is_zero == 1) ){
              OP += "INT";
              e1.insert("int");
          }
          else if(($1->e.number_stars + $1->e.number_of_boxes > 0) && ($4->e.number_stars + $4->e.number_of_boxes > 0)){

             if($1->e.number_of_boxes > 0 || $4->e.number_of_boxes > 0 ){

              ExpType exp1 = $1->e;
              ExpType exp2 = $4->e;

              

              if(exp1.number_of_boxes > 0){
                exp1.number_of_boxes--;
                exp1.number_stars++;
                exp1.num.erase(exp1.num.begin());
              }

              if(exp2.number_of_boxes > 0){
                exp2.number_of_boxes--;
                exp2.number_stars++;
                exp2.num.erase(exp2.num.begin());
              }

              if(exp1.tostringtype() == exp2.tostringtype()){
                OP += "INT";
                e1.insert("int");
              }
              else{
                error(@$ , "invalid operands of types " + exp1.tostringtype() + " and " + exp2.tostringtype() + " to binary operator ==");
              }

            }
            else if($1->e.tostringtype() == $4->e.tostringtype()){
              OP += "INT";
              e1.insert("int");
            }
            else{
              error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator ==");
            }

          }
          else{
            error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator ==");
          }

          e1.lvalue = 0;
       	  $$ = new op_binary_astnode(OP , lexp, rexp);
          $$->e = e1;
          $$->expval = $1->expval == $4->expval;

          ureg = restore_stack[restore_stack.size()-1];
          restore_stack.pop_back();

          $$->expCode.insert($$->expCode.end() , $1->expCode.begin() , $1->expCode.end());
          $$->expCode.push_back("movl %eax, %" + ureg);
          $$->expCode.insert($$->expCode.end() , $4->expCode.begin() , $4->expCode.end());
          $$->expCode.push_back("cmpl %eax, %" + ureg);
          $$->expCode.push_back("sete %al");
          $$->expCode.push_back("movzbl %al, %eax");

          rstack.push_back(ureg);

       }
       | equality_expression 
       {
          ureg = rstack[rstack.size()-1];
          restore_stack.push_back(ureg);
          rstack.pop_back();
       }
       NE_OP relational_expression
       {
       	  exp_astnode* lexp;
          exp_astnode* rexp;
          lexp = $1;
          rexp = $4;

          ExpType e1;
          string OP = "NE_OP_";
          e1 = $1->e;

          if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "int"){
            OP += "INT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("int");
            lexp = new op_unary_astnode("TO_FLOAT" , $1);
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "int"){
            OP += "FLOAT";
            e1.insert("int");
            rexp = new op_unary_astnode("TO_FLOAT" , $4);
          }
          else if( ( $1->e.tostringtype() == "void*" && ($4->e.number_stars + $4->e.number_of_boxes > 0) ) || (  $4->e.tostringtype() == "void*"   &&  ($1->e.number_stars + $1->e.number_of_boxes > 0) )  ){
            OP += "INT";
            e1.insert("int");
            
          }
          else if( (($1->e.number_stars + $1->e.number_of_boxes > 0) && $4->e.is_zero == 1) || (($4->e.number_stars + $4->e.number_of_boxes > 0) && $1->e.is_zero == 1) ){
              OP += "INT";
              e1.insert("int");
          }
          else if(($1->e.number_stars + $1->e.number_of_boxes > 0) && ($4->e.number_stars + $4->e.number_of_boxes > 0)){

             if($1->e.number_of_boxes > 0 || $4->e.number_of_boxes > 0 ){

              ExpType exp1 = $1->e;
              ExpType exp2 = $4->e;

              

              if(exp1.number_of_boxes > 0){
                exp1.number_of_boxes--;
                exp1.number_stars++;
                exp1.num.erase(exp1.num.begin());
              }

              if(exp2.number_of_boxes > 0){
                exp2.number_of_boxes--;
                exp2.number_stars++;
                exp2.num.erase(exp2.num.begin());
              }

              if(exp1.tostringtype() == exp2.tostringtype()){
                OP += "INT";
                e1.insert("int");
              }
              else{
                error(@$ , "invalid operands of types " + exp1.tostringtype() + " and " + exp2.tostringtype() + " to binary operator !=");
              }

            }
            else if($1->e.tostringtype() == $4->e.tostringtype()){
              OP += "INT";
              e1.insert("int");
            }
            else{
              error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator !=");
            }
          }

          else{
            error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator !=");
          }

          e1.lvalue = 0;
       	  $$ = new op_binary_astnode(OP , lexp, rexp);
          $$->e = e1;
          $$->expval = $1->expval != $4->expval;

          ureg = restore_stack[restore_stack.size()-1];
          restore_stack.pop_back();

          $$->expCode.insert($$->expCode.end() , $1->expCode.begin() , $1->expCode.end());
          $$->expCode.push_back("movl %eax, %" + ureg);
          $$->expCode.insert($$->expCode.end() , $4->expCode.begin() , $4->expCode.end());
          $$->expCode.push_back("cmpl %eax, %" + ureg);
          $$->expCode.push_back("setne %al");
          $$->expCode.push_back("movzbl %al, %eax");

          rstack.push_back(ureg);

       }
       ;

relational_expression:
         additive_expression
       {
       	  $$ = $1;
       }
       | relational_expression
       {
          ureg = rstack[rstack.size()-1];
          restore_stack.push_back(ureg);
          rstack.pop_back();

       } '<' additive_expression
       {
          exp_astnode* lexp;
          exp_astnode* rexp;
          lexp = $1;
          rexp = $4;

          ExpType e1;
          string OP = "LT_OP_";
          e1 = $1->e;

          if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "int"){
            OP += "INT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("int");
            lexp = new op_unary_astnode("TO_FLOAT" , $1);
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "int"){
            OP += "FLOAT";
            e1.insert("int");
            rexp = new op_unary_astnode("TO_FLOAT" , $4);
          }
          else if(($1->e.number_stars + $1->e.number_of_boxes > 0) && ($4->e.number_stars + $4->e.number_of_boxes > 0)){

             if($1->e.number_of_boxes > 0 || $4->e.number_of_boxes > 0 ){

              ExpType exp1 = $1->e;
              ExpType exp2 = $4->e;

              

              if(exp1.number_of_boxes > 0){
                exp1.number_of_boxes--;
                exp1.number_stars++;
                exp1.num.erase(exp1.num.begin());
              }

              if(exp2.number_of_boxes > 0){
                exp2.number_of_boxes--;
                exp2.number_stars++;
                exp2.num.erase(exp2.num.begin());
              }

              if(exp1.tostringtype() == exp2.tostringtype()){
                OP += "INT";
                e1.insert("int");
              }
              else{
                error(@$ , "invalid operands of types " + exp1.tostringtype() + " and " + exp2.tostringtype() + " to binary operator <");
              }

            }
            else if($1->e.tostringtype() == $4->e.tostringtype()){
              OP += "INT";
              e1.insert("int");
            }
            else{
              error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator <");
            }

          }
          else{
            error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator <");
          }

          e1.lvalue = 0;
       	  $$ = new op_binary_astnode(OP , lexp, rexp);
          $$->e = e1;
          $$->expval = $1->expval < $4->expval;

          ureg = restore_stack[restore_stack.size()-1];
          restore_stack.pop_back();

          $$->expCode.insert($$->expCode.end() , $1->expCode.begin() , $1->expCode.end());
          $$->expCode.push_back("movl %eax, %" + ureg);
          $$->expCode.insert($$->expCode.end() , $4->expCode.begin() , $4->expCode.end());
          $$->expCode.push_back("cmpl %eax, %" + ureg);
          $$->expCode.push_back("setl %al");
          $$->expCode.push_back("movzbl %al, %eax");

          rstack.push_back(ureg);


       }
       | relational_expression 
       {
          ureg = rstack[rstack.size()-1];
          restore_stack.push_back(ureg);
          rstack.pop_back();

       }'>' additive_expression
       {

          exp_astnode* lexp;
          exp_astnode* rexp;
          lexp = $1;
          rexp = $4;

          ExpType e1;
          string OP = "GT_OP_";
          e1 = $1->e;

          if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "int"){
            OP += "INT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("int");
            lexp = new op_unary_astnode("TO_FLOAT" , $1);
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "int"){
            OP += "FLOAT";
            e1.insert("int");
            rexp = new op_unary_astnode("TO_FLOAT" , $4);
          }
          else if(($1->e.number_stars + $1->e.number_of_boxes > 0) && ($4->e.number_stars + $4->e.number_of_boxes > 0)){

             if($1->e.number_of_boxes > 0 || $4->e.number_of_boxes > 0 ){

              ExpType exp1 = $1->e;
              ExpType exp2 = $4->e;

              

              if(exp1.number_of_boxes > 0){
                exp1.number_of_boxes--;
                exp1.number_stars++;
                exp1.num.erase(exp1.num.begin());
              }

              if(exp2.number_of_boxes > 0){
                exp2.number_of_boxes--;
                exp2.number_stars++;
                exp2.num.erase(exp2.num.begin());
              }

              if(exp1.tostringtype() == exp2.tostringtype()){
                OP += "INT";
                e1.insert("int");
              }
              else{
                error(@$ , "invalid operands of types " + exp1.tostringtype() + " and " + exp2.tostringtype() + " to binary operator >");
              }

            }
            else if($1->e.tostringtype() == $4->e.tostringtype()){
              OP += "INT";
              e1.insert("int");
            }
            else{
              error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator >");
            }

          }
          else{
            error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator >");
          }

          e1.lvalue = 0;
       	  $$ = new op_binary_astnode(OP , lexp, rexp);
          $$->e = e1;
          $$->expval = $1->expval > $4->expval;

          ureg = restore_stack[restore_stack.size()-1];
          restore_stack.pop_back();

          $$->expCode.insert($$->expCode.end() , $1->expCode.begin() , $1->expCode.end());
          $$->expCode.push_back("movl %eax, %" + ureg);
          $$->expCode.insert($$->expCode.end() , $4->expCode.begin() , $4->expCode.end());
          $$->expCode.push_back("cmpl %eax, %" + ureg);
          $$->expCode.push_back("setg %al");
          $$->expCode.push_back("movzbl %al, %eax");

          rstack.push_back(ureg);
            
       }
       | relational_expression
       {
          ureg = rstack[rstack.size()-1];
          restore_stack.push_back(ureg);
          rstack.pop_back();
       } 
       LE_OP additive_expression
       {
          exp_astnode* lexp;
          exp_astnode* rexp;
          lexp = $1;
          rexp = $4;

          ExpType e1;
          string OP = "LE_OP_";
          e1 = $1->e;

          if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "int"){
            OP += "INT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("int");
            lexp = new op_unary_astnode("TO_FLOAT" , $1);
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "int"){
            OP += "FLOAT";
            e1.insert("int");
            rexp = new op_unary_astnode("TO_FLOAT" , $4);
          }
          else if(($1->e.number_stars + $1->e.number_of_boxes > 0) && ($4->e.number_stars + $4->e.number_of_boxes > 0)){

             if($1->e.number_of_boxes > 0 || $4->e.number_of_boxes > 0 ){

              ExpType exp1 = $1->e;
              ExpType exp2 = $4->e;

              

              if(exp1.number_of_boxes > 0){
                exp1.number_of_boxes--;
                exp1.number_stars++;
                exp1.num.erase(exp1.num.begin());
              }

              if(exp2.number_of_boxes > 0){
                exp2.number_of_boxes--;
                exp2.number_stars++;
                exp2.num.erase(exp2.num.begin());
              }

              if(exp1.tostringtype() == exp2.tostringtype()){
                OP += "INT";
                e1.insert("int");
              }
              else{
                error(@$ , "invalid operands of types " + exp1.tostringtype() + " and " + exp2.tostringtype() + " to binary operator <=");
              }

            }
            else if($1->e.tostringtype() == $4->e.tostringtype()){
              OP += "INT";
              e1.insert("int");
            }
            else{
              error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator <=");
            }

          }
          else{
            error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator <=");
          }

          e1.lvalue = 0;
       	  $$ = new op_binary_astnode(OP , lexp, rexp);
          $$->e = e1;

          $$->expval = $1->expval <= $4->expval;

          ureg = restore_stack[restore_stack.size()-1];
          restore_stack.pop_back();

          $$->expCode.insert($$->expCode.end() , $1->expCode.begin() , $1->expCode.end());
          $$->expCode.push_back("movl %eax, %" + ureg);
          $$->expCode.insert($$->expCode.end() , $4->expCode.begin() , $4->expCode.end());
          $$->expCode.push_back("cmpl %eax, %" + ureg);
          $$->expCode.push_back("setle %al");
          $$->expCode.push_back("movzbl %al, %eax");

          rstack.push_back(ureg);

       }
       | relational_expression
        {
          ureg = rstack[rstack.size()-1];
          restore_stack.push_back(ureg);
          rstack.pop_back();
        } 
        GE_OP additive_expression
       {

          exp_astnode* lexp;
          exp_astnode* rexp;
          lexp = $1;
          rexp = $4;

          ExpType e1;
          string OP = "GE_OP_";
          e1 = $1->e;

          if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "int"){
            OP += "INT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("int");
            lexp = new op_unary_astnode("TO_FLOAT" , $1);
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "int"){
            OP += "FLOAT";
            e1.insert("int");
            rexp = new op_unary_astnode("TO_FLOAT" , $4);
          }
          else if(($1->e.number_stars + $1->e.number_of_boxes > 0) && ($4->e.number_stars + $4->e.number_of_boxes > 0)){

             if($1->e.number_of_boxes > 0 || $4->e.number_of_boxes > 0 ){

              ExpType exp1 = $1->e;
              ExpType exp2 = $4->e;

              

              if(exp1.number_of_boxes > 0){
                exp1.number_of_boxes--;
                exp1.number_stars++;
                exp1.num.erase(exp1.num.begin());
              }

              if(exp2.number_of_boxes > 0){
                exp2.number_of_boxes--;
                exp2.number_stars++;
                exp2.num.erase(exp2.num.begin());
              }

              if(exp1.tostringtype() == exp2.tostringtype()){
                OP += "INT";
                e1.insert("int");
              }
              else{
                error(@$ , "invalid operands of types " + exp1.tostringtype() + " and " + exp2.tostringtype() + " to binary operator >=");
              }

            }
            else if($1->e.tostringtype() == $4->e.tostringtype()){
              OP += "INT";
              e1.insert("int");
            }
            else{
              error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator >=");
            }

          }
          else{
            error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator >=");
          }

          e1.lvalue = 0;
       	  $$ = new op_binary_astnode(OP , lexp, rexp);
          $$->e = e1;

          $$->expval = $1->expval >= $4->expval;

          ureg = restore_stack[restore_stack.size()-1];
          restore_stack.pop_back();

          $$->expCode.insert($$->expCode.end() , $1->expCode.begin() , $1->expCode.end());
          $$->expCode.push_back("movl %eax, %" + ureg);
          $$->expCode.insert($$->expCode.end() , $4->expCode.begin() , $4->expCode.end());
          $$->expCode.push_back("cmpl %eax, %" + ureg);
          $$->expCode.push_back("setge %al");
          $$->expCode.push_back("movzbl %al, %eax");

          rstack.push_back(ureg);

       }
       ;

additive_expression:
         multiplicative_expression
       {
       	  $$ = $1;
       }
       | additive_expression 
       {
         ureg = rstack[rstack.size()-1];
         restore_stack.push_back(ureg);
         rstack.pop_back();
       }  '+' multiplicative_expression
       {
          
          exp_astnode* lexp;
          exp_astnode* rexp;
          lexp = $1;
          rexp = $4;

          ExpType e1;
          string OP = "PLUS_";
          e1 = $1->e;


          if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "int"){
            OP += "INT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("float");
          }
          else if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("float");
            lexp = new op_unary_astnode("TO_FLOAT" , $1);
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "int"){
            OP += "FLOAT";
            e1.insert("float");
            rexp = new op_unary_astnode("TO_FLOAT" , $4);
          }
          else if( ($1->e.number_stars + $1->e.number_of_boxes > 0) && $4->e.tostringtype() == "int" ){
            OP += "INT";
            e1.insert($1->e.tostringtype());

          }
          else if( ($4->e.number_stars + $4->e.number_of_boxes > 0) && $1->e.tostringtype() == "int" ){
            OP += "INT";
            e1.insert($4->e.tostringtype());
          }
          else{
            error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator +");
          }

          e1.lvalue = 0;
       	  $$ = new op_binary_astnode(OP , lexp, rexp);
          $$->e = e1;

          ureg = restore_stack[restore_stack.size()-1];
          restore_stack.pop_back();
          $$->expCode.insert($$->expCode.end() , $1->expCode.begin() , $1->expCode.end());
          $$->expCode.push_back("movl %eax, %" + ureg);
          $$->expCode.insert($$->expCode.end() , $4->expCode.begin() , $4->expCode.end());
          $$->expCode.push_back("addl %" + ureg +", %eax");
          rstack.push_back(ureg);

          $$->expval = $1->expval + $4->expval;

       }
       | additive_expression
       {

         ureg = rstack[rstack.size()-1];
         restore_stack.push_back(ureg);
         rstack.pop_back();

       } '-' multiplicative_expression
       {

          exp_astnode* lexp;
          exp_astnode* rexp;
          lexp = $1;
          rexp = $4;

          ExpType e1;
          string OP = "MINUS_";
          e1 = $1->e;

          if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "int"){
            OP += "INT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("float");
          }
          else if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("float");
            lexp = new op_unary_astnode("TO_FLOAT" , $1);
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "int"){
            OP += "FLOAT";
            e1.insert("float");
            rexp = new op_unary_astnode("TO_FLOAT" , $4);
          }
          else if( ($1->e.number_stars + $1->e.number_of_boxes > 0) && $4->e.tostringtype() == "int" ){
            OP += "INT";
            e1.insert($1->e.tostringtype());
          }
          else if( ($1->e.number_stars + $1->e.number_of_boxes > 0) && ($4->e.number_stars + $4->e.number_of_boxes > 0)){
            if($1->e.number_of_boxes > 0 || $4->e.number_of_boxes > 0 ){

              ExpType exp1 = $1->e;
              ExpType exp2 = $4->e;

              

              if(exp1.number_of_boxes > 0){
                exp1.number_of_boxes--;
                exp1.number_stars++;
                exp1.num.erase(exp1.num.begin());
              }

              if(exp2.number_of_boxes > 0){
                exp2.number_of_boxes--;
                exp2.number_stars++;
                exp2.num.erase(exp2.num.begin());
              }

              if(exp1.tostringtype() == exp2.tostringtype()){
                OP += "INT";
                e1.insert("int");
              }
              else{
                error(@$ , "invalid operands of types " + exp1.tostringtype() + " and " + exp2.tostringtype() + " to binary operator -");
              }

            }
            else if($1->e.tostringtype() == $4->e.tostringtype()){
              OP += "INT";
              e1.insert("int");
            }
            else{
              error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator -");
            }
          }
          else{
            error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator -");
          }

          e1.lvalue = 0;
       	  $$ = new op_binary_astnode(OP , lexp, rexp);
          $$->e = e1;

          ureg = restore_stack[restore_stack.size()-1];
          restore_stack.pop_back();

          $$->expCode.insert($$->expCode.end() , $1->expCode.begin() , $1->expCode.end());
          $$->expCode.push_back("movl %eax, %" + ureg);
          $$->expCode.insert($$->expCode.end() , $4->expCode.begin() , $4->expCode.end());
          $$->expCode.push_back("subl %" + ureg + ", %eax");
          $$->expCode.push_back("imull $-1, %eax" );
          

          rstack.push_back(ureg);


          $$->expval = $1->expval - $4->expval;

       }
       ;

unary_expression:
         postfix_expression
       {
       	  $$ = $1;
          if( ($1->expCode).size() >= 2 ){
            if($1->expCode[1] == "$$$$$"){
                $$->expCode.clear();
                $$->expCode.push_back( "movl " + $1->expCode[0] + ", %eax");
            }
          }
          
       }
       | unary_operator unary_expression
       {

          ExpType e1;
          e1 = $2->e;

          if($1 == "UMINUS"){

            if( e1.tostringtype() == "int" || e1.tostringtype() == "float" ){
                e1.lvalue = 0;
            }
            else{
              error(@$ , "wrong type argument to unary minus");
            }

          }

          else if($1 == "NOT"){

            if( e1.tostringtype() == "int" || e1.tostringtype() == "float" || (e1.number_of_boxes + e1.number_stars > 0) ){
                e1.lvalue = 0;
                e1.insert("int");
            }
            else{
              error(@$ , "no match for the operator !");
            }

          }
          else if($1 == "ADDRESS"){
            
            if($2->e.lvalue == 0){
              if($2->e.number_of_boxes > 0){
                e1.number_of_boxes++;
                e1.num.insert(e1.num.begin() , 1);
                e1.lvalue = 0;
              }
              else{
                error(@$ , "lvalue required as unary & operand");
              }
            }
            else{
               e1.number_of_boxes++;
               e1.num.insert(e1.num.begin() , 1);
               e1.lvalue = 0;
            }

          }

          else if($1 == "DEREF"){

            if(e1.number_of_boxes == 0){
              if(e1.number_stars == 0){
                 error(@$ , "invalid type argument of unary *");
              }
              else{
                e1.number_stars--;
              }
            }
            else{
              e1.number_of_boxes--;
              e1.num.erase(e1.num.begin());
            }

            if(e1.number_of_boxes == 0){
              e1.lvalue = 1;
            }
            else{
              e1.lvalue = 0;
            }

          }

       	  $$ = new op_unary_astnode($1 , $2);
          $$->e = e1;

          if($1 == "UMINUS"){
            
            $$->expval = -$2->expval;
            $$->expCode.insert($$->expCode.end() , $2->expCode.begin() , $2->expCode.end());
            $$->expCode.push_back("negl %eax");
          }
          else if($1 == "NOT"){
            
            $$->expval = !($2->expval);
            $$->expCode.insert($$->expCode.end() , $2->expCode.begin() , $2->expCode.end());
            $$->expCode.push_back("cmpl $0, %eax");
            $$->expCode.push_back("sete %al");
            $$->expCode.push_back("movzbl	%al, %eax");

          }

       }
       ;

multiplicative_expression:
         unary_expression
       {
       	  $$ = $1;

       }
       | multiplicative_expression 
       {
         ureg = rstack[rstack.size()-1];
         restore_stack.push_back(ureg);
         rstack.pop_back();
         
       } '*' unary_expression
       {

          exp_astnode* lexp;
          exp_astnode* rexp;
          lexp = $1;
          rexp = $4;

          ExpType e1;
          string OP = "MULT_";
          e1 = $1->e;

          if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "int"){
            OP += "INT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("float");
          }
          else if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("float");
            lexp = new op_unary_astnode("TO_FLOAT" , $1);
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "int"){
            OP += "FLOAT";
            e1.insert("float");
            rexp = new op_unary_astnode("TO_FLOAT" , $4);
          }
          else{
            error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator *");
          }

          e1.lvalue = 0;
       	  $$ = new op_binary_astnode(OP , lexp, rexp);
          $$->e = e1;

          ureg = restore_stack[restore_stack.size()-1];
          restore_stack.pop_back();
          $$->expCode.insert($$->expCode.end() , $1->expCode.begin() , $1->expCode.end());
          $$->expCode.push_back("movl %eax, %" + ureg);
          $$->expCode.insert($$->expCode.end() , $4->expCode.begin() , $4->expCode.end());
          $$->expCode.push_back("imull %" + ureg +", %eax");
          rstack.push_back(ureg);

          $$->expval = $1->expval * $4->expval;

          


          


       }
       | multiplicative_expression 
       {
         ureg = rstack[rstack.size()-1];
         restore_stack.push_back(ureg);
         rstack.pop_back();
       } '/' unary_expression
       {
       	 
          exp_astnode* lexp;
          exp_astnode* rexp;
          lexp = $1;
          rexp = $4;

          ExpType e1;
          string OP = "DIV_";
          e1 = $1->e;

          if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "int"){
            OP += "INT";
            e1.insert("int");
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("float");
          }
          else if( $1->e.tostringtype() == "int" && $4->e.tostringtype() == "float"){
            OP += "FLOAT";
            e1.insert("float");
            lexp = new op_unary_astnode("TO_FLOAT" , $1);
          }
          else if( $1->e.tostringtype() == "float" && $4->e.tostringtype() == "int"){
            OP += "FLOAT";
            e1.insert("float");
            rexp = new op_unary_astnode("TO_FLOAT" , $4);
          }
          else{
            error(@$ , "invalid operands of types " + $1->e.tostringtype() + " and " + $4->e.tostringtype() + " to binary operator /");
          }

          e1.lvalue = 0;
       	  $$ = new op_binary_astnode(OP , lexp, rexp);
          $$->e = e1;

          ureg = restore_stack[restore_stack.size()-1];
          restore_stack.pop_back();

          $$->expCode.insert($$->expCode.end() , $1->expCode.begin() , $1->expCode.end());
          $$->expCode.push_back("movl %eax, %" + ureg);
          $$->expCode.insert($$->expCode.end() , $4->expCode.begin() , $4->expCode.end());
          $$->expCode.push_back("xchg %eax, %" + ureg);
          $$->expCode.push_back("cltd");
          $$->expCode.push_back("idivl %" + ureg);

          rstack.push_back(ureg);


          $$->expval = $1->expval / $4->expval;
       }
       ;

postfix_expression:
         primary_expression
       {
       	  $$ = $1;
       }
       | postfix_expression '[' expression ']'
       {

       	  ExpType e1;

          if($3->e.type == "int" && $3->e.number_stars == 0 && $3->e.number_of_boxes == 0){

            e1 = $1->e;
            if(e1.number_of_boxes == 0){
              if(e1.number_stars == 0){
                 error(@$ , "invalid types for array subscript");
              }
              else{
                e1.number_stars--;
              }
            }
            else{
              e1.number_of_boxes--;
              e1.num.erase(e1.num.begin());
            }


          }
          else{
            error(@$ , "invalid types for array subscript" );
          }

        
          $$ = new arrayref_astnode($1 , $3);

          if(e1.number_of_boxes > 0){
            e1.lvalue = 0;
          }    
          else{
            e1.lvalue = 1;
          }

          $$->e = e1;
          

       }
       | IDENTIFIER '(' ')'
       {

          ExpType e1;
          vector<exp_astnode*> expressions;
       	  
          if(gst.Entries.count($1) == 0){
            if($1 != "printf" && $1 != "scanf"){
              error( @$ , $1 + " was not declared in this scope");
            }
            else{
              e1.insert("void");
            }
          }
          else{
            int number_param = 0;
            map<std::string , table_entries> m = gst.Entries[$1].symtab_pointer->Entries;

            for (const auto &entry : m){

              if (entry.second.scope == "param"){
                number_param++;
              }

            }

            if(number_param == 0){
              e1.insert(gst.Entries[$1].return_type);
            }
            else{
          
                error( @$ , "too many arguments to function " + $1);

            } 
          } 

          

          $$ = new funcall_astnode(expressions , $1); 
          $$->e = e1;
          $$->e.lvalue = 0;

          $$->expCode.push_back("call " + $1);

       }
       | IDENTIFIER '(' expression_list ')'
       {

          ExpType e1;
       	  
          if(gst.Entries.count($1) == 0){

            if($1 != "printf" && $1 != "scanf"){
              error( @$ , $1 + " was not declared in this scope");
            }
            else{
              e1.insert("void");
            }

          }
          else{

            size_t number_param = 0;

            map<int , table_entries> paralist;

            for (const auto &entry : gst.Entries[$1].symtab_pointer->Entries){
              if (entry.second.scope == "param"){
                number_param++;
                paralist[entry.second.offset] = entry.second;
              }

            }


            if(number_param == $3.size()){
              

              vector<table_entries> parrev;
              vector<table_entries> par;

              for (const auto &entry : paralist){    
                parrev.push_back(entry.second);
              }

              int size = parrev.size();
              for(int i= size-1 ; i >= 0 ; i--){
                par.push_back(parrev[i]);
              }
              

              for(size_t i= 0; i <par.size() ; i++){

                ExpType temp;
                temp.insert(par[i].return_type);

                if(par[i].return_type != $3[i]->e.tostringtype() ){
                  if(  (par[i].return_type == "float" || par[i].return_type == "int") &&  ( $3[i]->e.tostringtype() == "float" || $3[i]->e.tostringtype() == "int")  ){
                    if(par[i].return_type == "float" && $3[i]->e.tostringtype() == "int" ){
                      $3[i] = new op_unary_astnode("TO_FLOAT" , $3[i]);
                    }
                    else if(par[i].return_type == "int" && $3[i]->e.tostringtype() == "float" ){
                      $3[i] = new op_unary_astnode("TO_INT" , $3[i]);
                    }
                    continue;
                  }
                  else if(par[i].return_type == "void*"){

                    ExpType forvoid = $3[i]->e;
                    if(forvoid.number_of_boxes>0){
                      forvoid.number_of_boxes--;
                      forvoid.num.erase(forvoid.num.begin());
                      forvoid.number_stars++;
                    }
                    if(forvoid.number_stars > 0){
                      continue;
                    }
                    else{
                      error( @$ , "cannot convert " + forvoid.tostringtype() + " to " +   par[i].return_type );
                    }

                  }
                  else if($3[i]->e.tostringtype() == "void*"){

                    ExpType forvoid = temp;
                    if(forvoid.number_of_boxes>0){
                      forvoid.number_of_boxes--;
                      forvoid.num.erase(forvoid.num.begin());
                      forvoid.number_stars++;
                    }

                    if(forvoid.number_stars > 0){
                      continue;
                    }
                    else{
                      error( @$ , "cannot convert " + $3[i]->e.tostringtype() + " to " +   forvoid.tostringtype() );
                    }
                  }
                  else if(temp.number_of_boxes > 0 || $3[i]->e.number_of_boxes>0){
                    ExpType ee = $3[i]->e;
                    ExpType ee2 = temp;

                    if(ee2.number_of_boxes > 0){
                      ee2.number_of_boxes--;
                      ee2.number_stars++;
                      ee2.num.erase(ee2.num.begin());
                    }
                    if(ee.number_of_boxes > 0){
                      ee.number_of_boxes--;
                      ee.number_stars++;
                      ee.num.erase(ee.num.begin());
                    }
                    if(ee.tostringtype() == ee2.tostringtype()){
                      continue;
                    }
                    else{
                      error( @$ , "cannot convert " + ee.tostringtype() + " to " +   ee2.tostringtype() );
                    }
                  }
                  else{
                      error( @$ , "cannot convert " + $3[i]->e.tostringtype() + " to " +   par[i].return_type );
                  }
                }
                

              }


              e1.insert(gst.Entries[$1].return_type);

            }

            else{
                error( @$ , "wrong number of arguments to function " + $1);
            } 

            


          } 

       	  $$ = new funcall_astnode($3 , $1);
          $$->e = e1;
          $$->e.lvalue = 0;

          vector<exp_astnode*> expvec = $3;
          for(size_t i=0; i<expvec.size(); i++){
            $$->expCode.insert($$->expCode.end(), expvec[i]->expCode.begin(), expvec[i]->expCode.end() );
            $$->expCode.push_back("pushl %eax");
          }

          $$->expCode.push_back("call " + $1);
          $$->expCode.push_back("addl $" + to_string(4*expvec.size()) + ", %esp" );

          

       }
       | postfix_expression '.' IDENTIFIER
       {

          ExpType e1;

          if( $1->e.type[0] == 's' && $1->e.number_stars == 0 && $1->e.number_of_boxes == 0){
            if(gst.Entries.count($1->e.type) == 0){
              error( @$ ,  $1->e.type + " was not declared in this scope");
            }
            else{
              if(gst.Entries[$1->e.type].symtab_pointer->Entries.count($3) == 0){
                error( @$ ,  $3 + " was not declared in " + $1->e.type);
              }
              else{
                e1.insert(gst.Entries[$1->e.type].symtab_pointer->Entries[$3].return_type);
              }
            }
          }
          else{
             error( @$ , "trying to access a member of a non struct type");
          }

          identifier_astnode* id = new identifier_astnode($3);
       	  $$ = new member_astnode($1 , id);
          
          if(e1.number_of_boxes > 0){
            e1.lvalue = 0;
          }    
          else{
            e1.lvalue = 1;
          }

          $$->e = e1;

       }
       | postfix_expression PTR_OP IDENTIFIER
       {


          ExpType e1;
          if( $1->e.type[0] == 's' && ( ($1->e.number_stars == 1 && $1->e.number_of_boxes == 0) || ($1->e.number_stars == 0 && $1->e.number_of_boxes == 1) ) ){
            if(gst.Entries.count($1->e.type) == 0){
              error(@$ , $1->e.type + " was not declared in this scope" );
            }
            else{
              if(gst.Entries[$1->e.type].symtab_pointer->Entries.count($3) == 0){
                error( @$ , $3 + " was not declared in " +  $1->e.type );
              }
              else{
                e1.insert(gst.Entries[$1->e.type].symtab_pointer->Entries[$3].return_type);
              }
            }
          }
          else{
            error( @$ , "trying to access a member of a non struct type" );
          }

          identifier_astnode* id = new identifier_astnode($3);
       	  $$ = new arrow_astnode($1 , id);

          if(e1.number_of_boxes > 0){
            e1.lvalue = 0;
          }    
          else{
            e1.lvalue = 1;
          }


          $$->e = e1;

       }
       | postfix_expression INC_OP
       {
          ExpType e1;

          if( ($1->e.lvalue == 1) && ($1->e.number_of_boxes == 0)  && ( $1->e.number_stars>0 || $1->e.type == "int" || $1->e.type == "float") ){
            e1 = $1->e;
            e1.lvalue = 0;
          }
          else{
             error(@$ , "operand to ++ is incompatable or doesn't have an lvalue");
          }


       	  $$ = new op_unary_astnode("PP" , $1);
          $$->e = e1;
          $$->e.lvalue = 0;

          $$->expval = $1->expval + 1;
          $$->expCode.push_back("movl " + $1->expCode[0] + ", %eax");
          $$->expCode.push_back("addl $1, %eax");
          $$->expCode.push_back("movl %eax, " + $1->expCode[0]);
       }
       ;

primary_expression:
         IDENTIFIER
       {
            $$ = new identifier_astnode($1);
            

            if( gst.Entries[current_func].symtab_pointer->Entries.count($1) == 0){
              
              error(@$ , $1 + " was not declared in this scope");
            }
            else{
              
              $$->e.insert(gst.Entries[current_func].symtab_pointer->Entries[$1].return_type);
              if($$->e.number_of_boxes > 0){
                $$->e.lvalue = 0;
              }    
              else{
                $$->e.lvalue = 1;
              }   
              

            }

            int offset = gst.Entries[current_func].symtab_pointer->Entries[$1].offset;
            if(offset > 0){
              offset -= 4;
            }
            $$->expCode.push_back(to_string(offset) + "(%ebp)");
            $$->expCode.push_back("$$$$$");
            $$->expval = off_val[offset];
            
       }
       | INT_CONSTANT
       {
       	  $$ = new intconst_astnode($1);
          $$->e.insert("int");
          $$->e.lvalue = 0;
          if(stoi($1) == 0){
            $$->e.is_zero = 1;
          }

          
          $$->expval = stoi($1);
          $$->expCode.push_back("$"+$1);
          $$->expCode.push_back("$$$$$");


       }
       | '(' expression ')'
       {
       	  $$ = $2;
       }
       ;

expression_list:
         expression
       {
          vector<exp_astnode*> new_expression_list;
          new_expression_list.push_back($1);
          $$ = new_expression_list;
       }
       | expression_list ',' expression
       {
       	  $$ = $1;
          $$.push_back($3);
       }
       ;

unary_operator:
         '-'
       {
       	  $$ = "UMINUS";
       }
       | '!'
       {
       	  $$ = "NOT";
       }
       | '&'
       {
       	  $$ = "ADDRESS";
       }
       | '*'
       {
       	  $$ = "DEREF";
       }
       ;

selection_statement:
         IF '(' expression ')' 
         {
           code[asm_fun].insert( code[asm_fun].end() , $3->expCode.begin(), $3->expCode.end());
           code[asm_fun].push_back("cmpl $0, %eax" );
           code[asm_fun].push_back("jnle .L" + to_string(l_num) );
           if_L.push_back(asm_fun);
           asm_fun = ".L" + to_string(l_num);
           l_num++;
         } 
         statement 
         {
           code[asm_fun].push_back("jmp .L" + to_string(l_num) );
           string s = if_L[if_L.size()-1];
           if_L.pop_back();
           asm_fun = s;
           if_L.push_back(".L" + to_string(l_num));
           l_num++;

         }
         ELSE statement
       {

          if( $3->e.type[0] == 's' && $3->e.number_stars == 0 && $3->e.number_of_boxes == 0 ){
            error( @$ , "used struct type value where scaler is required"); 
          }

          string s = if_L[if_L.size()-1];
          if_L.pop_back();

          code[asm_fun].push_back("jmp " +  s);
          asm_fun = s;

       	  $$ = new if_astnode($3, $6, $9);
       }
       ;

iteration_statement:
         WHILE 
         {
           code[asm_fun].push_back("jmp .L" + to_string(l_num));
           asm_fun = ".L" + to_string(l_num);
           while_L.push_back(l_num);
           l_num++;
         } 
         '(' expression ')' 
         {
           code[asm_fun].insert( code[asm_fun].end() , $4->expCode.begin(), $4->expCode.end());
           code[asm_fun].push_back("cmpl $0, %eax" );
           code[asm_fun].push_back("jnle .L" + to_string(l_num) );
           asm_fun = ".L" + to_string(l_num);
           l_num++;
         } statement
       {

          if( $4->e.type[0] == 's' && $4->e.number_stars == 0 && $4->e.number_of_boxes == 0 ){
            error( @$ , "used struct type value where scaler is required"); 
          }

          int l = while_L[while_L.size()-1];
          while_L.pop_back();
          code[asm_fun].push_back("jmp .L" + to_string(l) );
          asm_fun = ".L" + to_string(l);
       	  $$ = new while_astnode($4, $7);
          

       }
       | FOR 
       '(' assignment_expression 
       {
          code[asm_fun].insert( code[asm_fun].end(),  $3->expCode.begin() ,  $3->expCode.end());
          code[asm_fun].push_back("jmp .L" + to_string(l_num));
          asm_fun = ".L" + to_string(l_num);
          for_L.push_back(l_num);
          l_num++;

       }';' expression 
       {

          code[asm_fun].insert( code[asm_fun].end() , $6->expCode.begin(), $6->expCode.end());
          code[asm_fun].push_back("cmpl $0, %eax" );
          code[asm_fun].push_back("jnle .L" + to_string(l_num) );
          asm_fun = ".L" + to_string(l_num+1);
          l_num += 2;

       } ';' assignment_expression ')' 
       {
          code[asm_fun].insert(code[asm_fun].end() , $9->expCode.begin() , $9->expCode.end());
          int l = for_L[for_L.size()-1];
          for_L.pop_back();
          code[asm_fun].push_back("jmp .L" + to_string(l) );
          asm_fun = ".L" + to_string(l_num-2);
          for_L.push_back(l_num-1);
  
       }
       statement
       {

          if( $6->e.type[0] == 's' && $6->e.number_stars == 0 && $6->e.number_of_boxes == 0 ){
            error( @$ , "used struct type value where scaler is required"); 
          }

          int l = for_L[for_L.size()-1];
          for_L.pop_back();
          code[asm_fun].push_back("jmp .L" + to_string(l) );

          asm_fun = ".L" + to_string(l-2);

       	  $$ = new for_astnode($3, $6, $9, $12);
          

       }
       ;

declaration_list:
         declaration
       {

       	    $$ = $1;

            vector<table_entries> vec_t = $1;

            if(is_struct == 1){
              gst.Entries[current_func].symtab_pointer = new SymbTab();
            }

            for(size_t i=0; i< vec_t.size(); i++){
              if( gst.Entries[current_func].symtab_pointer->Entries.count(vec_t[i].name) == 0){
                gst.Entries[current_func].symtab_pointer->Entries[vec_t[i].name] = vec_t[i];
              }
              else{
                error(@1 , vec_t[i].name + " is already declared");
              }
            }
            

       }
       | declaration_list declaration
       {

       	   $$ = $1;
           vector<table_entries> vec_t = $2;

           for(size_t i=0; i< vec_t.size(); i++){
             $$.push_back(vec_t[i]);
           }

           for(size_t i=0; i< vec_t.size(); i++){
              if( gst.Entries[current_func].symtab_pointer->Entries.count(vec_t[i].name) == 0){
                gst.Entries[current_func].symtab_pointer->Entries[vec_t[i].name] = vec_t[i];
              }
              else{
                error(@2 , vec_t[i].name + " is already declared");
              }
           }

       }
       ;

declaration:
         type_specifier declarator_list ';'
       {

          if($1[0] == 's'){

            if(is_struct == 1){

              if( gst.Entries.count($1) == 0){
                error( @$ , $1 + " is not defined" );
              }

              if($1 == current_func){

                for(size_t i=0; i< $2.size(); i++){
                  if($2[i].return_type[0] != '*'){
                    error(@$ , "cannot declare " + current_func + " inside the same struct");
                  }
                }

              }
            }
            else{
              if( gst.Entries.count($1) == 0){
                error( @$ , $1 + " is not defined" );
              }
            }
            
          }

          vector<table_entries> vec_t = $2;

          if($1 == "void"){
            for(size_t i=0; i< vec_t.size(); i++){

              if(vec_t[i].return_type[0] != '*'){
                error(@$ , "cannot declare variable of type void");
              }

            }
          }
          

       	  for(size_t i=0; i< vec_t.size(); i++){

            vec_t[i].scope = "local"; 

            if(vec_t[i].return_type[0] == '*'){
              vec_t[i].width = vec_t[i].width * 4;
            }
            else{
              if($1 == "void"){
                vec_t[i].width = vec_t[i].width * 4;
              }
              else if($1 == "int"){
                vec_t[i].width = vec_t[i].width * 4;
              }
              else if($1 == "float"){
                vec_t[i].width = vec_t[i].width * 4;
              }
              else{
                for (auto it = gst.Entries.begin(); it != gst.Entries.end(); ++it){
                  if(it->first == $1){
                      vec_t[i].width = vec_t[i].width *  it->second.width;
                      break;
                  }
                }   
              }
              
            }
            vec_t[i].return_type = $1 + vec_t[i].return_type;

          }

          
          $$ = vec_t;
       }
       ;

declarator_list:
         declarator
       {
            vector<table_entries> vec_t;
            vec_t.push_back($1);
            $$ = vec_t;
       	      
       }
       | declarator_list ',' declarator
       {
       	   $$ = $1;
           $$.push_back($3);
       }
       ;
      
%%
void IPL::Parser::error( const location_type &l, const std::string &err_message )
{
   std::cout << "Error at line " << l.begin.line << ": " << err_message << "\n";
   exit(1);
}




