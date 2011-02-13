//
//  MainMenu.m
//  Freefall
//
//  Created by Josh on 2009/05/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Highscores.h"
#import "Highscore.h"
#import "FreefallAppDelegate.h"

@implementation Highscores


-(void) refreshScores:(NSString *)section{
	loaded = NO;
	count = 0;
	if (![delegate getHighscores:section]) {
		[self errorLoadingScores];
	}else{
		error = NO;
	}
}

-(void) errorLoadingScores {
	error = YES;
	loaded = YES;
	[self.tableView reloadData];
}

-(void) scoresLoaded:(char *)buffer {
	if (memcmp(buffer,"SCORES",6) != 0) {
		[self errorLoadingScores];
		return;
	}
	int p;
	int k;
	
	int pname; int pscore; int pcomment; int pdate;
	
	int L = strlen(buffer);
	
	for (p = 0; p < L; p++) { if (buffer[p] == '\n') { p++; break; } } // skip first new line
	
	for (k = 0; k < 100; k++) {
		pname = p;
		for (; p < L; p++) { if (buffer[p] == '\n') { buffer[p++] = 0; break; } }
		pscore = p;
		for (; p < L; p++) { if (buffer[p] == '\n') { buffer[p++] = 0; break; } }
		pcomment = p;
		for (; p < L; p++) { if (buffer[p] == '\n') { buffer[p++] = 0; break; } }
		pdate = p;
		for (; p < L; p++) { if (buffer[p] == '\n') { buffer[p++] = 0; break; } }
		
		if (buffer[pscore]) {
			sname[count] = [[NSString alloc] initWithFormat:@"%s",buffer+pname];
			sscore[count] = [[NSString alloc] initWithFormat:@"%s",buffer+pscore];
			scomment[count] = [[NSString alloc] initWithFormat:@"%s",buffer+pcomment];
			sdate[count] = [[NSString alloc] initWithFormat:@"%s",buffer+pdate];
			rows[count++] = [[NSString alloc] initWithFormat:@"%s by %s",buffer+pscore,buffer+pname]; 
		}else break;
	}
	if (count == 0) {
		[self errorLoadingScores];
		return;
	}
	loaded = YES;
	
	[self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	printf("loading scores\n");
	
	[self setTitle:@"International Highscores"];
}

- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (loaded && !error) {
		return count/10+(count%10>0?1:0);
	}else{
		return 1;
	}
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (error || !loaded) return 1;
	else if (count >= 10*(section+1)) return 10;
	else {
		return count - 10*(section);
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
	if (error) {
		[cell setText:@"Could not load scores"];	
	}else{
		if (loaded && [indexPath row] < count) {
			[cell setText:rows[10*[indexPath section]+[indexPath row]]];
			[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
		}else{
			[cell setText:@"Loading..."];
		}
	}
	
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	//[delegate showFreefall];
	if (loaded && !error) {
		int s = [indexPath section]*10+[indexPath row];
		Highscore *h = [[Highscore alloc] initWithScore:sscore[s] by:sname[s] on:sdate[s] withComment:scomment[s]];
		[self.navigationController pushViewController:h animated:YES];
		[h release];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
	if (section == 0) return @"Top 10";
	else{
		return [[NSString alloc] initWithFormat:@"%d - %d",(section*10+1),(section*10+10)];
	}
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)dealloc {
    [super dealloc];
}


@end

