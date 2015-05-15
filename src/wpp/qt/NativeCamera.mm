#include <UIKit/UIKit.h>
#include <QtGui/qpa/qplatformnativeinterface.h>
#include <QtGui>
#include <QtQuick>
#include "NativeCamera.h"

@interface CameraDelegate : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	wpp::qt::NativeCamera *m_iosCamera;
}
@end

@implementation CameraDelegate

- (id) initWithIOSCamera:(wpp::qt::NativeCamera *)iosCamera
{
	//NSLog(@"initWithIOSCamera");
	self = [super init];
    if (self) {
        m_iosCamera = iosCamera;
    }
    return self;
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image

{

	int kMaxResolution = 480;


	CGImageRef imgRef = image.CGImage;

	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);

	CGAffineTransform transform = CGAffineTransformIdentity;

	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
	CGFloat ratio = width/height;
	if (ratio > 1) {
	bounds.size.width = kMaxResolution;
	bounds.size.height = bounds.size.width / ratio;
	}
	else {
	bounds.size.height = kMaxResolution;
	bounds.size.width = bounds.size.height * ratio;
	}
	}

	CGFloat scaleRatio = bounds.size.width / width;

	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;

	UIImageOrientation orient = image.imageOrientation;
	switch(orient)
	{
	case UIImageOrientationUp: //EXIF = 1
	transform = CGAffineTransformIdentity;
	break;
	case UIImageOrientationUpMirrored: //EXIF = 2
	transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
	transform = CGAffineTransformScale(transform, -1.0, 1.0);
	break;
	case UIImageOrientationDown: //EXIF = 3
	transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
	transform = CGAffineTransformRotate(transform, M_PI);
	break;
	case UIImageOrientationDownMirrored: //EXIF = 4
	transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
	transform = CGAffineTransformScale(transform, 1.0, -1.0);
	break;
	case UIImageOrientationLeftMirrored: //EXIF = 5
	boundHeight = bounds.size.height;
	bounds.size.height = bounds.size.width;
	bounds.size.width = boundHeight;
	transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
	transform = CGAffineTransformScale(transform, -1.0, 1.0);
	transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
	break;
	case UIImageOrientationLeft: //EXIF = 6
	boundHeight = bounds.size.height;
	bounds.size.height = bounds.size.width;
	bounds.size.width = boundHeight;
	transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
	transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
	break;
	case UIImageOrientationRightMirrored: //EXIF = 7
	boundHeight = bounds.size.height;
	bounds.size.height = bounds.size.width;
	bounds.size.width = boundHeight;
	transform = CGAffineTransformMakeScale(-1.0, 1.0);
	transform = CGAffineTransformRotate(transform, M_PI / 2.0);
	break;
	case UIImageOrientationRight: //EXIF = 8
	boundHeight = bounds.size.height;
	bounds.size.height = bounds.size.width;
	bounds.size.width = boundHeight;
	transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
	transform = CGAffineTransformRotate(transform, M_PI / 2.0);
	break;
	default:
	[NSException raise :NSInternalInconsistencyException format:@"Invalid image orientation"];
	}

	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();

	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
	CGContextScaleCTM(context, -scaleRatio, scaleRatio);
	CGContextTranslateCTM(context, -height, 0);
	}
	else {
	CGContextScaleCTM(context, scaleRatio, -scaleRatio);
	CGContextTranslateCTM(context, 0, -height);
	}

	CGContextConcatCTM(context, transform);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return imageCopy;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    Q_UNUSED(picker);

	// Create the path where we want to save the image:(application document directory)
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

	NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/tmp"];
	path = [path stringByAppendingString:@"/capture.png"];

	NSURL *url = [NSURL URLWithString:path];
	//exclude backup to iCloud
	[url setResourceValue:[NSNumber numberWithBool:YES] forKey:@"NSURLIsExcludedFromBackupKey" error:nil];

    // Save image:
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	UIImage *imgRotated = [self scaleAndRotateImage:image];
	[UIImagePNGRepresentation(imgRotated) writeToFile:path options:NSAtomicWrite error:nil];

    // Update imagePath property to trigger QML code:
	//m_iosCamera->m_imagePath = QStringLiteral("file:") + QString::fromNSString(path);
	m_iosCamera->m_imagePath = QString::fromNSString(path);
	emit m_iosCamera->imagePathChanged();

    // Bring back Qt's view controller:
    UIViewController *rvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rvc dismissViewControllerAnimated:YES completion:nil];
}

@end

namespace wpp {
namespace qt {

NativeCamera::NativeCamera(QQuickItem *parent) :
	QQuickItem(parent), m_delegate((__bridge_retained void*)[[CameraDelegate alloc] initWithIOSCamera:this])
{
}

void NativeCamera::open()
{
	qDebug() << __FUNCTION__ << ":1...";
    // Get the UIView that backs our QQuickWindow:
	UIView *view = (__bridge UIView *)(
                QGuiApplication::platformNativeInterface()
                ->nativeResourceForWindow("uiview", window()));
    UIViewController *qtController = [[view window] rootViewController];

	qDebug() << __FUNCTION__ << ":2...";
	// Create a new image picker controller to show on top of Qt's view controller:
	UIImagePickerController *imageController = [[UIImagePickerController alloc] init];
    [imageController setSourceType:UIImagePickerControllerSourceTypeCamera];
	[imageController setDelegate:(__bridge id)(m_delegate)];

	qDebug() << __FUNCTION__ << ":3...";
	// Tell the imagecontroller to animate on top:
    [qtController presentViewController:imageController animated:YES completion:nil];
}

}
}
