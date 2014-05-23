//
//  Start_Login.m
//  kakeibo
//
//  Created by hiro on 12/06/06.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Start_Login.h"

@interface Start_Login ()

@end

@implementation Start_Login

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
	[text_field becomeFirstResponder];
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

- (IBAction) login{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	
	if([text_field.text isEqualToString:[settings stringForKey:@"START_PASS"]]){
		[self dismissViewControllerAnimated:YES completion:^{
			NSLog(@"complete");
		}];
	}
	else{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"パスワードが違います。"
															message:@""
														   delegate:self
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
		
		
		text_field.text = @"";
	}
}

@end
