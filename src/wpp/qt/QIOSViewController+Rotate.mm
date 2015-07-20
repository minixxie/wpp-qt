#import "QIOSViewController+Rotate.h"
#include <wpp/qt/Wpp.h>

@implementation QIOSViewController (Rotate)

- (NSUInteger)supportedInterfaceOrientations
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	if ( wpp::qt::Wpp::getInstance().__IMPLEMENTATION_DETAIL_ENABLE_AUTO_ROTATE )
	{
		NSLog(@"supportedInterfaceOrientations: return UIInterfaceOrientationMaskAllButUpsideDown");
		return UIInterfaceOrientationMaskAllButUpsideDown;
	}
	else
	{
		NSLog(@"supportedInterfaceOrientations: return UIInterfaceOrientationPortrait");
		return UIInterfaceOrientationPortrait;
	}
}

-(BOOL)shouldAutorotate
{
	if ( wpp::qt::Wpp::getInstance().__IMPLEMENTATION_DETAIL_ENABLE_AUTO_ROTATE )
	{
		NSLog(@"shouldAutorotate: return YES");
		return YES;
	}
	else
	{
		NSLog(@"shouldAutorotate: return NO");
		return NO;
	}
}

@end
