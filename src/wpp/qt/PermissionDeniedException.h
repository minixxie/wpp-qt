#ifndef __QT_APP_BASE__PERMISSION_DENIED_EXCEPTION_H__
#define __QT_APP_BASE__PERMISSION_DENIED_EXCEPTION_H__

#include <QException>

namespace wpp
{
namespace qt
{

class PermissionDeniedException : public QException
{
public:
	void raise() const { throw *this; }
	PermissionDeniedException *clone() const { return new PermissionDeniedException(*this); }
};

}//namespace qt
}//namespace wpp

#endif

