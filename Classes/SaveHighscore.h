//
//  SaveHighscore.h
//  Freefall
//
//  Created by Josh on 2009/05/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SaveHighscore : UIViewController <UIScrollViewDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
	UITableView	*myTableView;
	UITextView *comments;
	UITextView *rules;
	UITextField *name;
	UIScrollView *scrollView;
	
	UITableViewCell *commentsCell;
	UITableViewCell *nameCell;
	
	UITableViewCell *submitCell;
	float score;
	BOOL saving;
}

@property (nonatomic, retain) UITableView *myTableView;

-(void) saveFailed;
-(void) highscoreSaved:(char *) buffer;
-(id) initWithScore:(float) score;// andFrame:(CGRect) frame;

@end
