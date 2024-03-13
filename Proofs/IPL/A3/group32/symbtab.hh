#ifndef SYMBTAB_HH
#define SYMBTAB_HH

#include "type.hh"

#include <iostream>
#include <string>
#include <map>
using namespace std;

class SymbTab;

class table_entries{

    public:
        string name;
        string varfun;
        string scope;
        int width;
        int offset;
        string return_type;
        SymbTab* symtab_pointer;
};

class SymbTab{
    public:
        map<string , table_entries> Entries;
        void printgst();
        void print();
};

#endif