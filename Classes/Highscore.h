//
//  Highscore.h
//  Freefall
//
//  Created by Josh on 2009/05/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Highscore : UITableViewController {

	NSString *score;
	NSString *name;
	NSString *date;
	NSString *comment;
}

-(id) initWithScore:(NSString *) score by:(NSString *)name on:(NSString *)date withComment:(NSString *)c;

@end
