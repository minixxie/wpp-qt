#import "ELCAlbumPickerController+RemoveMyPhotoStream.h"
//#include <wpp/qt/Wpp.h>

@interface ELCAlbumPickerController (RemoveMyPhotoStream)

@property (nonatomic, strong) ALAssetsLibrary *library;

@end

@implementation ELCAlbumPickerController (RemoveMyPhotoStream)

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

	[self.navigationItem setTitle:NSLocalizedString(@"Loading...", nil)];

	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.parent action:@selector(cancelImagePicker)];
	[self.navigationItem setRightBarButtonItem:cancelButton];

	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.assetGroups = tempArray;

	ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
	self.library = assetLibrary;

	// Load Albums into assetGroups
	dispatch_async(dispatch_get_main_queue(), ^
	{
		@autoreleasepool {

		// Group enumerator Block
			void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
			{
				if (group == nil) {
					return;
				}

				// added fix for camera albums order
				NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
				NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];

				if ([[sGroupPropertyName lowercaseString] isEqualToString:@"camera roll"] && nType == ALAssetsGroupSavedPhotos) {
					[self.assetGroups insertObject:group atIndex:0];
				}
				else {
					[self.assetGroups addObject:group];
				}

				// Reload albums
				[self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
			};

			// Group Enumerator Failure Block
			void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {

				if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
					NSString *errorMessage = NSLocalizedString(@"This app does not have access to your photos or videos. You can enable access in Privacy Settings.", nil);
					[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Access Denied", nil) message:errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil] show];

				} else {
					NSString *errorMessage = [NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]];
					[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil] show];
				}

				[self.navigationItem setTitle:nil];
				NSLog(@"A problem occured %@", [error description]);
			};

			// Enumerate Albums
			NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;

			[self.library enumerateGroupsWithTypes:groupTypes  //ALAssetsGroupAll
								   usingBlock:assetGroupEnumerator
								 failureBlock:assetGroupEnumberatorFailure];

		}
	});

}

@end
