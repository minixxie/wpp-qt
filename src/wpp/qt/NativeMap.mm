#include <UIKit/UIKit.h>
#include <QtGui/qpa/qplatformnativeinterface.h>
#include <QtGui>
#include <QtQuick>
#include "NativeMap.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>


@interface MapViewController : UIViewController<MKMapViewDelegate, /*CLLocationManagerDelegate,*/ MKReverseGeocoderDelegate, UIGestureRecognizerDelegate>
{
	MKMapView *mapView;
	CLLocationManager *locationManager;
	@public wpp::qt::NativeMap *m_iosMap;
}
@end


static bool isPositioning = true;
static bool isPin = false;
static MKPointAnnotation *lastAnnotation = [[MKPointAnnotation alloc]init];
static NSString *location = @"";
static double longitude = 0.00;
static double latitude = 0.00;
static int zoom = 2000;
static NSMutableData *lookServerResponseData = nil;
static QMap<QString,QString> i18n;

@implementation MapViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	CGRect screenRect = [[UIScreen mainScreen] bounds];
	CGFloat screenWidth = screenRect.size.width;
	CGFloat screenHeight = screenRect.size.height;

	isPositioning = true;
	isPin = false;
	location = @"";
	longitude = 0.00;
	latitude = 0.00;

	i18n = m_iosMap->i18n();

//	int lat = [[NSNumber numberWithDouble:m_iosMap->getLatitude()] intValue];
//	int lng = [[NSNumber numberWithDouble:m_iosMap->getLongitude()] intValue];

	if ( m_iosMap->getLatitude() > 0.0 && m_iosMap->getLongitude() > 0.0 )
	{
		NSLog(@"-=--=-=-=-=-null   -=-==-   %f",  m_iosMap->getLatitude());
		NSLog(@"-=--=-=-=-=-null   -=-==-   %f",  m_iosMap->getLongitude());

		isPositioning = false;
		isPin = true;

		latitude = m_iosMap->getLatitude();
		longitude = m_iosMap->getLongitude();
		location = m_iosMap->getLocation().toNSString();

	}

	UINavigationController *navController = [[UINavigationController alloc]init];

	navController.navigationBar.barTintColor = [UIColor colorWithRed: 48/255.0 green: 138/255.0 blue: 39/255.0 alpha: 1.0];
	navController.navigationBar.tintColor = [UIColor whiteColor];

//	navController.navigationItem.title = @"Map";
	UITabBarController *uTabBar = [[UITabBarController alloc] init];
	uTabBar.view.backgroundColor = [UIColor colorWithRed: 48/255.0 green: 138/255.0 blue: 39/255.0 alpha: 1.0];

	UILabel *mapLabel = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth-100)/2, 18, 100, 44)];
	mapLabel.text = i18n["map"].toNSString();
	mapLabel.textColor = [UIColor whiteColor];
	mapLabel.textAlignment = NSTextAlignmentCenter;
	mapLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20];

	[uTabBar.view addSubview:mapLabel];

	UILabel *finishLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-100-10, 18, 100, 44)];
	finishLabel.text = i18n["finish"].toNSString();
	finishLabel.textColor = [UIColor whiteColor];
	finishLabel.textAlignment = NSTextAlignmentRight;
	finishLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18];
	finishLabel.userInteractionEnabled = YES;
	UITapGestureRecognizer * finishTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFinish:)];

	[finishLabel addGestureRecognizer:finishTap];
	//[finishTap release];

	[uTabBar.view addSubview:finishLabel];

	UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 18, 100, 44)];
	backLabel.text = i18n["back"].toNSString();
	backLabel.textColor = [UIColor whiteColor];
	backLabel.textAlignment = NSTextAlignmentLeft;
	backLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18];
	backLabel.userInteractionEnabled = YES;
	UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBack:)];

	[backLabel addGestureRecognizer:backTap];
	//[backTap release];

	[uTabBar.view addSubview:backLabel];

	[navController.view addSubview:uTabBar.view];
	[self.view addSubview:navController.view];

	//[mapLabel release];
	//[finishLabel release];
	//[backLabel release];


	locationManager = [[CLLocationManager alloc] init];
//	locationManager.delegate = self;
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
	{
		//[locationManager requestWhenInUseAuthorization];
		[locationManager requestAlwaysAuthorization];
	}
	[locationManager startUpdatingLocation];


	mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, (18+44), screenWidth, screenHeight - (18+44))];
	mapView.showsUserLocation = YES;
	mapView.mapType = MKMapTypeStandard;
	mapView.delegate = self;

	[self.view addSubview:mapView];
	[super viewDidLoad];

	if ( latitude > 0.0 && longitude > 0.0 )
	{

		CLLocationCoordinate2D coordinate;
		coordinate.latitude = latitude;
		coordinate.longitude = longitude;


		lastAnnotation.coordinate = coordinate;
		if ( nil == location || 0 == location.length )
		{
			lastAnnotation.title = i18n["unknownRegion"].toNSString();
		}
		else
		{
			lastAnnotation.title = location;
		}
		[mapView addAnnotation:lastAnnotation];
		[mapView selectAnnotation:lastAnnotation animated: true];

	}


	UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedAction:)];
	[longPressGestureRecognizer setDelegate:self];
	[self.view addGestureRecognizer:longPressGestureRecognizer];


}
- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}
// When a map annotation point is added, zoom to it (2000 range)
- (void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation
{

	if ( isPositioning )
	{
		MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, zoom, zoom);
		[mv setRegion:region animated:YES];
//		[mv selectAnnotation:mp animated:YES];

		isPositioning = false;
	}
	else if (isPin)
	{

		CLLocationCoordinate2D coordinate;
		coordinate.latitude = latitude;
		coordinate.longitude = longitude;

		MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, zoom, zoom);
		[mv setRegion:region animated:YES];

		isPin = false;
	}

}

//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:
//	  (CLLocation *)oldLocation {

//		[locationManager stopUpdatingLocation];

//		NSString *latitude = [NSString stringWithFormat:@"%.10f",newLocation.coordinate.latitude];
//		NSString *longitude = [NSString stringWithFormat:@"%.10f",newLocation.coordinate.longitude];
//NSLog(@"222222222");
//		NSLog(@"latitude:  %@   longitude:  %@", latitude, longitude);

//		MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
//		geocoder.delegate = self;
//		[geocoder start];


//}

//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//{
//	NSLog(@"error:  %@",error);
//}


- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {


	NSArray *address = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
	NSLog(@"placemark: ^^^^^^^^ %@",placemark);

	if ( address[0] != nil )
	{
		NSLog(@"address: ^^^^^^^^ %@",address[0]);

		location = address[0];
		lastAnnotation.title = address[0];
		[mapView selectAnnotation:lastAnnotation animated: true];

	}

//	NSString *streetAddress = placemark.thoroughfare;
//	NSString *city = placemark.locality;
//	NSString *state = placemark.administrativeArea;
//	NSString *zip = placemark.postalCode;

	// Do something with information
	geocoder.delegate = nil;
	//[geocoder autorelease];


}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	NSLog(@"Error resolving coordinates: %@", [error localizedDescription]);

	location = @"";
	lastAnnotation.title = i18n["unknownRegion"].toNSString();
//	[mapView selectAnnotation:lastAnnotation animated: true];

	geocoder.delegate = nil;
	//[geocoder autorelease];

	NSString *language = @"zh-Hans";
	NSArray *locale = [NSLocale preferredLanguages];
	if (nil != locale)
	{
		language = locale[0];
	}

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
										initWithURL:[NSURL URLWithString:
													 [NSString
														stringWithFormat:@"https://maps.google.cn/maps/api/geocode/json?latlng=%f,%f&sensor=true&language=%@",latitude,longitude,language]]];
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-type"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[connection start];

}
//NSURLConnection delegate method
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// A response has been received, this is where we initialize the instance var you created
	// so that we can append data to it in the didReceiveData method
	// Furthermore, this method is called each time there is a redirect so reinitializing it
	// also serves to clear it
	lookServerResponseData = [[NSMutableData alloc] init];
}
//NSURLConnection delegate method
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Failed with error: %@",[error localizedDescription]);
}
//NSURLConnection delegate method
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	// Append the new data to the instance variable you declared
	[lookServerResponseData appendData:data];
}
//NSURLConnection delegate method
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{

	// The request is complete and data has been received
	// You can parse the stuff in your instance variable now
	NSError *errorJson=nil;
	NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:lookServerResponseData options:kNilOptions error:&errorJson];

	NSString *status = [responseDict objectForKey:@"status"];
	NSArray *results = [responseDict objectForKey:@"results"];

	if ( [status isEqualToString:@"OK"] )
	{

		for ( id res in results )
		{

			NSLog(@"formatted_address--------: %@", [res objectForKey:@"formatted_address"]);
			location = [res objectForKey:@"formatted_address"];
			lastAnnotation.title = [res objectForKey:@"formatted_address"];

			break;
		}

	}

	//[lookServerResponseData release];
	//lookServerResponseData = nil;

	[mapView selectAnnotation:lastAnnotation animated: true];

}

- (void)longPressedAction:(UIGestureRecognizer *)sender {

	if(sender.state != UIGestureRecognizerStateBegan)
	{
		return;
	}


	[mapView removeAnnotations:mapView.annotations];

	CGPoint location = [sender locationInView:mapView];

	CLLocationCoordinate2D mapPoint = [mapView convertPoint:location toCoordinateFromView:mapView ];


	lastAnnotation.coordinate = mapPoint;

	lastAnnotation.title = @"";
	lastAnnotation.subtitle = @"";

	[mapView addAnnotation:lastAnnotation];

	longitude = mapPoint.longitude;
	latitude = mapPoint.latitude;


	MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:mapPoint];
	geocoder.delegate = self;
	[geocoder start];



}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	// If it's the user location, just return nil.
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;

	// Handle any custom annotations.
	if ([annotation isKindOfClass:[MKPointAnnotation class]])
	{
		// Try to dequeue an existing pin view first.
		MKPinAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];

		if (!pinView)
		{
			// If an existing pin view was not available, create one.

			pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
			pinView.animatesDrop = YES;
			pinView.canShowCallout = YES;
//          pinView.image = [UIImage imageNamed:@"pizza_slice_32.png"];
//			pinView.calloutOffset = CGPointMake(0, 32);
		} else {
			pinView.annotation = annotation;
		}
		return pinView;
	}
	return nil;
}

- (void)onBack:(UIGestureRecognizer *)recognizer
{
	NSLog(@"------------------back:    ");

	UIViewController *rvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
	[rvc dismissViewControllerAnimated:YES completion:nil];
	//[mapView release];

}

- (void)onFinish:(UIGestureRecognizer *)recognizer
{

	NSLog(@"------------------location: %@   longitude: %f  latitude: %f  zoom:  %d",location,longitude,latitude,zoom);

//	int lng = [[NSNumber numberWithDouble:longitude] intValue];
//	int lat = [[NSNumber numberWithDouble:latitude] intValue];

	if ( latitude > 0.0 && longitude > 0.0 )
	{

		m_iosMap->setLocation(QString::fromNSString(location));
		m_iosMap->setLatitude(latitude);
		m_iosMap->setLongitude(longitude);
		m_iosMap->setZoom(zoom);

		emit m_iosMap->locationSelected(longitude, latitude, QString::fromNSString(location));

		UIViewController *rvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
		[rvc dismissViewControllerAnimated:YES completion:nil];
		//[mapView release];

	}
	else
	{


		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:i18n["pleaseSelectVenue"].toNSString() message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];

		[alert addButtonWithTitle:@"OK"];
		[alert show];

	}



}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end



//@interface MapDelegate : NSObject <MKMapViewDelegate, /*CLLocationManagerDelegate,*/ MKReverseGeocoderDelegate, UIGestureRecognizerDelegate> {
//	wpp::qt::IOSMap *m_iosMap;
//}
//@end

//@implementation MapDelegate

//- (id) initWithIOSMap:(wpp::qt::IOSMap *)iosMap
//{
//    self = [super init];
//    if (self) {
//		m_iosMap = iosMap;
//    }
//    return self;
//}


//@end

namespace wpp {
namespace qt {

void NativeMap::open()
{
	// Get the UIView that backs our QQuickWindow:
	UIView *view = (__bridge UIView *)(
				QGuiApplication::platformNativeInterface()
				->nativeResourceForWindow("uiview", window()));
	UIViewController *qtController = [[view window] rootViewController];

	// Create a new image picker controller to show on top of Qt's view controller:
	MapViewController *mapViewController = [[MapViewController alloc] init];

	mapViewController->m_iosMap = this;
	// Tell the imagecontroller to animate on top:
	[qtController presentViewController:mapViewController animated:YES completion:nil];

}



}
}
