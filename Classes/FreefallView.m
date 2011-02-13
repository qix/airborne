//
//  FreefallView.m
//  Freefall
//
//  Created by Josh on 2009/05/27.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "FreefallView.h"
#import "FreefallAppDelegate.h"

@implementation FreefallView



float current = 0.0f;
float best[10];
float total = 0.0f;
float last = 0.0f;

float negAccel[100];

float timeSince = 1000.0f;

char bestfile[512];
float score[10];
BOOL wasCheating = NO;
BOOL bouncing = NO;
BOOL flying = NO;
BOOL cheating = NO;
BOOL scored = NO;
UIAcceleration *lastAcceleration = nil;


// Implement loadView to create a view hierarchy programmatically, without using a nib.
-(void) loadScores {
	int k;
	
	NSArray *dirnames = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	sprintf(bestfile,"%s/best",[[dirnames objectAtIndex:0] UTF8String]);
	for (k = 0; k < 10; k++) {
		score[k] = best[k] = 0.0f;
	}
	for (k = 0; k < 100; k++) { negAccel[k] = 0.0f; };
	
	FILE *f = fopen(bestfile,"r");
	if (f) {
		for (k = 0; k < 10; k++) {
			fscanf(f,"%f",&score[k]);
		}
		for (k = 0; k < 10; k++) {
			fscanf(f,"%f",&best[k]);
		}
		fscanf(f,"%f",&total);
		fclose(f);
	}
	
}
-(float) bestScore { 
	return best[0];
}
-(float) totalScore { 
	return total;
}
- (void)loadView {
	
	//[self addSubview: lc];
	//[self addSubview: ld];
	//[self addSubview: lt];
	[self update];
}
-(void) writeScores {
	int k;
	FILE *f = fopen(bestfile,"w");
	if (f) {
		for (k = 0; k < 10; k++) {
			fprintf(f,"%f\n",score[k]);		
		}
		for (k = 0; k < 10; k++) {
			fprintf(f,"%f\n",best[k]);		
		}
		fprintf(f,"%f\n",total);		
		fclose(f);
	}
}



/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/
-(void) scoreColor:(float)s forContext:(CGContextRef)c withBrightness:(float)l {

	
	float f; float t; int fc; 
	
	float colors[] = {
		1.0f, 1.0f, 1.0f, // white - 0
		1.0f, 0.0f, 0.0f, // red - 1
		0.0f, 1.0f, 0.0f, // green - 2
		1.0f, 1.0f, 0.0f, // yellow - 3
		0.0f, 0.0f, 1.0f, // blue - 4
		0.0f, 1.0f, 1.0f, // no idea - 5
		1.0f, 1.0f, 1.0f, //  - 6
		1.0f, 0.0f, 1.0f, //  - 7
		0.4f, 0.6f, 0.8f, //  - 8
		1.0f, 0.6f, 1.0f, //  - 9
		0.0f, 1.0f, 0.6f, //  - 10
		0.4f, 0.4f, 0.4f, //  - 11
		1.0f, 1.0f, 1.0f
	};	
	
	if (s <= 0.5) {	f = 0.0; t = 0.5; fc = 0; }
	else if (s <= 1.00) { f = 0.5; t = 1.00; fc = 1; }
	else if (s <= 1.25) { f = 1.00; t = 1.25; fc = 2; }
	else if (s <= 1.75) { f = 1.25; t = 1.75; fc = 3; }
	else if (s <= 2.25) { f = 1.75; t = 2.25; fc = 4; }
	else if (s <= 3.50) { f = 2.25; t = 3.50; fc = 5; }
	else if (s <= 7.0) { f = 3.5; t = 7.0; fc = 6; }
	else if (s <= 15.0) { f = 7; t = 15.0; fc = 7; }
	else if (s <= 45.0) { f = 15; t = 45.0; fc = 8; }
	else if (s <= 90.0) { f = 45; t = 90.0; fc = 9; }
	else if (s <= 300.0) { f = 90; t = 300.0; fc = 10; }
	else if (s <= 1000) { f = 300; t = 1000.0; fc = 11; }
	else { t = s + 1.0f; f = 1.5f; fc = 12; }
	
	float C[3];
	float n = (s-f)/(t-f);
	for (int k = 0; k < 3; k++) {
		C[k] = (colors[3*fc+k]*(1-n) + colors[3*fc+k+3]*n)*l;
	}
	CGContextSetRGBFillColor(c,C[0],C[1],C[2],1.0f);
}

-(void) drawRect:(CGRect) rect {
	char buffer[64];
	CGContextRef c = UIGraphicsGetCurrentContext();
	sprintf(buffer,"%.1f",best);
	///CGContextSelectFont(c,"Times-Bold",48,kCGEncodingMacRoman);
	//CGContextSetCharacterSpacing(c, 10);
	//CGContextSetTextDrawingMode(c,kCGTextFillStroke);
	CGContextSetRGBFillColor(c, 0.0,0.0,0.0,1.0);
	CGContextFillRect(c, CGRectMake(0,0,320,480));
	CGContextSetRGBFillColor(c, 1.0,1.0,1.0,1.0);
	CGContextSetRGBStrokeColor(c, 0.0,0.0,1.0,0.5);
	
    CGContextSetAllowsAntialiasing(c, true);
	
	UIFont *tipFont = [UIFont systemFontOfSize:18];
	UIFont *commentFont = [UIFont systemFontOfSize:17];
	UIFont *scoreFont = [UIFont systemFontOfSize:40];
	UIFont *smallFont = [UIFont systemFontOfSize:14];

	[@"Recent scores:" drawAtPoint:CGPointMake(40,55) withFont:tipFont];
	for (int k = 0; k < 5; k++) {
		if (k>0 && score[k] < 0.01f) break;
		[self scoreColor:score[k] forContext:c withBrightness:(1.0-k*0.2)];
		if (!(score[k] < 10.00f)) { // not less than 10
			[[NSString stringWithFormat:@"%.1f", score[k]] drawAtPoint:CGPointMake(40,80+55*k) withFont:scoreFont];
		}else{
			[[NSString stringWithFormat:@"%.2f", score[k]] drawAtPoint:CGPointMake(40,80+55*k) withFont:scoreFont];
		}
		if (k == 0) [@"seconds" drawAtPoint:CGPointMake(122,105) withFont:smallFont];
	}
	/*
	NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
	[style setAlignment:NSCenterTextAlignment];
	NSDictionary *attr = [NSDictionary dictionaryWithObject:style andKey:@"NSParagraphStyleAttributeName"];*/
	
	CGContextSetRGBFillColor(c, 0.4, 0.4, 0.4, 1.0);
	[@"Your phone needs to be airborne to play." drawInRect:CGRectMake(5,5,320,20) withFont:commentFont];
	[@"<Double tap to return to menu>." drawInRect:CGRectMake(45,25,320,20) withFont:commentFont];
	
	CGContextSetRGBFillColor(c, 1.0, 1.0, 1.0, 1.0);
	[@"High scores:" drawAtPoint:CGPointMake(200,55) withFont:tipFont];
	
	for (int k = 0; k < 5; k++) {
		if (k>0 && best[k] < 0.01f) break;
		[self scoreColor:best[k] forContext:c withBrightness:(1.0-k*0.2)];
		if (!(best[k] < 10.00f)) { // not less than 10
			[[NSString stringWithFormat:@"%.1f", best[k]] drawAtPoint:CGPointMake(200,80+55*k) withFont:scoreFont];
		}else{
			[[NSString stringWithFormat:@"%.2f", best[k]] drawAtPoint:CGPointMake(200,80+55*k) withFont:scoreFont];
		}
	}
	
	[self scoreColor:score[0] forContext:c withBrightness:1.0f];
	NSString *message;
	float m = score[0]+0.001;
	if (!scored) {
		CGContextSetRGBFillColor(c, 0.4, 0.4, 0.4, 1.0);
		[@"Confused? Throw me up into the air a couple of centimeters. Maybe do it over a bed to be safe." drawInRect:CGRectMake(15,400,290,80) withFont:commentFont];
		return;
	}
	
	else if (m < 0.05) message = @"%.2f!?! That barely even fell";
	else if (m < 0.06) message = @"%.2f - Come on man!\nThats NOTHING";
	else if (m < 0.07) message = @"%.2f. Higher.\nI wanna go higher!";
	else if (m < 0.08) message = @"I could do %.2f in my sleep :/";
	else if (m < 0.09) message = @"%.2f. Call me when you are ready\nto play properly.";
	else if (m < 0.10) message = @"%.2f\nI can almost feel a bit of air there";
	else if (m < 0.11) message = @"%.2f is weak brother - try again.";
	else if (m < 0.12) message = @"%.2f :/\nMaybe next time?";
	else if (m < 0.13) message = @"%.2f I wanna fly!\nPleeeaase?";
	else if (m < 0.14) message = @"Was that air? %.2f?\nI think it might have been";
	else if (m < 0.15) message = @"I air for %.2f walking down stairs";
	else if (m < 0.16) message = @"A fruit could jump for %.2f seconds.";
	else if (m < 0.17) message = @"Seriously? %.2f?\nYou're not even trying";
	else if (m < 0.18) message = @"%.2f AIR!";
	else if (m < 0.19) message = @"Can you take me higher than %.2f?";
	else if (m < 0.20) message = @"%.2f? Thats barely even up";
	else if (m < 0.21) message = @"Apparently mice can air for %.2f,\nCan you beat the mice?";
	else if (m < 0.22) message = @"My grandma can jump %.2f";
	else if (m < 0.23) message = @"Did you see that?\nI could see the ground from %.2f";
	else if (m < 0.24) message = @"Hit me (higher than %.2f)\nbaby one more time";
	else if (m < 0.25) message = @"%.2f is almost getting nowhere :/";
	else if (m < 0.30) message = @"%.2f doesn't really count as freefall";
	else if (m < 0.31) message = @"%.2f is high enough for me. NOT.";
	else if (m < 0.32) message = @"I had %.2f to think of a comment.\nI failed.";
	else if (m < 0.33) message = @"I'm sure you could beat %.2f :)";
	else if (m < 0.34) message = @"Just a bit more than %.2f,\nthings get interesting now";
	else if (m < 0.35) message = @"%.2f - Things are starting to look up";
	else if (m < 0.40) message = @"%.2f! I definately felt that one :)";
	else if (m < 0.45) message = @"%.2f a little bit more to 0.5!";
	else if (m < 0.49) message = @"%.2f... Come onnnnnn!";
	else if (m < 0.50) message = @"%.2f!!! Half a second!";
	else if (m < 0.51) message = @"Its go time! %.2f!";
	else if (m < 0.55) message = @"%.2f - I'm flying now";
	else if (m < 0.60) message = @"%.2f!!!! Weeeeeeee!!!";
	else if (m < 0.65) message = @"%.2f seconds! I could do a backflip!";
	else if (m < 0.70) message = @":) %.2f in the air. Thats decent.";
	else if (m < 0.75) message = @"Your %.2f isn't that far off 1.00!";
	else if (m < 0.80) message = @"You got %.2f...\nCome on, you can reach a second!";
	else if (m < 0.85) message = @"%.2f - wow, that was awesome!";
	else if (m < 0.90) message = @"I'm getting a bit scared of heights.\n%.2f seconds is too much.";
	else if (m < 0.95) message = @"%.2f come on!\nThat was so close to a second";
	else if (m < 1.00) message = @"%.2f seconds! Oh my! :D";
	else if (m < 1.01) message = @"Wow. A full second of air!";
	else if (m < 1.05) message = @"At %.2f seconds, I could be an astronaut!";
	else if (m < 1.10) message = @"I think I can fly (for %.2f seconds)\nI think I can touch the sky!";
	else if (m < 1.15) message = @"%.2f, I think its time to take me to an airshow";
	else if (m < 1.20) message = @"%.2f I think I just beat Neil Armstrong";
	else if (m < 1.25) message = @"%.2f :D - That gravity stuff doesnt apply to me";
	else if (m < 1.30) message = @"%.2f I could see home from up there";
	else if (m < 1.35) message = @"Yeah! Nice!\nJust like Tony Hawks!";
	else if (m < 1.40) message = @"%.2f seconds aaaaah!\nCaaaaaatch me!";
	else if (m < 1.50) message = @"%.2f! Waaait! Was that a unicorn?\nSend me back up!";
	else if (m < 1.60) message = @"%.2f higher higher!\nI want to touch clouds";
	else if (m < 1.70) message = @"%.2f is higher than Bob Marley";
	else if (m < 1.80) message = @"%.2f is like inifinity dude.";
	else if (m < 1.90) message = @"That was like weow!";
	else if (m < 2.00) message = @"I was freefalling for %.2f seconds!";
	else if (m < 2.10) message = @"TWO SECONDS! Thats like impossible :/";
	else if (m < 2.20) message = @"Bet you've never freefalled for %.2f seconds!";
	else if (m < 2.30) message = @"Im freeee; free falling yeah!\nSo far for %.2f seconds";
	else if (m < 2.40) message = @"I can fly. I just did now\nFor %.2f seconds";
	else if (m < 2.50) message = @"If I fly for %.2f seconds in a jungle\nWho will hear me scream?";
	else if (m < 2.60) message = @"I believe I can fly, I believe I can touch the sky!";
	else if (m < 2.70) message = @"%.2f seconds.\nImagine your grandmother doing that.";
	else if (m < 2.80) message = @"\"Tony Hawks\" - who's that?";
	else if (m < 2.90) message = @"Annnd thats a new record!";
	else if (m < 3.00) message = @"Einstein was wrong.";
	else if (m < 3.25) message = @"I am iron man.";
	else if (m < 3.50) message = @"Did I tell you I'm scared of heights?";
	else if (m < 3.75) message = @"%.2f thats like. High.";
	else if (m < 4.00) message = @"I'm flying through space.";
	else if (m < 4.25) message = @"I can touch the sskkkkyyy";
	else if (m < 4.50) message = @"Super-maan";
	else if (m < 4.75) message = @"%.2f is higher than my mom.";
	else if (m < 5.00) message = @"Wooo. Oh my! %.2f seconds! Wooo!";
	else if (m < 5.50) message = @"And thats the 5 second barrier gone.\nThats like the speed of sound.";
	else if (m < 6.00) message = @"I. am. flying.";
	else if (m < 6.50) message = @"I'm a bird. Oh wait. Err,\n%.2f seconds for a phone?";
	else if (m < 7.00) message = @"%.2f seconds! Nice!";
	else if (m < 7.50) message = @"I can't think of words to describe it :/";
	else if (m < 8.00) message = @"I am the walrus *eagle.";
	else if (m < 8.50) message = @"Eight seconds!? Are you cheating?";
	else if (m < 9.00) message = @"My hovercraft is full of eels.";
	else if (m < 9.50) message = @"I can fly, so high.\nOver the rainbow.";
	else if (m < 10.00) message = @"We're almost at warp speed captain.";
	else if (m < 11.00) message = @"Wait. You just broke the ten second barrier";
	else if (m < 12.00) message = @"This is crazy man";
	else if (m < 13.00) message = @"Please say someone is going to catch me";
	else if (m < 14.00) message = @"I wish I could just sit on the ground :/";
	else if (m < 15.00) message = @"Please stop this nonsense. I'm going too fast";
	else if (m < 16.00) message = @"I..... cant... slow down";
	else if (m < 17.00) message = @"Noooooooooooooooooooooo";
	else if (m < 18.00) message = @"This is kinda fun!";
	else if (m < 19.00) message = @"I'm probably going to die when I stop :(";
	else if (m < 20.00) message = @"I can't feel my legs =/";
	else if (m < 25.00) message = @"I'm a bird, and a plane";
	else if (m < 30.00) message = @"Supermaaaaaan";
	else if (m < 35.00) message = @"I'm like Peter Pan. or something.";
	else if (m < 40.00) message = @"How the hell haven't I hit the ground yet?";
	else if (m < 45.00) message = @"I think I can see the ground now";
	else if (m < 50.00) message = @"Ohhhh my goddd.\nWhy aren't there brakes?!!?";
	else if (m < 55.00) message = @"Helpppp me! I'm falllling";
	else if (m < 60.00) message = @"This is the scariest thing a human has put me through.";
	else if (m < 65.00) message = @"A FULL MINUTE OF AIR!\nWEEEEEOOOOW!";
	else message = @"I'm flllllyyyyyyyiiing now!";
	
	[[NSString stringWithFormat:message, score[0]] drawInRect:CGRectMake(15,400,290,80) withFont:commentFont];
}

-(void) update {
	[self setNeedsDisplay];
	/*
	if (lastAcceleration) {
		v = [[NSString alloc] initWithFormat:@"X:%.2f,Y:%.2f,Z:%.2f",lastAcceleration.x,lastAcceleration.y,lastAcceleration.z];
		[ld setText:v];
	}*/
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	BOOL cheatOk = NO;
	static int cheatPoint = 0;
	for (UITouch *myTouch in touches)
    {
		printf("%d taps with %d touches\n",myTouch.tapCount, touches.count);
		
		if (touches.count == 4) {
			if (cheatPoint == 0) { cheatPoint++; return; }
			else if (cheatPoint == 2) {
				cheatPoint = 0;
				wasCheating = YES;
				cheating = YES;
				return;
			}
		}else if (touches.count == 3) {
			if (cheatPoint == 1) { 
				cheatPoint++; return;
			}
			
			
		}else if (myTouch.tapCount > 1) {
			if (touches.count == 1) {
				[delegate showMenu];
			}
		}else{
			cheating = NO;
		}
	}
	cheatPoint = 0;
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	/*score[0] += 0.0001;
	[self update];
	return;*/
	int k; int j;

	if (lastAcceleration) {
		float old_current = current;
		current += 1.0f/100;
		if (!cheating) {

			if (current > 0.3) {
				
			if ((fabs(lastAcceleration.z)+fabs(lastAcceleration.y)+fabs(lastAcceleration.x) > 0.8) &&
				(fabs(acceleration.z)+fabs(acceleration.y)+fabs(acceleration.x) > 0.8)) {
				current = 0.0;
			}else{
				
			}
			
			}
			if (current < 0.3) {
				if (acceleration.z > 0.2 && lastAcceleration.z > 0.2) current = 0.0;
				if (acceleration.y > 0.2 && lastAcceleration.y > 0.2) current = 0.0;
				if (acceleration.x > 0.2 && lastAcceleration.x > 0.2) current = 0.0;
				if (acceleration.z < -0.2 && lastAcceleration.z < -0.2) current = 0.0;
				if (acceleration.y < -0.2 && lastAcceleration.y < -0.2) current = 0.0;
				if (acceleration.x < -0.2 && lastAcceleration.x < -0.2) current = 0.0;
			}		
		}
		if (current > 0.05f) {
			if (!flying) {
				flying = YES;
				if (timeSince < 0.10) {
					bouncing = YES;
				}else{
					bouncing = NO;
					for (k = 9; k >= 1; k--) {
						score[k] = score[k-1];
					}
					score[0] = 0.0f;
					scored = YES;
				}
			}
			if (old_current < 0.10f && current >= 0.10f) {
				[delegate showFreefall];
			}
			if (old_current < 0.05f && current >= 0.05f) {
				
				[delegate playSound];
			}
			if (old_current < 0.6f && current >= 0.6f) {
				
				[delegate repeatSound];
			}
			if (current > score[0]) {
				score[0] = current;
			}
			
			[self update];
		}else if (current < 0.025f) {
			if (flying) {
				
				[delegate stopSound];
				// Depending on the score, allow more time for a bounce
				if (score[0] > 2.0f) {
					timeSince = -0.5f;
				}else if (score[0] > 1.0f) {
					timeSince = -0.2f;
				}else if (score[0] > 0.5f) {
					timeSince = -0.1f;
				}else{
					timeSince = 0.0f;
				}
				if (!wasCheating) {
					for (k = 0; k < 10; k++) {
						if (score[0] > best[k]){
							for (j = 10-1; j >= k+1; j--) {
								best[j] = best[j-1];
							}
							best[k] = score[0];
							break;
						}
					}
					total += score[0];
				} 
				flying = NO;
				[self writeScores];
				[self update];
				if (score[0] > 0.4f) {
					// Give them a message
					float b,s,hs;
					b = score[0];
					s = 0.5*(9.8)*b*b;
					hs = s/2.0;
					[[[UIAlertView alloc] initWithTitle:@"Airborne Statistics" message:[[NSString alloc] initWithFormat:@"This device was airborne for %.2f seconds. Thats a height of %.2fm if it was thrown and caught from the same height or %.2fm if it was dropped.%s",b,hs,s,wasCheating?" Although that was in cheat mode, so your score wasn't counted.":""] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
				}
				wasCheating = NO;
				cheating = NO;
			}else{
				timeSince += 1.0f/100;
			}
		}
	}
	
	if (lastAcceleration) [lastAcceleration release];
	lastAcceleration = acceleration;
	[lastAcceleration retain];
}



- (void)dealloc {
    [super dealloc];
}

@end
