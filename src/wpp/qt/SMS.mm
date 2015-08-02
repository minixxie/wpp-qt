#include <UIKit/UIKit.h>
#include <QtGui/qpa/qplatformnativeinterface.h>
#include <QtGui>
#include <QtQuick>
#import <MessageUI/MessageUI.h>

#include "SMS.h"

@interface SMSDelegate : NSObject <MFMessageComposeViewControllerDelegate> {
	wpp::qt::SMS *m_sms;
}
@end

@implementation SMSDelegate

- (id) initWithQtClass:(wpp::qt::SMS *)sms
{
	self = [super init];
    if (self) {
		m_sms = sms;
    }
    return self;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result)
	{
		case MessageComposeResultCancelled:
			NSLog(@"Cancelled");
			emit m_sms->cancelled();
		break;
		case MessageComposeResultFailed:
			/*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MyApp" message:@"Unknown Error"
														   delegate:self cancelButtonTitle:@”OK” otherButtonTitles: nil];
			[alert show];
			[alert release];*/
			emit m_sms->failed();
		break;
		case MessageComposeResultSent:
			emit m_sms->sent();
		break;
		default:
		break;
	}

    // Update imagePath property to trigger QML code:
	//m_iosCamera->m_imagePath = QStringLiteral("file:") + QString::fromNSString(path);
	//m_sms->m_imagePath = QString::fromNSString(path);
	//emit m_sms->imagePathChanged();

    // Bring back Qt's view controller:
    UIViewController *rvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rvc dismissViewControllerAnimated:YES completion:nil];
}

@end

namespace wpp {
namespace qt {

SMS::SMS(QQuickItem *parent) :
	QQuickItem(parent), m_delegate((__bridge_retained void*)[[SMSDelegate alloc] initWithQtClass:this])
{
}

void SMS::open()
{
	// Get the UIView that backs our QQuickWindow:
	UIView *view = (__bridge UIView *)(
				QGuiApplication::platformNativeInterface()
				->nativeResourceForWindow("uiview", window() ));
	UIViewController *qtController = [[view window] rootViewController];


	MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
	if([MFMessageComposeViewController canSendText])
	{

		controller.body = msg().toNSString();
		controller.recipients = [NSArray arrayWithObjects:phone().toNSString(), nil];
		//controller.messageComposeDelegate = self;
		controller.messageComposeDelegate = (__bridge id)(m_delegate);
		//[qtController presentModalViewController:controller animated:YES];
		[qtController presentViewController:controller animated:YES completion:nil];

	}
}

}
}
