#include <UIKit/UIKit.h>
#include <QtGui/qpa/qplatformnativeinterface.h>
#include <QtGui>
#include <QtQuick>
#include <QStringList>
#include "ELCImagePicker/ELCImagePickerHeader.h"
#include "ImagePicker.h"
#include "IOS.h"

#include <uuid/uuid.h>
#include <QByteArray>
#include <QtConcurrent>


@interface PhotoLibraryDelegate : NSObject <ELCImagePickerControllerDelegate, UINavigationControllerDelegate> {
	wpp::qt::ImagePicker *m_iosImagePicker;
}
@end

@implementation PhotoLibraryDelegate

- (id) initWithIOSImagePicker:(wpp::qt::ImagePicker *)iosImagePicker
{
	//NSLog(@"initWithIOSImagePicker");
    self = [super init];
    if (self) {
		m_iosImagePicker = iosImagePicker;
    }
    return self;
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image
{

	int kMaxResolution = 5120;


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
	qDebug() << "UIImageOrientationUp....";
	break;
	case UIImageOrientationUpMirrored: //EXIF = 2
	transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
	transform = CGAffineTransformScale(transform, -1.0, 1.0);
	qDebug() << "UIImageOrientationUpMirrored....";
	break;
	case UIImageOrientationDown: //EXIF = 3
	transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
	transform = CGAffineTransformRotate(transform, M_PI);
	qDebug() << "UIImageOrientationDown....";
	break;
	case UIImageOrientationDownMirrored: //EXIF = 4
	transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
	transform = CGAffineTransformScale(transform, 1.0, -1.0);
	qDebug() << "UIImageOrientationDownMirrored....";
	break;
	case UIImageOrientationLeftMirrored: //EXIF = 5
	boundHeight = bounds.size.height;
	bounds.size.height = bounds.size.width;
	bounds.size.width = boundHeight;
	transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
	transform = CGAffineTransformScale(transform, -1.0, 1.0);
	transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
	qDebug() << "UIImageOrientationLeftMirrored....";
	break;
	case UIImageOrientationLeft: //EXIF = 6
	boundHeight = bounds.size.height;
	bounds.size.height = bounds.size.width;
	bounds.size.width = boundHeight;
	transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
	transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
	qDebug() << "UIImageOrientationLeft....";
	break;
	case UIImageOrientationRightMirrored: //EXIF = 7
	boundHeight = bounds.size.height;
	bounds.size.height = bounds.size.width;
	bounds.size.width = boundHeight;
	transform = CGAffineTransformMakeScale(-1.0, 1.0);
	transform = CGAffineTransformRotate(transform, M_PI / 2.0);
	qDebug() << "UIImageOrientationRightMirrored....";
	break;
	case UIImageOrientationRight: //EXIF = 8
	boundHeight = bounds.size.height;
	bounds.size.height = bounds.size.width;
	bounds.size.width = boundHeight;
	transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
	transform = CGAffineTransformRotate(transform, M_PI / 2.0);
	qDebug() << "UIImageOrientationRight....";
	break;
	default:
		qDebug() << "default:exception....";
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

/*
- (void)imagePickerController:(UIImagePickerController *)picker
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
	NSLog(@"didFinishPickingImage");
	//imageView.image = image;

	// Create the path where we want to save the image:
//	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/tmp"];
	path = [path stringByAppendingString:@"/capture.png"];

	NSURL *url = [NSURL URLWithString:path];
	//exclude backup to iCloud
	[url setResourceValue:[NSNumber numberWithBool:YES] forKey:@"NSURLIsExcludedFromBackupKey" error:nil];

	UIImage *imgRotated = [self scaleAndRotateImage:image];
	[UIImagePNGRepresentation(imgRotated) writeToFile:path options:NSAtomicWrite error:nil];

	// Update imagePath property to trigger QML code:
	//m_iosImagePicker->m_imagePath = QStringLiteral("file:") + QString::fromNSString(path);
	m_iosImagePicker->m_imagePath = QString::fromNSString(path);
	emit m_iosImagePicker->imagePathChanged();

	// Bring back Qt's view controller:
	UIViewController *rvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
	[rvc dismissViewControllerAnimated:YES completion:nil];

	//[[picker parentViewController] dismissModalViewControllerAnimated:YES];
}
*/

/*
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    Q_UNUSED(picker);

    // Create the path where we want to save the image:
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingString:@"/capture.png"];

    // Save image:
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [UIImagePNGRepresentation(image) writeToFile:path options:NSAtomicWrite error:nil];

    // Update imagePath property to trigger QML code:
	m_iosImagePicker->m_imagePath = QStringLiteral("file:") + QString::fromNSString(path);
	emit m_iosImagePicker->imagePathChanged();

    // Bring back Qt's view controller:
    UIViewController *rvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rvc dismissViewControllerAnimated:YES completion:nil];
}
*/

- (ELCImagePickerController *)createImagePickerController
{
	//NSLog(@"createImagePickerController()...");

	// Create a new image picker controller to show on top of Qt's view controller:
	ELCImagePickerController *imageController = [[ELCImagePickerController alloc] initImagePicker];
	qDebug() << __FUNCTION__ << ":...2.1";
	imageController.maximumImagesCount = m_iosImagePicker->maxPick(); //Set the maximum number of images to select, defaults to 4
	qDebug() << __FUNCTION__ << ":...2.2";
	imageController.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
	qDebug() << __FUNCTION__ << ":...2.3";
	imageController.returnsImage = NO; //Return UIimage if YES. If NO, only return asset location information
	qDebug() << __FUNCTION__ << ":...2.4";
	imageController.onOrder = YES; //For multiple image selection, display and return selected order of images
	qDebug() << __FUNCTION__ << ":...2.5";
	imageController.imagePickerDelegate = self;
	//qDebug() << __FUNCTION__ << ":m_delegate=" << (void*)m_delegate;
	//NSLog(@"delegate=%p", self);
	//[imageController setImagePickerDelegate: (__bridge id<ELCImagePickerControllerDelegate, UINavigationControllerDelegate> )m_delegate ];
	qDebug() << __FUNCTION__ << ":...3";
	return imageController;
}

extern void asyncProcessImages(id iosImagePicker, NSArray *info, QThread *uiThread)
{
	qDebug() << __FUNCTION__;

	[iosImagePicker processImages:info];


/*	wpp::qt::AddressBookReader& addressBookReader = wpp::qt::AddressBookReader::getInstance();
	QList<QObject*> contacts = addressBookReader.fetchAll();
	qDebug() << __FUNCTION__ << ":return contacts-size:" << contacts.size();
	for ( QObject *obj : contacts )
	{
		wpp::qt::AddressBookContact *contact = dynamic_cast<wpp::qt::AddressBookContact *>(obj);
		contact->moveToThread(uiThread);

		for ( QObject *phone : contact->getPhones() )
			phone->moveToThread(uiThread);
		for ( QObject *email : contact->getEmails() )
			email->moveToThread(uiThread);
	}
	return contacts;*/
}

- (void)processImages:(NSArray *)info
{
	id thisClass = self;

	__block QStringList paths;//closure
	ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *asset)//lambda function
	{
			//NSLog(@"asset=%@", asset);
			ALAssetRepresentation *repr = [asset defaultRepresentation];

			CGImageRef cgImg = [repr fullResolutionImage];
			NSString *fname = [repr filename];
			//NSString* fileName = asset.defaultRepresentation.filename;
			NSURL* fileUrl = [[[[NSFileManager defaultManager]
				URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject]URLByAppendingPathComponent:fname];
			//NSLog(@"UIImagePickerControllerReferenceURL(fileUrl) = %@", fileUrl);
			NSString *urlStr = [fileUrl absoluteString];
			//NSLog(@"UIImagePickerControllerReferenceURL(fileUrlString) = %@", urlStr);
			QString path = QString::fromNSString(urlStr);

			QString ext(path);
			ext = ext.remove(QRegExp(".*\\.")).toLower();

			//NSLog(@"orientation: asset valueForProperty:%@", [asset valueForProperty:@"ALAssetPropertyOrientation"]);
			//JPEG exif
			//NSLog(@"orientation: [[repr metadata] objectForKey:@\"Orientation\"]:%@", [[repr metadata] objectForKey:@"Orientation"]);
			//NSLog(@"orientation: [repr orientation]:%d", [repr orientation]);
			//NSLog(@"orientation: [img imageOrientation]", [img imageOrientation]);


			// Retrieve the image orientation from the EXIF data
			UIImageOrientation orientation = UIImageOrientationUp;
			/*orientation = [[repr orientation] toRaw];
			switch (  [repr orientation] )
			{
			case ALAssetOrientationUp:		orientation = UIImageOrientationUp;		break;
			case ALAssetOrientationDown:	orientation = UIImageOrientationDown;	break;
			case ALAssetOrientationLeft:	orientation = UIImageOrientationRight;	break;
			case ALAssetOrientationRight:	orientation = UIImageOrientationLeft;	break;
			case ALAssetOrientationUpMirrored:	orientation = UIImageOrientationUpMirrored; break;
			case ALAssetOrientationDownMirrored: orientation = UIImageOrientationDownMirrored; break;
			case ALAssetOrientationLeftMirrored: orientation = UIImageOrientationLeftMirrored; break;
			case ALAssetOrientationRightMirrored: orientation = UIImageOrientationRightMirrored; break;
			default:
				orientation = UIImageOrientationUp;
			}*/
			NSNumber *orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
				if (orientationValue != nil) {
					orientation = (UIImageOrientation)[orientationValue intValue];
				}

			//NSLog(@"orientation:===%d", orientation);
			UIImage *img = [UIImage imageWithCGImage:cgImg scale:1.0f orientation:orientation];
			//UIImage *img = [UIImage imageWithCGImage:cgImg];
			img = [thisClass scaleAndRotateImage:img];

			NSData *data = 0;
			if ( ext == "jpg" || ext == "jpeg" )
			{
				data = UIImageJPEGRepresentation(img, 1.0);//preserve original quality
			}
			/*else if ( ext == "gif" )
			{
				NSData *data = UIImageGIFRepresentation(img);
			}*/
			else //if ( ext == "png" )
			{
				data = UIImagePNGRepresentation(img);
			}


			//[data writeToFile:[@"BaseDirectory/" stringByAppendingPathComponent:fname]
				//atomically:YES];


		QFile origFile(path);
		qDebug() << "original file size=" << origFile.size();


		/*QDir parentDir( QStandardPaths::writableLocation(QStandardPaths::TempLocation) );
		QDir parentParentDir( parentDir.filePath("..") );
		if ( !parentDir.exists() )
		{
			parentParentDir.mkpath( parentDir.dirName() );
			qDebug() << "making folder:" << parentDir.dirName() << " under:" << parentParentDir.absolutePath();
		}
		qDebug() << "folder readable:" << parentDir.isReadable();
		QFile parentDirFile( parentDir.absolutePath() );
		qDebug() << "cache folder permissions:" << parentDirFile.permissions();
		if ( !parentDirFile.setPermissions(
				 parentDirFile.permissions()
				 | QFile::ReadUser | QFile::WriteUser | QFile::ExeUser
				 | QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner
				 | QFile::ReadGroup | QFile::WriteGroup | QFile::ExeGroup
				 | QFile::ReadOther | QFile::WriteOther | QFile::ExeOther
				 ) )
			qDebug()<<"setPermission failed.";
		qDebug() << "cache folder permissions:" << parentDirFile.permissions();*/

		QUuid fileUUID = QUuid::createUuid();
		qDebug() << "fileUUID:" << fileUUID;
		QString fileUUIDStr( fileUUID.toString() );
		fileUUIDStr.replace('{',"").replace('}',"");

		/*QString imagePath(path);
		QString ext(imagePath);
		ext.remove(QRegExp(".*\\."));*/

		NSString *nsNewPath = [NSHomeDirectory() stringByAppendingFormat:@"/tmp"];
		//newPath = [newPath stringByAppendingString:@"/capture.png"];
		QString newPath = QString::fromNSString(nsNewPath);
		newPath.append( QString().sprintf("/%s.%s", fileUUIDStr.toStdString().c_str(), ext.toStdString().c_str()) );

		nsNewPath = newPath.toNSString();
		NSURL *url = [NSURL URLWithString:nsNewPath];
		//exclude backup to iCloud
		[url setResourceValue:[NSNumber numberWithBool:YES] forKey:@"NSURLIsExcludedFromBackupKey" error:nil];

		//QString newPath = parentDir.absoluteFilePath(
			//QString().sprintf("%s.%s", fileUUIDStr.toStdString().c_str(), ext.toStdString().c_str())
			//QString().sprintf("%s.png", fileUUIDStr.toStdString().c_str())
		//);
		qDebug() << "newPath=" << newPath;

		//QFile imageFile(path);
		//bool isCopySuccess = imageFile.copy(newPath);
		//qDebug() << "isCopySuccess=" << isCopySuccess;
		if ( data != 0 )
		{
			QByteArray fileData = QByteArray::fromNSData(data);
			qDebug() << "fileData.length=" << fileData.length();
			QFile newImageFile(newPath);
			bool isRemoveSuccess = newImageFile.remove();
			qDebug() << "isRemoveSuccess:" << isRemoveSuccess;
			newImageFile.open(QIODevice::WriteOnly);
			qint64 written = newImageFile.write(fileData);
			qDebug() << "fileData written=" << written;
			newImageFile.close();
			if ( newImageFile.exists() )
			{
				qDebug() << "newPath exist!";
			}
			else
			{
				qDebug() << "newPath NOT exist!";
			}

			paths.append( newPath );
			if ( paths.length() == info.count )
			{
				qDebug() << "done, paths:" << paths;
				emit m_iosImagePicker->accepted(paths);
			}
		}
	};

	for (NSDictionary *dict in info)
	{
		if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto)
		{
			if ([dict objectForKey:UIImagePickerControllerOriginalImage])
			{
				UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];

				NSURL *url = [dict objectForKey:UIImagePickerControllerReferenceURL];
				//NSLog(@"==UIImagePickerControllerReferenceURL(url) = %@", url);

				//NSLog(@"orientation: [image imageOrientation]", [image imageOrientation]);
				//image = [thisClass scaleAndRotateImage:image];

				/*ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
				[assetslibrary assetForURL:url resultBlock:	^(ALAsset *asset)//lambda function
					{
						ALAssetRepresentation *repr = [asset defaultRepresentation];
						CGImageRef cgImg = [repr fullResolutionImage];
						NSString *fname = [repr filename];
						//NSString* fileName = asset.defaultRepresentation.filename;
						NSURL* fileUrl = [[[[NSFileManager defaultManager]
						URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject]URLByAppendingPathComponent:fname];
						NSLog(@"UIImagePickerControllerReferenceURL(fileUrl) = %@", fileUrl);
						NSString *urlStr = [fileUrl absoluteString];
						NSLog(@"UIImagePickerControllerReferenceURL(fileUrlString) = %@", urlStr);
						QString path = QString::fromNSString(urlStr);
						qDebug() << "path=" << path;
					}
					failureBlock:nil];*/
				/*[images addObject:image];

				UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
				[imageview setContentMode:UIViewContentModeScaleAspectFit];
				imageview.frame = workingFrame;

				[_scrollView addSubview:imageview];

				workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;*/
			}
			else
			{
				//NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
				NSURL *url = [dict objectForKey:UIImagePickerControllerReferenceURL];
				//NSLog(@"UIImagePickerControllerReferenceURL(url) = %@", url);

				ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
				[assetslibrary assetForURL:url resultBlock:resultblock failureBlock:nil];
			}
		}
		else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo)
		{
			if ([dict objectForKey:UIImagePickerControllerOriginalImage])
			{
				UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];

				/*[images addObject:image];

				UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
				[imageview setContentMode:UIViewContentModeScaleAspectFit];
				imageview.frame = workingFrame;

				[_scrollView addSubview:imageview];

				workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;*/
			}
			else
			{
				//NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
				NSURL *url = [dict objectForKey:UIImagePickerControllerReferenceURL];
				//NSLog(@"UIImagePickerControllerReferenceURL(url) = %@", url);

				ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
				[assetslibrary assetForURL:url resultBlock:resultblock failureBlock:nil];
			}
		}
		else
		{
			//NSLog(@"Uknown asset type");
		}
	}
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
	m_iosImagePicker->__hideUI();
	//emit m_iosImagePicker->startedImageProcessing();
	m_iosImagePicker->processImages((__bridge void*)info);
	//[self processImages:info];

}
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
}

@end

namespace wpp {
namespace qt {

ImagePicker::ImagePicker(QQuickItem *parent)
	: QQuickItem(parent),
	  m_maxPick(-1),
	  m_delegate((__bridge_retained void*)[[PhotoLibraryDelegate alloc] initWithIOSImagePicker:this]),
	  futureWatcher(0), future(0)
{
}

void ImagePicker::__hideUI()
{
	// Get the UIView that backs our QQuickWindow:
	/*UIView *view = (__bridge UIView *)(
				QGuiApplication::platformNativeInterface()
				->nativeResourceForWindow("uiview", window()));
	qDebug() << __FUNCTION__ << ":...1";
	UIViewController *qtController = [[view window] rootViewController];
	[qtController dismissViewControllerAnimated:YES completion:nil];*/

	// Bring back Qt's view controller:
	UIViewController *rvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
	[rvc dismissViewControllerAnimated:YES completion:nil];

}

void ImagePicker::open()
{
	qDebug() << __FUNCTION__ << ":...0";
    // Get the UIView that backs our QQuickWindow:
	UIView *view = (__bridge UIView *)(
                QGuiApplication::platformNativeInterface()
                ->nativeResourceForWindow("uiview", window()));
	qDebug() << __FUNCTION__ << ":...1";
	UIViewController *qtController = [[view window] rootViewController];
	qDebug() << __FUNCTION__ << ":...2";

	// Create a new image picker controller to show on top of Qt's view controller:
	ELCImagePickerController *imageController = [(__bridge id)m_delegate createImagePickerController];
	/*ELCImagePickerController *imageController = [[ELCImagePickerController alloc] initImagePicker];
	qDebug() << __FUNCTION__ << ":...2.1";
	imageController.maximumImagesCount = 4; //Set the maximum number of images to select, defaults to 4
	qDebug() << __FUNCTION__ << ":...2.2";
	imageController.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
	qDebug() << __FUNCTION__ << ":...2.3";
	imageController.returnsImage = NO; //Return UIimage if YES. If NO, only return asset location information
	qDebug() << __FUNCTION__ << ":...2.4";
	imageController.onOrder = YES; //For multiple image selection, display and return selected order of images
	qDebug() << __FUNCTION__ << ":...2.5";
	//imageController.imagePickerDelegate = self;
	qDebug() << __FUNCTION__ << ":m_delegate=" << (void*)m_delegate;
	NSLog(@"delegate=%p", (__bridge id)m_delegate);
	//[imageController setImagePickerDelegate: (__bridge id<ELCImagePickerControllerDelegate, UINavigationControllerDelegate> )m_delegate ];
	qDebug() << __FUNCTION__ << ":...3";*/

	/*UIImagePickerController *imageController = [[[UIImagePickerController alloc] init] autorelease];
	[imageController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	[imageController setDelegate:id(m_delegate)];*/

    // Tell the imagecontroller to animate on top:
    [qtController presentViewController:imageController animated:YES completion:nil];
	qDebug() << __FUNCTION__ << ":...4";
}

void ImagePicker::processImages(void *nsarray)
{
	this->startedImageProcessing();
	NSArray *info = (__bridge NSArray *)nsarray;

	/*futureWatcher = new QFutureWatcher<void>;
	connect(futureWatcher, SIGNAL(finished()), this, SLOT(onProcessImageFinished()));

	future = new QFuture<void>;
	*future = QtConcurrent::run(asyncProcessImages, (__bridge id)m_delegate, info, QThread::currentThread());
	futureWatcher->setFuture(*future);
	*/

	//no multi-thread
	asyncProcessImages((__bridge id)m_delegate, info, QThread::currentThread());

}

void ImagePicker::onProcessImageFinished()
{
	qDebug() << __FUNCTION__;

	delete future;
	future = 0;
	delete futureWatcher;
	futureWatcher = 0;

	//emit accepted(paths);
}

}
}
