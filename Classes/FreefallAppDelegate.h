//
//  FreefallAppDelegate.h
//  Freefall
//
//  Created by Josh on 2009/05/27.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FreefallView.h"


#include <AudioToolbox/AudioServices.h>

enum {
	SOUND_START, SOUND_LOOP, SOUND_END, COUNT_SOUNDS
};
extern SystemSoundID sounds[COUNT_SOUNDS];
extern float soundLastPlay[COUNT_SOUNDS];


@interface FreefallAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}

-(void) showMenu;
-(void) showFreefall;
-(void) showHighscores:(NSString *)section;
-(void) showSaveHighscore;
-(BOOL) saveHighscore:(float) score by:(NSString *)name withComment:(NSString *)comment;
-(BOOL) getHighscores:(NSString *)section;
-(void) playSound;
-(void) repeatSound;
-(void) stopSound;

@property (nonatomic, retain) IBOutlet UIWindow *window;


@end

extern FreefallAppDelegate *delegate;
extern FreefallView *freefallView;