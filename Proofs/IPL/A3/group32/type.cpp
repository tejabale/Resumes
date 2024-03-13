#include "type.hh"
#include "symbtab.hh" 

void ExpType::insert(string s){

        if(s[0] == 'v'){
            this->type = "void";
        }
        else if(s[0] == 'i'){
            this->type = "int";
        }
        else if(s[0] == 'f'){
            this->type = "float";
        }
        else if(s[0] == 's'){
            string temp;

            for(size_t i=0; i<s.length(); i++){
                if(s[i] == '*' || s[i] == '['){
                    break;
                }
                temp += s[i];
            }

            this->type = temp;

        }
        
        this->number_stars = 0;

        for(size_t i=0; i<s.length(); i++){

            if(s[i] == '*'){
                this->number_stars++;
            }

        }

        bool left = 0;
        string temp1;

        this->number_of_boxes = 0;
        this->num.clear();
        
        for(size_t i=0; i<s.length(); i++){

            if(s[i] == ']'){
                
                left = 0;
                this->num.push_back(stoi(temp1));
                temp1 = "";
                continue;
            }

            if(s[i] == '['){
                this->number_of_boxes++;
                left = 1;
                temp1 = "";
                continue;
            }

            if(left){
                temp1 += s[i];
                continue;
            }

        }
}


string ExpType::tostringtype(){
    string s = this->type;

    for(int i=0; i<this->number_stars; i++){
        s = s + "*";
    }

    for(int i=0; i<this->number_of_boxes; i++){
        s = s + "[" + to_string(this->num[i]) + "]";
    }

    return s;

}

