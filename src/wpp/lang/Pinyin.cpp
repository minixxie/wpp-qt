#include "Pinyin.h"

#include <sstream>

namespace wpp {
namespace lang {

std::string Pinyin::from( wchar_t c, bool firstOnly )
{
        for ( int i = 0 ; i < DATA_COUNT; i++ )
        {
                unsigned short *pinyinLinePtr = reinterpret_cast<unsigned short*>( DATA[i] );
                //printf( "char = %04x\n", *pinyinLinePtr );
                const char *pinyinListPtr = reinterpret_cast<const char*>( DATA[i] + 3 );
                if ( (wchar_t)*pinyinLinePtr == c )
                {
			if ( !firstOnly )
				return std::string(pinyinListPtr);
			else
			{
                        	std::stringstream ss( pinyinListPtr );
				std::string result;
				ss >> result;
				return result;
			}
                }
        }
	return std::string();
}

std::string Pinyin::from( wchar_t s[], int length )
{
	std::stringstream ss;
	for ( int i = 0 ; i < length ; i++ )
	{
		std::string pinyin = from(s[i], true);
		if ( i != 0 && !pinyin.empty() )
			ss << ' ';
		if ( !pinyin.empty() )
		ss << pinyin;
	}
	return ss.str();

}

}
}
