#include "symbtab.hh"


void SymbTab::printgst(){

    for (auto it = Entries.begin(); it != Entries.end(); ++it){

        cout << "[" << endl;

        cout << "\"" <<  it->first <<  "\",";
        cout << "\"" <<  it->second.varfun <<  "\",";
        cout << "\"" <<  it->second.scope <<  "\",";
        cout << it->second.width <<  ",";
        if(it->second.offset == -1 && it->second.varfun == "struct"){
            cout << "\"-\",";
        }
        else{
            cout << it->second.offset <<  ",";
        }
        cout << "\"" <<  it->second.return_type <<  "\"";

        cout << "]" << endl;

        if (next(it,1) != Entries.end()){ 
            cout << "," << endl;
        }
    }


}

void SymbTab::print(){

    for (auto it = Entries.begin(); it != Entries.end(); ++it){

        cout << "[" << endl;

        cout << "\"" <<  it->first <<  "\",";
        cout << "\"" <<  it->second.varfun <<  "\",";
        cout << "\"" <<  it->second.scope <<  "\",";
        cout << it->second.width <<  ",";
        cout << it->second.offset <<  ",";
        cout << "\"" <<  it->second.return_type <<  "\"";

        cout << "]" << endl;

        if (next(it,1) != Entries.end()){ 
            cout << "," << endl;
        }
    }


}