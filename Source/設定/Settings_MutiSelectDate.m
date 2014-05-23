//
//  Settings_MutiSelectDate.m
//  kakeibo
//
//  Created by hiro on 12/06/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Settings_MutiSelectDate.h"

@interface Settings_MutiSelectDate ()

@end

@implementation Settings_MutiSelectDate

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																							target:self 
																							action:@selector(save_button_tap)];
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	NSDate* date = [settings objectForKey:@"ANA_MULTI_START_DATE"];
	
	if(date == nil){
		date = [NSDate date];
	}
	
	[date_picker setDate:date];
	
	self.title = @"開始日";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) save_button_tap{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	[settings setObject:date_picker.date forKey:@"ANA_MULTI_START_DATE"];
		
	[self.navigationController popToRootViewControllerAnimated:YES];
}

@end
