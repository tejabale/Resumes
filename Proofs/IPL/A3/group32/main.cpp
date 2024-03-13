
#include "scanner.hh"
#include "parser.tab.hh"
#include <fstream>
using namespace std;

SymbTab gst, gstfun, gststruct; 
string filename;
extern std::map<string,abstract_astnode*> ast;
extern std::map<int,std::vector<std::string> > LC;
extern std::vector<std::string> final_code;
extern std::map<std::string , std::vector<std::string> > code;




int main(int argc, char **argv)
{
	using namespace std;
	fstream in_file, out_file;
	
	

	in_file.open(argv[1], ios::in);
	std::string str = argv[1];
	str = "\"" + str ; 
	str = str + "\"" ;
	final_code.push_back( ".file " +str );
	final_code.push_back(".text");
	final_code.push_back(".section .rodata");

	



	IPL::Scanner scanner(in_file);

	IPL::Parser parser(scanner);

#ifdef YYDEBUG
	parser.set_debug_level(1);
#endif
parser.parse();
// create gstfun with function entries only

for (const auto &entry : LC)
{
	str  = ".LC" + to_string(entry.first);
	str +=  ":";
	final_code.push_back(str);
	for(size_t i =0; i<entry.second.size(); i++){
		final_code.push_back(entry.second[i]);
	}
}

for (const auto &entry : code)
{
	str  = entry.first;
	str +=  ":";
	final_code.push_back(str);
	for(size_t i =0; i<entry.second.size(); i++){
		final_code.push_back(entry.second[i]);
	}
}


for(size_t i =0; i<final_code.size(); i++){
	cout << final_code[i] << endl;
}




for (const auto &entry : gst.Entries)
{
	if (entry.second.varfun == "fun")
	gstfun.Entries.insert({entry.first, entry.second});
}
// create gststruct with struct entries only

for (const auto &entry : gst.Entries)
{
	if (entry.second.varfun == "struct")
	gststruct.Entries.insert({entry.first, entry.second});
}

	fclose(stdout);

}




