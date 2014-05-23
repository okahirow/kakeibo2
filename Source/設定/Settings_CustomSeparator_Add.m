//
//  Settings_CustomSeparator_Add.m
//  kakeibo
//
//  Created by hiro on 11/04/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Settings_CustomSeparator_Add.h"
#import "CommonAPI.h"
#import "MyModel.h"

@implementation Settings_CustomSeparator_Add


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
	
	//カテゴリを追加
	[g_model_ add_custom_ana:text_field_.text formula:@"" unit:@"" is_show:TRUE];

	[self.navigationController popViewControllerAnimated:YES];
}



@end
