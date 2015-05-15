#import <UIKit/UIKit.h>
     
	#include <QtGui/5.3.0/QtGui/qpa/qplatformnativeinterface.h>
    #include <QtGui>
    #include <QtQuick>
     
    #include "WebViewController.h"
     
    @interface WebViewController : UIViewController {
       }
    @end
     
    @implementation WebViewController
     
    - (void)viewDidLoad
    {
     
     [super viewDidLoad];
     //self.view.frame = CGRectMake(0,0,100,100);
     
     UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
     [self.view addSubview:webView];
     
     NSString *urlAddress = @"http://www.google.com";
     NSURL *url = [NSURL URLWithString:urlAddress];
     NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
     [webView loadRequest:requestObj];
     
    }
     
    @end
     
     
    IOSWebView::IOSWebView(QQuickItem *parent) :
     QQuickItem(parent)
    {
		qDebug() << "IOSWebView()...";
    }
     
    void IOSWebView::open()
    {
		NSLog(@"IOSWebView::open()...");
     UIView *view = static_cast<UIView *>(
        QGuiApplication::platformNativeInterface()
        ->nativeResourceForWindow("uiview",window()));
	 UIViewController *qtController = [[view window] rootViewController];
     
     WebViewController *wView = [[[WebViewController alloc] init] autorelease];
     
	 [qtController presentViewController:wView animated:YES completion:nil];

	 int x = 0;
	  int y = 80;
	  int width = 300;
	  int height = 200;

	  UIWebView* webView =[[UIWebView alloc] initWithFrame:CGRectMake(x,y,width,height)];
	  [view addSubview:webView];

	  NSString *urlAddress = @"http://www.google.com";
	  NSURL *url = [NSURL URLWithString:urlAddress];
	  NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	  [webView loadRequest:requestObj];
     
    }

