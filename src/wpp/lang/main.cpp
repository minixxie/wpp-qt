#include "Pinyin.h"

#include <iostream>
#include <string>

int main()
{
	wchar_t c = 0x9fa5;

	std::string pinyin = wpp::lang::Pinyin::from( c );
	std::cout << "pinyin: " << pinyin << std::endl;
	
	return 0;
}
