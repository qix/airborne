//
//  MoreController.m
//  Spit
//
//  Created by Josh on 2009/04/12.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MoreController.h"


@implementation MoreController

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/



-(BOOL) webView:(UIWebView *)v shouldStartLoadWithRequest:(NSURLRequest *)r navigationType:(UIWebViewNavigationType)nt {
	printf("start load with request\n");
	NSString *urlString = r.URL.absoluteString;
	
	printf("url: %s\n",[urlString UTF8String]);
	if ([urlString UTF8String][10] == '/') return YES;
	if (strcmp([urlString UTF8String],"http://app/?more") == 0) return YES;
	
	
	[[UIApplication sharedApplication] openURL:r.URL];
	return YES;
	//	return NO;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	self.view = view;
	[view release];
	
	UIWebView *webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	webView.delegate = self;
	[view addSubview:webView];
	
	char buffer[1024*200+1];
	FILE *r = fopen([[[NSBundle mainBundle] pathForResource:@"more" ofType:@"htm"] UTF8String],"r");
	if (r) {
		fread(buffer,1,1024*200,r);
		fclose(r);
	}
	NSString *s = [[NSString alloc] initWithCString:buffer];
	[webView loadHTMLString:s baseURL: [NSURL URLWithString:@"http://app/?more"]];
	[s release];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
 [super viewDidLoad];
 [self setTitle:@"Airborne - More"];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
