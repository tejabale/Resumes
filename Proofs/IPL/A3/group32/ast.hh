
#ifndef AST_HH
#define AST_HH

#include "type.hh"
#include<vector>
#include<string>
#include<iostream>
using namespace std;


class abstract_astnode
{
    public:
        virtual void print(int blanks) = 0;
};

class statement_astnode : public abstract_astnode{
    public:
        int is_empty;
        vector<string> stmCode;
    
};

class exp_astnode : public abstract_astnode{
    public:
        ExpType e;
        vector<string> expCode;
        int expval;
};

class ref_astnode : public exp_astnode{

};



class empty_astnode : public statement_astnode{
    public:
        void print(int blanks);
        empty_astnode(){
            is_empty = 1;
        }
};

class seq_astnode : public statement_astnode{
    public:
        vector<statement_astnode*> statement_astnodes;
        void print(int blanks);
        seq_astnode(){
            is_empty = 0;
        }
};

class assignS_astnode : public statement_astnode{
    public:
        void print(int blanks);
        exp_astnode* lvalue;
        exp_astnode* rvalue;
        assignS_astnode( exp_astnode* lvalue , exp_astnode* rvalue){
            this->lvalue = lvalue;
            this->rvalue = rvalue;
            is_empty = 0;
        }
        assignS_astnode(){
            is_empty = 0;
        }
};

class return_astnode : public statement_astnode{
    public:
        void print(int blanks);
        exp_astnode* return_exp;
        return_astnode(exp_astnode* return_exp){
            this->return_exp = return_exp;
            is_empty = 0;
        }
        return_astnode(){
            is_empty = 0;
        }
};

class if_astnode : public statement_astnode{
    public:
        void print(int blanks);
        exp_astnode* if_exp;
        statement_astnode* if_statement;
        statement_astnode* else_statement;
        if_astnode(exp_astnode* if_exp, statement_astnode* if_statement, statement_astnode* else_statement){
            this->if_exp = if_exp;
            this->if_statement = if_statement;
            this->else_statement = else_statement;
            is_empty = 0;
        }
        if_astnode(){
            is_empty = 0;
        }
};

class while_astnode : public statement_astnode{
    public:
        void print(int blanks);
        exp_astnode* while_exp;
        statement_astnode* while_statement;
        while_astnode(exp_astnode* while_exp, statement_astnode* while_statement){
            this->while_exp = while_exp;
            this->while_statement = while_statement;
            is_empty = 0;
        }
        while_astnode(){
            is_empty = 0;
        }

};

class for_astnode : public statement_astnode{
    public:
        void print(int blanks);
        exp_astnode* initilizer_exp;
        exp_astnode* gaurd_exp;
        exp_astnode* step_exp;
        statement_astnode* for_statement;
        for_astnode(exp_astnode* initilizer_exp, exp_astnode* gaurd_exp, exp_astnode* step_exp, statement_astnode* for_statement){
            this->initilizer_exp = initilizer_exp;
            this->gaurd_exp = gaurd_exp;
            this->step_exp = step_exp;
            this->for_statement = for_statement;
            is_empty = 0;
        }
        for_astnode(){
            is_empty = 0;
        }

};

class proccall_astnode : public statement_astnode{
    public:
        void print(int blanks);
        vector<exp_astnode*> exp_astnodes;
        string fname;
        proccall_astnode(string fname){
            this->fname = fname;
            is_empty = 0;
        }
        proccall_astnode(string fname, vector<exp_astnode*> exp_astnodes){
            this->fname = fname;
            this->exp_astnodes = exp_astnodes;
            is_empty = 0;
        }
        proccall_astnode(){
            is_empty = 0;
        }
};

class printf_astnode : public statement_astnode{
    public:
        void print(int blanks);
        vector<exp_astnode*> exp_astnodes;
        string svalue;
        printf_astnode(string svalue, vector<exp_astnode*> exp_astnodes ){
            this->svalue = svalue;
            this->exp_astnodes = exp_astnodes;
            is_empty = 0;
        }
};


class identifier_astnode : public ref_astnode{
    public:
        void print(int blanks);
        string identifier;
        identifier_astnode(string id){
            this->identifier = id;
        }
};

class arrayref_astnode : public ref_astnode{
    public:
        void print(int blanks);
        exp_astnode* exp1;
        exp_astnode* exp2;
        arrayref_astnode(exp_astnode* exp1 , exp_astnode* exp2){
            this->exp1 = exp1;
            this->exp2 = exp2;
        }
};

class member_astnode : public ref_astnode{
    public:
        void print(int blanks);
        exp_astnode* exp1;
        identifier_astnode* identifier;
        member_astnode(exp_astnode* exp1, identifier_astnode* identifier){
            this->exp1 = exp1;
            this->identifier = identifier;
        }
};

class arrow_astnode : public ref_astnode{
    public:
        void print(int blanks);
        exp_astnode* exp1;
        identifier_astnode* identifier;
        arrow_astnode(exp_astnode* exp1, identifier_astnode* identifier){
            this->exp1 = exp1;
            this->identifier = identifier;
        }
};




class op_binary_astnode : public exp_astnode{
    public:
        void print(int blanks);
        string OP;
        exp_astnode* lexp;
        exp_astnode* rexp;
        op_binary_astnode(string OP, exp_astnode* lexp, exp_astnode* rexp){
            this->OP = OP;
            this->lexp = lexp;
            this->rexp = rexp;
        }
};

class op_unary_astnode : public exp_astnode{
    public:
        void print(int blanks);
        string OP;
        exp_astnode* exp;
        op_unary_astnode(string OP, exp_astnode* exp){
            this->OP = OP;
            this->exp = exp;
        }
};

class assignE_astnode : public exp_astnode{
    public:
        void print(int blanks);
        exp_astnode* lexp;
        exp_astnode* rexp;
        assignE_astnode( exp_astnode* lexp , exp_astnode* rexp){
            this->lexp = lexp;
            this->rexp = rexp;
        }
};

class funcall_astnode : public exp_astnode{
    public:
        void print(int blanks);
        vector<exp_astnode*> expressions;
        string fname;
        funcall_astnode(vector<exp_astnode*> expressions, string fname){
            this->expressions = expressions;
            this->fname= fname;
        }
};

class intconst_astnode : public exp_astnode{
    public:
        void print(int blanks);
        int value;
        intconst_astnode(string val){
            this->value = stoi(val);
        }
};

class floatconst_astnode : public exp_astnode{
    public:
        void print(int blanks);
        float value;
        floatconst_astnode(string val){
            this->value = stof(val);
        }
};

class stringconst_astnode : public exp_astnode{
    public:
        void print(int blanks);
        string value;
        stringconst_astnode(string val){
            this->value = val;
        }
};

#endif


