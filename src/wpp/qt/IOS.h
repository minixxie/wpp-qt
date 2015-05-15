#ifndef __WPP__QT__IOS_H__
#define __WPP__QT__IOS_H__

#include <QString>

namespace wpp
{
namespace qt
{

class IOS
{
public:
	static void excludeICloudBackup(const QString& path);
	static void documentsDirectoryExcludeICloudBackup();
};

}//namespace qt
}//namespace wpp

#endif
