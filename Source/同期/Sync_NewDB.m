//
//  Sync_NewDB.m
//  kakeibo
//
//  Created by hiro on 11/04/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Sync_NewDB.h"
#import "Sync_Top.h"


@implementation Sync_NewDB


- (id) init{
	if((self = [super init])){
		//ナビゲーションバーの設定
		self.title = NSLocalizedString(@"STR-088", nil);
	}
	
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR-003", nil) style:UIBarButtonItemStyleBordered 
																			 target:self 
																			 action:@selector(cancel_button_tap)];
	
	text_field_.text = @"";
	
	[text_field_ becomeFirstResponder];
}


//テキストの編集が終わったとき
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
	if([text_field_.text length] == 0){
		return FALSE;
	}
	else{
		NSArray *allControllers = self.navigationController.viewControllers;
		Sync_Top* parent_parent = (Sync_Top*)allControllers[[allControllers count] - 3];
		[parent_parent set_db_name:text_field_.text];
		
		[self.navigationController popToViewController:parent_parent animated:YES];
	}
	
	return TRUE;
}


//キャンセルボタンタップ
- (void) cancel_button_tap{
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
