//
//  MainMenu.m
//  Freefall
//
//  Created by Josh on 2009/05/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import "FreefallAppDelegate.h"
#import "Highscores.h"
#import "MoreController.h"

@implementation MainMenu


- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Airborne"];
}

- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0: return 3;
		case 1: return 2;
		case 2: return 1;
		default: return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
	switch ([indexPath section]) {
	case 0:
		switch ([indexPath row]) {
			case 0:
				[cell setText:@"Play Airborne"];
				break;
			case 1:
				[cell setText:@"Statistics"];
				break;
			case 2:
				[cell setText:@"Submit Highscore"];
				break;
		}
			break;
	case 1:
		if ([indexPath row] == 0) {
			[cell setText:@"View Recent Scores"];
		}else{
			[cell setText:@"View Highest Scores"];
		}
		break;
	case 2:
		[cell setText:@"More"];
		break;
	}
		
		
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	float b,s,hs;
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	if ([indexPath section] == 1) {
		// Top scores
		if ([indexPath row] == 0) {
			[delegate showHighscores:@"recent"];
		}else{
			[delegate showHighscores:@"top"];
		}
	}else if ([indexPath section] == 0) {
		// Top scores
		switch ([indexPath row]) {
			case 0: // play
				[delegate showFreefall];
				break;
			case 1: // stats
				b = [freefallView bestScore];
				s = 0.5*(9.8)*b*b;
				hs = s/2.0;
				[[[UIAlertView alloc] initWithTitle:@"Statistics" message:[[NSString alloc] initWithFormat:@"This device has been airborne for a total of %.2f seconds. Your best score is %.2f, which is a height of %.2fm if it was thrown and caught from the same height.",[freefallView totalScore],b,hs] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				break;
			case 2: // save
				[delegate showSaveHighscore];
				break;
		}
	}else{
		
		MoreController* tempView = [[MoreController alloc] init];
		[[self navigationController] pushViewController:tempView animated:YES];
		[tempView release];

	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
	if (section == 0) return @"Airborne";
	else if (section == 1) return @"Online Scores";
	else return @"More?";
}


- (void)dealloc {
    [super dealloc];
}


@end

