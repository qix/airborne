//
//  FreefallView.h
//  Freefall
//
//  Created by Josh on 2009/05/27.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FreefallView : UIView<UIAccelerometerDelegate> {

}

-(float) bestScore;
-(float) totalScore;
-(void) loadScores;
- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
- (void)loadView;
-(void) update;
@end

