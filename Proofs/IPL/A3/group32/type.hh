#ifndef TYPE_HH
#define TYPE_HH

#include<vector>
#include<string>
#include<iostream>
using namespace std;

class ExpType{

    public:
        string type;
        int number_stars;
        int number_of_boxes;
        int lvalue;
        vector<int> num;
        int is_zero;

        ExpType(){
            this->number_stars = 0;
            this->number_of_boxes = 0;
            this->lvalue = 0;
            this->is_zero = 0;
        }

        void insert(string s);
        string tostringtype();

};



#endif