//
//  Setting_CrashLog.m
//  kakeibo
//
//  Created by hiro on 12/01/09.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Setting_CrashLog.h"

@implementation Setting_CrashLog

//ビューが表示される直前
- (void)viewWillAppear:(BOOL)animated {
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	text_view.text = [settings valueForKey:@"SYNC_LOG"];
	
    [super viewWillAppear:animated];
}

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.title = NSLocalizedString(@"STR-205", nil);
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

@end

