#include "GeoPosition.h"
#import <CoreLocation/CoreLocation.h>

#include <QDebug>

//@interface locationManager : NSObject <CLLocationManagerDelegate> {
//	wpp::qt::GeoPosition *m_iosLocation;
//}
//@end

//@implementation locationManager

//- (id) initWithIOSLocation:(wpp::qt::GeoPosition *)geoPosition
//{
//	NSLog(@"initWithIOSLocation");
//	self = [super init];
//	if (self) {
//		m_iosLocation = geoPosition;
//	}
//	return self;
//}

//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

//	NSLog(@"kkkkkkkkkkkkk1111111");

//	//[locationManager stopUpdatingLocation];
//	NSLog(@"kkkkkkkkkkkkk222222222");
//	NSString *strLat = [NSString stringWithFormat:@"%.10f",newLocation.coordinate.latitude];
//	NSLog(@"kkkkkkkkkkkkk3333333333333");
//	NSString *strLng = [NSString stringWithFormat:@"%.10f",newLocation.coordinate.longitude];
//NSLog(@"kkkkkkkkkkkkk44444441111111");

//	NSLog(@"Lat: %@  Lng: %@", strLat, strLng);

//}

//@end


namespace wpp
{
namespace qt
{

//GeoPosition::GeoPosition(QObject *parent)
//	: QObject(parent), geoSource(0),
//	  receiver(0), method(0), m_delegate([[locationManager alloc] initWithIOSLocation:this])
//{
//	qDebug() << "GeoPosition()...";
//}
void GeoPosition::requestAuthorization()
{
	qDebug() << "requestAuthorization...";
	CLLocationManager *locationManager = [[CLLocationManager alloc] init];

	if ( [locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)] )
	{
		qDebug() << "inside if...";
		[locationManager requestWhenInUseAuthorization];
	}

//	locationManager.delegate = id(m_delegate);
	[locationManager startUpdatingLocation];
}

}
}
