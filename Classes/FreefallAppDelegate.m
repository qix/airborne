//
//  FreefallAppDelegate.m
//  Freefall
//
//  Created by Josh on 2009/05/27.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "FreefallAppDelegate.h"
#import "MainMenu.h"
#import "Highscores.h"
#import "SaveHighscore.h"
#import "oalPlayback.h"

#define kAccelerometerFrequency     100

oalPlayback *scream;


SystemSoundID sounds[COUNT_SOUNDS];
float soundLastPlay[COUNT_SOUNDS];

@implementation FreefallAppDelegate

@synthesize window;

enum { STATE_MENU, STATE_FREEFALL, STATE_HIGHSCORES, STATE_SAVE_HIGHSCORE };

int state = STATE_MENU;

FreefallAppDelegate *delegate;
FreefallView *freefallView;
UINavigationController *navigationController;
MainMenu *mainMenuController;
Highscores *highscoresController;
SaveHighscore *saveHighscoreController = nil;

NSMutableData *receivedData;

-(void)connection:(NSURLConnection *)c didReceiveResponse:(NSURLResponse *)response {
	[receivedData setLength:0];
}
-(void)connection:(NSURLConnection *)c didReceiveData:(NSData *)d {
	[receivedData appendData: d];
}
-(void)connection:(NSURLConnection *)c didFailWithError:(NSError *)error {
	
	if (state == STATE_HIGHSCORES) {
		[highscoresController errorLoadingScores];
	}else if (state == STATE_SAVE_HIGHSCORE) {
		[saveHighscoreController saveFailed];
	}
}
-(void)connectionDidFinishLoading:(NSURLConnection *)c {
	int L = [receivedData length];
	char *buffer = (char *)malloc(sizeof(char)*(L+1));
	[receivedData getBytes:buffer length:L];
	buffer[L] = 0;

	if (buffer[0] == '!') {
		[[[UIAlertView alloc] initWithTitle:@"Airborne" message:[[NSString alloc] initWithFormat:@"%s",buffer+1] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}

	printf("%s\n",buffer);
	if (state == STATE_HIGHSCORES) {
		[highscoresController scoresLoaded:buffer];
	}else if (state == STATE_SAVE_HIGHSCORE) {
		[saveHighscoreController highscoreSaved:buffer];
	}
	
	free(buffer);
	[c release];
	[receivedData release];
	receivedData = nil;
}

-(BOOL) httpRequest:(NSString *) url withPOST:(NSString *)post {
	NSMutableURLRequest *_req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
	NSData *data = [NSData dataWithBytes:[post UTF8String] length:[post length]];
	[_req setHTTPMethod:@"POST"];
	[_req setHTTPBody: data];
	
	NSURLConnection *_conn = [[NSURLConnection alloc] initWithRequest:_req delegate:self];
	if (_conn) {
		receivedData = [[NSMutableData data] retain];
		return YES;
	}else{
		return NO;
	}
}
-(BOOL) httpRequest:(NSString *) url {
	NSURLRequest *_req = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
	NSURLConnection *_conn = [[NSURLConnection alloc] initWithRequest:_req delegate:self];
	if (_conn) {
		receivedData = [[NSMutableData data] retain];
		return YES;
	}else{
		return NO;
	}
	
}
- (void) pingServer {
	
	NSString *post = [[NSString alloc] initWithFormat:@"total=%.2f&best=%.2f&device=%s&model=%s&lmodel=%s&system=%s&version=%s",
					  [freefallView totalScore],[freefallView bestScore],
					  [[UIDevice currentDevice].uniqueIdentifier UTF8String],
					  [[UIDevice currentDevice].model UTF8String],
					  [[UIDevice currentDevice].localizedModel UTF8String],
					  [[UIDevice currentDevice].systemName UTF8String],
					  [[UIDevice currentDevice].systemVersion UTF8String]
					  ];
	[self httpRequest:@"https://j.yud.co.za/freefall-iphone/api/ping.php" withPOST:post];
}
- (BOOL) saveHighscore:(float) score by:(NSString *)name withComment:(NSString *)comment {
	NSString *post = [[NSString alloc] initWithFormat:@"score=%.2f&name=%s&comment=%s&device=%s",score,[[name stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] UTF8String], [[comment stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] UTF8String],[[UIDevice currentDevice].uniqueIdentifier UTF8String]];
	return [self httpRequest:@"https://blue.ltserv.net/j.yud.co.za/freefall_save.php" withPOST:post];
}
- (BOOL) getHighscores:(NSString *)section {
	return [self httpRequest:[[NSString alloc] initWithFormat:@"http://j.yud.co.za/freefall-iphone/api/retr.php?section=%s",[section UTF8String]]];
}
	/*
	NSData *   postStringData = [@"roar=yes"
								 dataUsingEncoding: kCFStringEncodingASCII
								 allowLossyConversion: YES];
	
	CFURLRef scoreURL = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef) @"http://j.yud.co.za/freefall-iphone/highscores.php", NULL);
	CFHTTPMessageRef _request = CFHTTPMessageCreateRequest(kCFAllocatorDefault, CFSTR("GET"), scoreURL, kCFHTTPVersion1_1);
	CFHTTPMessageSetHeaderFieldValue(_request,CFSTR("Host"),CFSTR("j.yud.co.za"));
	//CFHTTPMessageSetBody(_request, (CFDataRef) postStringData);
	CFReadStreamRef _read = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, _request);
	CFReadStreamOpen(_read);
	CFIndex read;
	UInt8 buffer[1025];
	printf("reading\n");
	while (CFReadStreamGetStatus(_read) != kCFStreamStatusAtEnd) {
		printf("Status: %d\n",CFReadStreamGetStatus(_read));
		read = CFReadStreamRead(_read, buffer, 1024);
		printf("%s\n",read);
	}
	printf("Done\n");
	CFReadStreamClose(_read);
	CFRelease(_request);
	CFRelease(scoreURL);
	
}*/
- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	delegate = self;
	
    // Override point for customization after app launch    
	freefallView = [[FreefallView alloc] initWithFrame:CGRectMake(0,0,320,480)];
	[freefallView loadScores];
	[freefallView loadView];
	freefallView.multipleTouchEnabled = YES;
	
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:freefallView];

	highscoresController = [[Highscores alloc] init];
	[highscoresController loadView];
	
	
	CFURLRef url;
	CFBundleRef bundle = CFBundleGetMainBundle();
	url = CFBundleCopyResourceURL(bundle,CFSTR("scream_01"),CFSTR("wav"),NULL);
	AudioServicesCreateSystemSoundID(url,&sounds[SOUND_START]);
	url = CFBundleCopyResourceURL(bundle,CFSTR("scream_looped"),CFSTR("wav"),NULL);;
	AudioServicesCreateSystemSoundID(url,&sounds[SOUND_LOOP]);
	url = CFBundleCopyResourceURL(bundle,CFSTR("scream_03"),CFSTR("wav"),NULL);	
	AudioServicesCreateSystemSoundID(url,&sounds[SOUND_END]);
	
	scream = [[oalPlayback alloc] init];
	
	mainMenuController = [[MainMenu alloc] initWithStyle:UITableViewStyleGrouped];
	navigationController = [[UINavigationController alloc] initWithRootViewController:mainMenuController];
	
	[window addSubview:[navigationController view]];
	state = STATE_MENU;
    [window makeKeyAndVisible];	
	[self pingServer];
}
-(void) playSound {
	[scream startSound];
}
-(void) repeatSound {
	[scream repeatSound];
}
-(void) stopSound {
	[scream stopSound];
}

-(void) showFreefall {
	if (state == STATE_FREEFALL) return;
	state = STATE_FREEFALL;
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	freefallView.userInteractionEnabled = YES;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0f];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:window cache:NO];
	[[navigationController view] removeFromSuperview];
    [window addSubview:freefallView];
	[UIView commitAnimations];
	
}
-(void) showMenu {
	if (state == STATE_MENU) return;
	
	[UIApplication sharedApplication].idleTimerDisabled = NO;
	if (state == STATE_FREEFALL) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0f];
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:window cache:YES];
		[freefallView removeFromSuperview];
		[window addSubview:[navigationController view]];
		[UIView commitAnimations];		
	}else{
		[navigationController popToRootViewControllerAnimated:NO];
	}
	state = STATE_MENU;
}
-(void) showHighscores:(NSString *)section {
	[self showMenu];
	state = STATE_HIGHSCORES;
	[highscoresController refreshScores:section];
	[navigationController pushViewController:highscoresController animated:YES];
}
-(void) showSaveHighscore {
	[self showMenu];
	state = STATE_SAVE_HIGHSCORE;
	saveHighscoreController = [[SaveHighscore alloc] initWithScore:[freefallView bestScore]];// andFrame:navigationController.defaultViewFrame];
	
	[navigationController pushViewController:saveHighscoreController animated:YES];
}


- (void)dealloc {
    [freefallView release];
    [window release];
    [super dealloc];
}


@end
