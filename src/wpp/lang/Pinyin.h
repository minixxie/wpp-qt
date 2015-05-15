#ifndef __WPP__LANG__PINYIN_H__
#define __WPP__LANG__PINYIN_H__

#include <string>

namespace wpp {
namespace lang {

class Pinyin
{
private:
	static char DATA[][50];
	static int DATA_COUNT;
public:
	static std::string from( wchar_t c, bool firstOnly = true );
	static std::string from( wchar_t c[], int length );


};

}
}

#endif
