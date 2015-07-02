#include <UIKit/UIKit.h>

#include "NativeDateTimePicker.h"

#include "System.h"

#import <ActionSheetDatePicker.h>
#import "ActionSheetCustomPickerDelegate.h"
#import <NSDate+TCUtils.h>

@interface WppDatePickerDelegate : NSObject <ActionSheetCustomPickerDelegate>
{
	wpp::qt::NativeDateTimePicker *m_nativeDateTimePicker;
}

@end

@implementation WppDatePickerDelegate
- (id) initWithNativeDateTimePicker:(wpp::qt::NativeDateTimePicker *)nativeDateTimePicker
{
	NSLog(@"initWithNativeDateTimePicker");
	self = [super init];
	if (self) {
		m_nativeDateTimePicker = nativeDateTimePicker;
	}
	return self;
}
- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element
{
	NSLog(@"date selected: %@", selectedDate);
	QDateTime dateTime = QDateTime::fromTime_t( selectedDate.timeIntervalSince1970 );
	qDebug() << "QDateTime=" << dateTime;

	//m_nativeDateTimePicker->setDateTime(dateTime);
	m_nativeDateTimePicker->setMsecSinceEpoch(dateTime.toMSecsSinceEpoch());
	emit m_nativeDateTimePicker->picked(dateTime.toMSecsSinceEpoch());
}
@end

wpp::qt::NativeDateTimePicker *__gSingletonDateTimePicker = 0;

namespace wpp {
namespace qt {


NativeDateTimePicker::NativeDateTimePicker(QQuickItem *parent)
	: QQuickItem(parent),
	  m_msecSinceEpoch(0),
	m_timeZoneId( wpp::qt::System::getSystemTimezoneId() ),
	m_delegate((__bridge_retained void*)[[WppDatePickerDelegate alloc] initWithNativeDateTimePicker:this])
{
	//uint initTS = QDateTime::currentDateTime().toTime_t();
	//initTS -= initTS % 60;//assign seconds to 0
	//m_dateTime.setTime_t( initTS );
	m_msecSinceEpoch = QDateTime::currentMSecsSinceEpoch();

	__gSingletonDateTimePicker = this;

	connect(this, SIGNAL(timeZoneIdChanged()), this, SLOT(onTimeZoneIdChanged));

}

void NativeDateTimePicker::open()
{
	NativeDateTimePicker *thisPtr = this;

	UIViewController *rvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];

	[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;//hacky fix

	qDebug() << "init qDateTime=" << this->msecSinceEpoch();
	uint initTS = this->msecSinceEpoch()/1000;
	//initTS -= initTS % 60;//assign seconds to 0
	qDebug() << "init TS=" << initTS;
	NSDate *initDate = [NSDate dateWithTimeIntervalSince1970:initTS];

	ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@""
		datePickerMode:UIDatePickerModeDateAndTime
		selectedDate:initDate
		minimumDate:nil
		maximumDate:nil
		target:(__bridge id)m_delegate
		action:@selector(dateWasSelected:element:)
		origin:rvc.view];

	NSString *timezoneId = this->timeZoneId().toNSString();
	NSLog(@"init timezone: %@", timezoneId);
	actionSheetPicker.timeZone = [NSTimeZone timeZoneWithName:timezoneId];

	[actionSheetPicker addCustomButtonWithTitle:@"Today" value:[NSDate date]];
	[actionSheetPicker addCustomButtonWithTitle:@"Yesterday" value:[[NSDate date] TC_dateByAddingCalendarUnits:NSCalendarUnitDay amount:-1]];
	actionSheetPicker.hideCancel = YES;
	[actionSheetPicker showActionSheetPicker];


#if 0
	UIActionSheet *menu = nil;
	UIAlertController *alert = nil;
	if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)) {
//NSString *title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
		menu = [[UIActionSheet alloc] initWithTitle:@"Date Picker"
														  delegate:nil
												 cancelButtonTitle:@"Cancel"
											destructiveButtonTitle:nil
												 otherButtonTitles:@"",@"",@"",nil ];
	}
	else {//iOS8.0+
		alert = [UIAlertController alertControllerWithTitle:@""
									  message:@"" //"\n\n\n\n\n\n\n\n"
									  preferredStyle:UIAlertControllerStyleActionSheet];
	}


	CGRect datePickerRect = CGRectMake(0, 0, 500, 800);
	UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-8, 4, 320, 160)]; // [[UIDatePicker alloc] initWithFrame:datePickerRect];

	qDebug() << "init qDateTime=" << this->dateTime();
	uint initTS = this->dateTime().toTime_t();
	initTS -= initTS % 60;//assign seconds to 0
	qDebug() << "init TS=" << initTS;
	NSDate *initDate = [NSDate dateWithTimeIntervalSince1970:initTS];
	NSLog(@"init NSDate=%@", initDate);
	[datePicker setDate:initDate animated:YES];

	NSString *timezoneId = this->timezoneId().toNSString();
	NSLog(@"current timezone: %@", timezoneId);
	datePicker.timeZone = [NSTimeZone timeZoneWithName:timezoneId];
	//datePicker.backgroundColor = [UIColor redColor];

	UIViewController *rvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
	if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending))
	{
		//menu.frame = CGRectMake(0,0,0,0);
		//UIView *grayLayer = menu.subviews[1];
		//grayLayer.frame = CGRectMake(0,0,0,0);
		//[rvc.view addSubview:menu];
		NSLog(@"navigationController:%p", rvc.navigationController);
		[menu showInView:rvc.navigationController.view];

		//[menu showFromRect:CGRectMake(0,300,320,200) inView:rvc.view animated:YES];

		//CGRect menuRect = menu.frame;
		//CGFloat orgHeight = menuRect.size.height;
		//menuRect.origin.y -= 214-30; //height of picker
		//menuRect.size.height = orgHeight+214;
		//menuRect.size.width = 320;
		//menu.frame = menuRect;

		//menu.view.subViews[0].frame.size



		//CGRect pickerRect = datePicker.frame;
		//pickerRect.origin.y = orgHeight;
		//datePicker.frame = pickerRect;
		//[menu addSubview:datePicker];

	}
	else
	{
		UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleDefault handler:nil];
		[alert addAction:alertAction];
		[alert addAction:alertAction];
		[alert addAction:alertAction];

		UIAlertAction* defaultAction =
				[UIAlertAction actionWithTitle:@"OK"
										 style:UIAlertActionStyleDefault
									   handler:^(UIAlertAction * action) {

					NSDate *date = datePicker.date;
					//[date
					NSLog(@"date selected: %@", date);
					QDateTime dateTime = QDateTime::fromTime_t( date.timeIntervalSince1970 );
					qDebug() << "QDateTime=" << dateTime;

					//QDateTime dateTime = QDateTime::fromNSDate(date);
					thisPtr->setDateTime(dateTime);
					emit thisPtr->picked(dateTime);
				}];
		[alert addAction:defaultAction];

		UIView *whiteBg = [[UIView alloc] initWithFrame:CGRectMake(0, 4, 320-2*8, 160)];
		whiteBg.backgroundColor = [UIColor colorWithRed:247.0/255 green:247.0/255 blue:247.0/255 alpha:1.0];
		[alert.view addSubview:whiteBg];
		[alert.view addSubview:datePicker];
		//alert.view.frame = CGRectMake(0, 0, 500, 800);

		[rvc presentViewController:alert animated:YES completion:nil];
	}
#endif





/*
	qDebug() << __FUNCTION__;
	CGRect datePickerRect = CGRectMake(0, 200, 320, 200);
	UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:datePickerRect];

	qDebug() << __FUNCTION__ << ":created datePicker...";

	UIViewController *rvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
	UIView *qtView = rvc.view;
	[qtView addSubview:datePicker];

	qDebug() << __FUNCTION__ << ":added subview...";

	//[rvc dismissViewControllerAnimated:YES completion:nil];
*/
}

}
}
