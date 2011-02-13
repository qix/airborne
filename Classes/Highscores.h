//
//  Highscores.h
//  Freefall
//
//  Created by Josh on 2009/05/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Highscores : UITableViewController {

	BOOL error;
	BOOL loaded;
	int count;
	NSString *rows[100];
	NSString *sname[100];
	NSString *sscore[100];
	NSString *sdate[100];
	NSString *scomment[100];
}

-(void) scoresLoaded:(char *)buffer;
-(void) refreshScores:(NSString *)section;
-(void) errorLoadingScores;
@end
