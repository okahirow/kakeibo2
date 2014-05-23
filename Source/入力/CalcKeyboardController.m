//
//  CalcKeyboardController.m
//  kakeibo
//
//  Created by hiro on 12/01/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CalcKeyboardController.h"

@implementation CalcKeyboardController
@synthesize text_field, val1, val2, ret, ope, state;
@synthesize plus_button, minus_button, equal_button, clear_button, del_button, save_button;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void) show_val{
	if(self.state == Input_val1){
		self.text_field.text = [NSString stringWithFormat:@"%d", self.val1];
	}
	else if(self.state == Select_ope){
		if(self.ope == Plus){
			self.text_field.text = [NSString stringWithFormat:@"%d + ", self.val1];
		}
		else{
			self.text_field.text = [NSString stringWithFormat:@"%d - ", self.val1];
		}
	}
	else if(self.state == Input_val2){
		if(self.ope == Plus){
			self.text_field.text = [NSString stringWithFormat:@"%d + %d", self.val1, self.val2];
		}
		else{
			self.text_field.text = [NSString stringWithFormat:@"%d - %d", self.val1, self.val2];
		}
	}
	else if(self.state == Show_ret){
		self.text_field.text = [NSString stringWithFormat:@"%d", self.ret];
	}
	
	[self.save_button setEnabled:true];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	if([self.text_field.text isEqualToString:@""] == true){
		self.val1 = 0;
		[self.save_button setEnabled:false];
	}
	else{
		self.val1 = [self.text_field.text intValue];
		[self.save_button setEnabled:true];
	}
	self.val2 = 0;
	self.ret = 0;
	self.ope = Plus;
	self.state = Input_val1;
	
	//self.text_field.text = [NSString stringWithFormat:@"%d", self.val1];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	
	if(self.state == Input_val1){
		
	}
	else if(self.state == Select_ope){
		self.text_field.text = [NSString stringWithFormat:@"%d", self.val1];
	}
	else if(self.state == Input_val2){
		self.text_field.text = [NSString stringWithFormat:@"%d", self.val1];
	}
	else if(self.state == Show_ret){
		
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (int) get_ret{
	if(self.ope == Plus){
		return self.val1 + self.val2;
	}
	else if(self.ope == Minus){
		return self.val1 - self.val2;
	}
	
	return 0;
}


- (IBAction) num_button_tap:(id) sender{
	int num = ((UIView*)sender).tag;
	
	if(self.state == Input_val1){
		self.val1 = self.val1 * 10 + num;
	}
	else if(self.state == Select_ope){
		self.state = Input_val2;
		self.val2 = num;
	}
	else if(self.state == Input_val2){
		self.val2 = self.val2 * 10 + num;
	}
	else if(self.state == Show_ret){
		self.state = Input_val1;
		self.val1 = num;
	}
	
	[self show_val];
	
	// サウンドの再生。
	[self play_click_sound];
}

- (IBAction) plus_button_tap{
	if(self.state == Input_val1){
		self.ope = Plus;
		self.state = Select_ope;
	}
	else if(self.state == Select_ope){
		self.ope = Plus;
	}
	else if(self.state == Input_val2){
		self.val1 = [self get_ret];
		
		self.ope = Plus;
		self.state = Select_ope;
	}
	else if(self.state == Show_ret){
		self.val1 = self.ret;
		
		self.ope = Plus;
		self.state = Select_ope;
	}
	
	[self show_val];
	
	// サウンドの再生。
	[self play_click_sound];
}

- (IBAction) minus_button_tap{
	if(self.state == Input_val1){
		self.ope = Minus;
		self.state = Select_ope;
	}
	else if(self.state == Select_ope){
		self.ope = Minus;
	}
	else if(self.state == Input_val2){
		self.val1 = [self get_ret];
		
		self.ope = Minus;
		self.state = Select_ope;
	}
	else if(self.state == Show_ret){
		self.val1 = self.ret;
		
		self.ope = Minus;
		self.state = Select_ope;
	}
	
	[self show_val];
	
	// サウンドの再生。
	[self play_click_sound];
}

- (IBAction) equal_button_tap{
	if(self.state == Input_val1){
		self.ret = self.val1;
		
		self.state = Show_ret;
	}
	else if(self.state == Select_ope){
		self.ret = self.val1;
		
		self.state = Show_ret;
	}
	else if(self.state == Input_val2){
		self.ret = [self get_ret];
		
		self.state = Show_ret;
	}
	else if(self.state == Show_ret){
		//nothing
	}
	
	[self show_val];
	
	[self.text_field resignFirstResponder];
	
	// サウンドの再生。
	[self play_click_sound];
}

- (IBAction) clear_button_tap{
	self.val1 = 0;
	self.val2 = 0;
	self.ret = 0;
	self.ope = Plus;
	self.state = Input_val1;
	
	[self show_val];
	
	// サウンドの再生。
	[self play_click_sound];
}

- (IBAction) del_button_tap{
	if(self.state == Input_val1){
		self.val1 = self.val1 / 10;
	}
	else if(self.state == Select_ope){
		self.val1 = self.val1 / 10;
		
		self.state = Input_val1;
	}
	else if(self.state == Input_val2){
		self.val2 = self.val2 / 10;
	}
	else if(self.state == Show_ret){
		self.val1 = self.ret / 10;
		
		self.state = Input_val1;
	}
	
	[self show_val];
	
	// サウンドの再生。
	[self play_click_sound];
}

- (IBAction) save_button_tap{
	
}

- (void) play_click_sound{
	BOOL is_play = CFPreferencesGetAppBooleanValue(
										   CFSTR("keyboard"),
										   CFSTR("/var/mobile/Library/Preferences/com.apple.preferences.sounds"),
										   NULL);
	
	if(is_play == true){
		AudioServicesPlaySystemSound(0x450);
	}

}

@end
