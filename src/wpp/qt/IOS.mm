#include "IOS.h"

#include <QString>
#include <UIKit/UIKit.h>

#import "Foundation/NSURL.h"

namespace wpp
{
namespace qt
{

void IOS::excludeICloudBackup(const QString& path)
{
	const char *charString = path.toStdString().c_str();
	NSString * pathStr = [NSString stringWithUTF8String:charString];
	NSURL *url = [NSURL URLWithString:pathStr];
	//exclude backup to iCloud
	[url setResourceValue:[NSNumber numberWithBool:YES] forKey:@"NSURLIsExcludedFromBackupKey" error:nil];

}

void IOS::documentsDirectoryExcludeICloudBackup()
{
	NSURL *documentsPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	[documentsPath setResourceValue:[NSNumber numberWithBool:YES] forKey:@"NSURLIsExcludedFromBackupKey" error:nil];
}

}//namespace qt
}//namespace wpp

