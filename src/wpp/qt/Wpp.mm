#include "Wpp.h"
#include <QGuiApplication>
#include <QtGui/qpa/qplatformnativeinterface.h>

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#if defined(Q_OS_MAC) && !defined(Q_OS_IOS)
	#include <QtMac>
#endif

namespace wpp
{
namespace qt
{

void Wpp::initDeviceId()
{
	NSUUID *identifierForVendor = [[UIDevice currentDevice] identifierForVendor];
	NSString *deviceId = [identifierForVendor UUIDString];
	QString deviceIdQString( [deviceId UTF8String] );

	this->deviceId = deviceIdQString;
	emit this->deviceIdChanged();
}

int Wpp::getIOSVersion()
{

	NSArray *comp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];

	return [[comp objectAtIndex:0] intValue];
}

void Wpp::enableAutoScreenOrientation(bool enable)
{
	__IMPLEMENTATION_DETAIL_ENABLE_AUTO_ROTATE = enable;
}

void Wpp::registerApplePushNotificationService()
{
	UIApplication *application = [UIApplication sharedApplication];
	if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
		UIUserNotificationType userNotificationTypes =
				(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);

		[application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:userNotificationTypes
																						categories:nil]];
		[application registerForRemoteNotifications]; // you can also set here for local notification.
	} else {
		UIUserNotificationType userNotificationTypes =
				(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge);

		[application registerForRemoteNotificationTypes:userNotificationTypes];
	}
/*
        if ( [[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)] )
        {
                UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                                                                                UIUserNotificationTypeBadge |
                                                                                                                UIUserNotificationTypeSound);
                UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes

                     categories:nil];
                [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                [[UIApplication sharedApplication] registerForRemoteNotifications];

        }
        else
        {
                [[UIApplication sharedApplication] registerForRemoteNotificationTyes:
                        (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
        }

*/
}

void Wpp::addToImageGallery(const QString& imageFullPath)
{
//http://stackoverflow.com/questions/12609301/how-to-save-the-image-on-iphone-in-the-gallery

	NSString *imagePath = imageFullPath.toNSString();

	NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]];
	UIImage* image = [UIImage imageWithData:data];

	UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

void Wpp::setAppIconUnreadCount(int count)
{
#ifdef Q_OS_IOS
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
#endif
#if defined(Q_OS_MAC) && !defined(Q_OS_IOS)
	QtMac::setApplicationIconBadgeNumber(count);
#endif

}

bool Wpp::dial(const QString& phone, bool direct)
{
	NSString *phNo = phone.toNSString();
	NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@",phNo]];

	if ([[UIApplication sharedApplication] canOpenURL:phoneUrl])
	{
		[[UIApplication sharedApplication] openURL:phoneUrl];
		return true;
	}
	else
	{
		return false;
	}
}

}//namespace qt
}//namespace wpp

