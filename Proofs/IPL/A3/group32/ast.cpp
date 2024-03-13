#include "ast.hh"
using namespace std;

void printf_astnode::print(int blanks){
    cout << "print\n" << endl;
}
void empty_astnode::print(int balnks){
    cout << "\"empty\"";
}

void seq_astnode::print(int blanks){

    cout << "\"seq\": [";
    size_t vec_size = (this->statement_astnodes).size();

    for(size_t i=0; i<vec_size; i++){
        
        if(this->statement_astnodes[i]->is_empty == 0){
            cout << "{";
        }

        this->statement_astnodes[i]->print(0);

        if(this->statement_astnodes[i]->is_empty == 0){
            if(i == vec_size-1){
                cout << "}";
            }
            else{
                cout << "},";
            }
        }
        else{
            if(i != vec_size-1){
                cout << ",";
            }
        }
    }

    cout << "]";
}

void assignS_astnode::print(int blanks){
    cout << "\"assignS\": {";

    cout << "\"left\": {";
    this->lvalue->print(0);
    cout << "},";

    cout << "\"right\": {";
    this->rvalue->print(0);
    cout << "}";

    cout << "}";
}

void return_astnode::print(int blanks){
    cout << "\"return\": {";
    this->return_exp->print(0);
    cout << "}";
}

void if_astnode::print(int blanks){
    cout << "\"if\": {";

        
        cout << "\"cond\": {";
        this->if_exp->print(0);
        cout << "},";


        
        if(this->if_statement->is_empty == 0){
            cout << "\"then\": {";
        }
        else{
            cout << "\"then\": ";
        }

        
        this->if_statement->print(0);
        
        if(this->if_statement->is_empty == 0){
            cout << "},";
        }
        else{
            cout << ",";
        }


        if(this->else_statement->is_empty == 0){
            cout << "\"else\": {";
        }
        else{
            cout << "\"else\": ";
        }

        this->else_statement->print(0);

        if(this->else_statement->is_empty == 0){
            cout << "}";
        }

    
    cout << "}";
}

void while_astnode::print(int blanks){
    cout << "\"while\": {";

        cout << "\"cond\": {";
        this->while_exp->print(0);
        cout << "},";

        if(this->while_statement->is_empty == 0){
            cout << "\"stmt\": {";
        }
        else{
            cout << "\"stmt\": ";
        }
    
        this->while_statement->print(0);


        if(this->while_statement->is_empty == 0){
            cout << "}";
        }

    
    cout << "}";
}


void for_astnode::print(int blanks){
    cout << "\"for\": {";

        cout << "\"init\": {";
        this->initilizer_exp->print(0);
        cout << "},";

        cout << "\"guard\": {";
        this->gaurd_exp->print(0);
        cout << "},";

        cout << "\"step\": {";
        this->step_exp->print(0);
        cout << "},";


        if(this->for_statement->is_empty == 0){
            cout << "\"body\": {";
        }
        else{
            cout << "\"body\": ";
        }

        
        this->for_statement->print(0);
        
        if(this->for_statement->is_empty == 0){
            cout << "}";
        }

    
    cout << "}";
}

void proccall_astnode::print(int blanks){

    cout << "\"proccall\": {";

        cout << "\"fname\": {";
        cout << "\"identifier\": \"" << this->fname  << "\"";
        cout << "},";

        cout << "\"params\": [";
        size_t vec_size = (this->exp_astnodes).size();

        for(size_t i=0; i<vec_size; i++){
            cout << "{";
            this->exp_astnodes[i]->print(0);
            if(i == vec_size-1){
                cout << "}";
            }
            else{
                cout << "},";
            }
        }

        cout << "]";

    
    cout << "}";
}



void identifier_astnode::print(int blanks){

    cout << "\"identifier\": \"" << this->identifier  << "\"";

}


void arrayref_astnode::print(int blanks){

    cout << "\"arrayref\": {";

        cout << "\"array\": {";
        this->exp1->print(0);
        cout << "},";

        cout << "\"index\": {";
        this->exp2->print(0);
        cout << "}";

    
    cout << "}";

}


void member_astnode::print(int blanks){

    cout << "\"member\": {";

        cout << "\"struct\": {";
        this->exp1->print(0);
        cout << "},";

        cout << "\"field\": {";
        this->identifier->print(0);
        cout << "}";

    
    cout << "}";

}


void arrow_astnode::print(int blanks){

    cout << "\"arrow\": {";

        cout << "\"pointer\": {";
        this->exp1->print(0);
        cout << "},";

        cout << "\"field\": {";
        this->identifier->print(0);
        cout << "}";

    
    cout << "}";

}


void op_binary_astnode::print(int blanks){

    
    cout << "\"op_binary\": {";

        cout << "\"op\": \"" << this->OP  << "\",";

        cout << "\"left\": {";
        this->lexp->print(0);
        cout << "},";

        cout << "\"right\": {";
        this->rexp->print(0);
        cout << "}";

    
    cout << "}";

}



void op_unary_astnode::print(int blanks){

    cout << "\"op_unary\": {";

        cout << "\"op\": \"" << this->OP  << "\",";

        cout << "\"child\": {";
        this->exp->print(0);
        cout << "}";

    
    cout << "}";

}


void assignE_astnode::print(int blanks){

    cout << "\"assignE\": {";

        cout << "\"left\": {";
        this->lexp->print(0);
        cout << "},";

        cout << "\"right\": {";
        this->rexp->print(0);
        cout << "}";

    
    cout << "}";

}


void funcall_astnode::print(int blanks){

    cout << "\"funcall\": {";

        cout << "\"fname\": {";
        cout << "\"identifier\": \"" << this->fname  << "\"";
        cout << "},";

        cout << "\"params\": [";

        size_t vec_size = (this->expressions).size();

        for(size_t i=0; i<vec_size; i++){
            cout << "{";
            this->expressions[i]->print(0);
            if(i == vec_size-1){
                cout << "}";
            }
            else{
                cout << "},";
            }
        }

        cout << "]";

    
    cout << "}";
}


void intconst_astnode::print(int blanks){

    cout << "\"intconst\": " << this->value;

}


void floatconst_astnode::print(int blanks){

    cout << "\"floatconst\": " << this->value;

}

void stringconst_astnode::print(int blanks){

    cout << "\"stringconst\": " << this->value ;

}



