#ifndef __QT_APP_BASE__READ_ADDRESS_BOOK_PERMISSION_DENIED_EXCEPTION_H__
#define __QT_APP_BASE__READ_ADDRESS_BOOK_PERMISSION_DENIED_EXCEPTION_H__

#include "PermissionDeniedException.h"

namespace wpp
{
namespace qt
{

class ReadAddressBookPermissionDeniedException : public PermissionDeniedException
{
public:
	void raise() const { throw *this; }
	ReadAddressBookPermissionDeniedException *clone() const { return new ReadAddressBookPermissionDeniedException(*this); }
};

}//namespace qt
}//namespace wpp

#endif

