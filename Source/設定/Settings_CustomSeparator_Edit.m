//
//  Settings_CustomAna_Edit.m
//  kakeibo
//
//  Created by hiro on 11/04/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Settings_CustomSeparator_Edit.h"
#import "CommonAPI.h"
#import "MyUIActionSheet.h"

@implementation Settings_CustomSeparator_Edit

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"STR-191", nil);
	
	text_field_.text = self.custom_ana_.cur.name;
	[text_field_ addTarget:self action:@selector(text_edit:) forControlEvents:UIControlEventEditingChanged];
	text_field_.delegate = self;
	
	[del_button_ setTitle:NSLocalizedString(@"STR-192", nil) forState:UIControlStateNormal];
	
	[switch_ setOn:self.custom_ana_.is_show];
		
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR-003", nil) style:UIBarButtonItemStyleBordered 
																			 target:self 
																			 action:@selector(cancel_button_tap)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																							target:self 
																							action:@selector(save_button_tap)];
	
	
	[self update_add_button];
}


//保存ボタンが押された
- (IBAction) save_button_tap{
	//不正な文字が含まれる場合
	if([CommonAPI is_valid_string:text_field_.text] == false){
		UIAlertView* alart = [[UIAlertView alloc] initWithTitle:nil 
														 message:NSLocalizedString(@"STR-207", nil) 
														delegate:nil 
											   cancelButtonTitle:nil 
											   otherButtonTitles:NSLocalizedString(@"STR-081", nil), nil];
		
		[alart show];
		return;
	}
	
	//変更
	[self.custom_ana_ edit_name:text_field_.text];
	self.custom_ana_.is_show = switch_.on;
	[g_model_ save_model];
		
	[self.navigationController popViewControllerAnimated:YES];
}


//削除ボタンが押された場合
- (IBAction) del_button_tap{
	UIActionSheet* sheet = [[MyUIActionSheet alloc] init];
	sheet.delegate = self;
	sheet.title = NSLocalizedString(@"STR-193", nil);
	[sheet addButtonWithTitle:NSLocalizedString(@"STR-008", nil)];
	[sheet addButtonWithTitle:NSLocalizedString(@"STR-003", nil)];
	sheet.destructiveButtonIndex = 0;
	sheet.cancelButtonIndex = 1;
	[sheet showInView:self.tabBarController.view];	
	
	return;
}


@end
