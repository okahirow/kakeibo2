//
//  Ana_InputCategory.m
//  PSPTimer
//
//  Created by hiro on 10/11/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Ana_InputCategory.h"
#import "Ana_EditHistory.h"
#import "CommonAPI.h"

@implementation Ana_InputCategory


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"STR-019", nil);

	textField_.delegate = self;
	textField_.text = @"";
	textField_.placeholder = NSLocalizedString(@"STR-020", nil);			
	
	[textField_ becomeFirstResponder];
}

- (void) cancel_button_tap{
	[self.navigationController popViewControllerAnimated:YES];
}


//テキストの編集が終わったとき
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	//不正な文字が含まれる場合
	if([CommonAPI is_valid_string:textField.text] == false){
		UIAlertView* alart = [[UIAlertView alloc] initWithTitle:nil 
														 message:NSLocalizedString(@"STR-207", nil) 
														delegate:nil 
											   cancelButtonTitle:nil 
											   otherButtonTitles:NSLocalizedString(@"STR-081", nil), nil];
		
		[alart show];
		return FALSE;
	}
	
	if([textField.text length] == 0){
		return FALSE;
	}
	else{
		NSArray *allControllers = self.navigationController.viewControllers;
		Ana_EditHistory* parent_parent = (Ana_EditHistory*)allControllers[[allControllers count] - 3];
		[parent_parent set_category_name:textField.text];
		
		[self.navigationController popToViewController:parent_parent animated:YES];
	}
	
	return TRUE;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	textField_ = nil;
}


- (void)dealloc {
	textField_ = nil;
}


@end
