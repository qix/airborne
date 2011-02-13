//
//  SaveHighscore.m
//  Freefall
//
//  Created by Josh on 2009/05/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SaveHighscore.h"
#import "CellTextField.h"
#import "CellTextView.h"
#import "FreefallAppDelegate.h"

UIAlertView *savingAlert;

@implementation SaveHighscore

#define kUITextViewCellRowHeight 150.0
#define kTextFieldWidth							100.0	// initial width, but the table cell will dictact the actual width
#define kTextFieldHeight		30.0
#define kUIRowHeight			50.0

@synthesize myTableView;

-(id) initWithScore:(float) nscore {// andFrame:(CGRect) frame {
	if (self = [super init]) {
		
	}
	rules = name = comments = nil;
	saving = NO;
	score = nscore;
	[self setTitle:@"Save Highscore"];
	/*
	printf("load view %f\n", [self view].frame.size.width);
	scrollView = [[UIScrollView alloc] initWithFrame:[self view].frame];
	self.view = scrollView;
	
	printf("load name\n");
	name = [[UITextField alloc] initWithFrame:CGRectMake(10,20,300,32)];
	name.borderStyle = UITextBorderStyleRoundedRect;
	name.placeholder = @"<enter your name>";
	name.autocorrectionType = UITextAutocorrectionTypeNo;
	name.returnKeyType = UIReturnKeyDone;
	name.clearButtonMode = UITextFieldViewModeWhileEditing;
	[scrollView addSubview:name];
	
	printf("load comments\n");
	comments = [[BorderedTextView alloc] initWithFrame:CGRectMake(10,80,300,200)];
	comments.autocorrectionType = UITextAutocorrectionTypeNo;
	comments.editable = YES;
	[scrollView addSubview:comments];
	*/
	printf("load nothing else\n");	
	return self;
}

- (void)dealloc
{
	[myTableView release];
	
	[super dealloc];
}

- (void)loadView
{
	// create and configure the table view
	myTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];	
	myTableView.delegate = self;
	myTableView.dataSource = self;
	myTableView.scrollEnabled = YES; // no scrolling in this case, we don't want to interfere with text view scrolling
	myTableView.autoresizesSubviews = YES;
	
	self.view = myTableView;
}

-(void) showAlert:(NSString *) message {
	if (savingAlert) {
		[savingAlert dismissWithClickedButtonIndex:0 animated:YES];
		[savingAlert release];
		savingAlert = nil;
	}
	savingAlert= [[UIAlertView alloc] initWithTitle:@"Save Highscore" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[savingAlert show];
}

-(void) highscoreSaved:(char *) buffer {
	if (buffer[0] == 'O' && buffer[1] == 'K') {
		for (int k = 3; buffer[k]; k++) { if (buffer[k] == '\n') { buffer[k] = 0; break; } }
		[self showAlert:[[NSString alloc] initWithFormat:@"Your score was saved!\nYou came %s!",buffer+3]];
	}else{
		[self saveFailed];
	}
}
-(void) saveFailed {
	saving = NO;
	[self showAlert:@"Could not save your score!"];
/*	[submitCell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	submitCell.accessoryView = nil;*/
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	if ([indexPath section] == 3) {
		if ([delegate saveHighscore:score by:name.text withComment:comments.text]) {
			savingAlert = [[UIAlertView alloc] initWithTitle:@"Save Highscore" message:@"Sending your high score..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
			[savingAlert show];
			saving = YES;
			/*	UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,32,32)];
			activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
			[activity startAnimating];
			[activity sizeToFit];
			activity.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
			submitCell.accessoryView = activity;
			[activity release];*/
			
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}else{
			[self saveFailed];
		}
	}
}


- (UITextField *)createTextField
{
	CGRect frame = CGRectMake(0.0, 0.0, kTextFieldWidth, kTextFieldHeight);
	UITextField *returnTextField = [[UITextField alloc] initWithFrame:frame];
	
	returnTextField.borderStyle = UITextBorderStyleNone;
    returnTextField.textColor = [UIColor blackColor];
	returnTextField.font = [UIFont systemFontOfSize:17.0];
    returnTextField.placeholder = @"";
    returnTextField.backgroundColor = [UIColor whiteColor];
	returnTextField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	
	returnTextField.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	returnTextField.returnKeyType = UIReturnKeyDone;
	
	returnTextField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	
	return returnTextField;
}

- (UITextView *)createTextView
{
	CGRect frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
	
	UITextView *textView = [[[UITextView alloc] initWithFrame:frame] autorelease];
    textView.textColor = [UIColor blackColor];
//    textView.font = [UIFont fontWithName:kFontName size:kTextViewFontSize];
    textView.delegate = self;
    textView.backgroundColor = [UIColor whiteColor];
	
	textView.text = @"";
	textView.returnKeyType = UIReturnKeyDone;
	textView.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	
	// note: for UITextView, if you don't like autocompletion while typing use:
	// myTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	
	return textView;
}


#pragma mark UITextView delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{

	// provide my own Save button to dismiss the keyboard
	UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self action:@selector(saveAction:)];
	self.navigationItem.rightBarButtonItem = saveItem;
	[saveItem release];
}

- (void)saveAction:(id)sender
{
	// finish typing text/dismiss the keyboard by removing it as the first responder
	//
	[nameCell stopEditing];
	[commentsCell stopEditing];
	if ([comments.text length] > 160) {
		comments.text = [comments.text substringToIndex:160];
	}
	UITableViewCell *cell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[((CellTextView *)cell).view resignFirstResponder];
	self.navigationItem.rightBarButtonItem = nil;	// this will remove the "save" button
}

-(void) textViewDidChange:(UITextView *)t {

	if ([comments.text hasSuffix:@"\n"]) {
		comments.text = [comments.text substringToIndex:[comments.text length]-1];
		[self saveAction:t];
	}
	if ([comments.text length] > 160) {
		comments.text = [comments.text substringToIndex:160];
	}
		
	return YES;
}

#pragma mark - UITableView delegates

// if you want the entire table to just be re-orderable then just return UITableViewCellEditingStyleNone
//
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0) return @"Name";
	else if (section == 1) return @"Comments";
	else if (section == 2) return @"Rules";
	else return @"Submit your score";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

// to determine specific row height for each cell, override this.  In this example, each row is determined
// buy the its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result;
	
	switch ([indexPath section])
	{
		case 0: return kUIRowHeight;
		case 1:
		{
			result = kUITextViewCellRowHeight;
			break;
		}
		case 2: return kUITextViewCellRowHeight;
		case 3: return kUIRowHeight;
	}
	
	return result;
}


// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITextView *textView;
	UITableViewCell *cell;
	// we are creating a new cell, setup its attributes
	switch ([indexPath section]) {
		case 0:
			nameCell = [myTableView dequeueReusableCellWithIdentifier:@"name"];
			if (nameCell == nil) {
				nameCell = [[[CellTextField alloc] initWithFrame:CGRectZero reuseIdentifier:kCellTextView_ID] autorelease];
			}
			if (!name) name = [self createTextField];
			((CellTextView *)nameCell).view = name;
			return nameCell;
		case 1:
			commentsCell = [myTableView dequeueReusableCellWithIdentifier:@"comments"];
			if (commentsCell == nil) {
				commentsCell = [[[CellTextView alloc] initWithFrame:CGRectZero reuseIdentifier:kCellTextView_ID] autorelease];
			}
			if (!comments) comments = [self createTextView];
			((CellTextView *)commentsCell).view = comments;
			return commentsCell;
		case 2:
			/********** RULES *******/
			cell = [myTableView dequeueReusableCellWithIdentifier:@"rules"];
			if (cell == nil) {
				cell = [[[CellTextView alloc] initWithFrame:CGRectZero reuseIdentifier:kCellTextView_ID] autorelease];
			}
			
			if (!rules) {
				CGRect frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
				
				textView = [[[UITextView alloc] initWithFrame:frame] autorelease];
				textView.textColor = [UIColor blackColor];
				//    textView.font = [UIFont fontWithName:kFontName size:kTextViewFontSize];
				textView.delegate = self;
				textView.backgroundColor = [UIColor whiteColor];
				
				textView.editable = NO;
				textView.text = @"1. Only people with valid Airborne versions from the App Store may submit highscores\n2. Any form of cheating gravity such as playing in space is strictly prohibited (though skydiving is allowed)";
				textView.returnKeyType = UIReturnKeyDone;
				textView.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
				
				// note: for UITextView, if you don't like autocompletion while typing use:
				// myTextView.autocorrectionType = UITextAutocorrectionTypeNo;
				rules = textView;
			}
			((CellTextView *)cell).view = rules;
			return cell;
			
		case 3:
			cell = [tableView dequeueReusableCellWithIdentifier:@"savecell"];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"savecell"] autorelease];
			}
			[cell setText:[[NSString alloc] initWithFormat:@"Submit my %.2f score!",score]];
			
			submitCell = cell;
			
			if (saving) {
				UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,32,32)];
				activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
				[activity startAnimating];
				[activity sizeToFit];
				activity.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
				cell.accessoryView = activity;
				[activity release];
			}else{
				cell.accessoryView = nil;
				[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
			}

			return cell;
			
		default: return nil;
	}
	
}

@end



/*
-(id) initWithScore:(float) score {// andFrame:(CGRect) frame {
	if (self = [super init]) {
		
	}
	[self setTitle:@"Save Highscore"];
	
	printf("load view %f\n", [self view].frame.size.width);
	scrollView = [[UIScrollView alloc] initWithFrame:[self view].frame];
	self.view = scrollView;
	
	printf("load name\n");
	name = [[UITextField alloc] initWithFrame:CGRectMake(10,20,300,32)];
	name.borderStyle = UITextBorderStyleRoundedRect;
	name.placeholder = @"<enter your name>";
	name.autocorrectionType = UITextAutocorrectionTypeNo;
	name.returnKeyType = UIReturnKeyDone;
	name.clearButtonMode = UITextFieldViewModeWhileEditing;
	[scrollView addSubview:name];
	
	printf("load comments\n");
	comments = [[BorderedTextView alloc] initWithFrame:CGRectMake(10,80,300,200)];
	comments.autocorrectionType = UITextAutocorrectionTypeNo;
	comments.editable = YES;
	[scrollView addSubview:comments];
	
	printf("load nothing else\n");	
	return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
*/