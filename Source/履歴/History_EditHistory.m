//
//  History_EditHistory.m
//  kakeibo
//
//  Created by hiro on 12/06/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "History_EditHistory.h"
#import "History_YearList.h"
#import "CommonAPI.h"
#import "History_HistoryList.h"

@interface History_EditHistory ()

@end

@implementation History_EditHistory

//保存ボタンが押された
- (IBAction) save_button_tap{
	//不正な文字が含まれる場合
	if([CommonAPI is_valid_string:memo_text_field_.text] == false){
		UIAlertView* alart = [[UIAlertView alloc] initWithTitle:nil 
														 message:NSLocalizedString(@"STR-207", nil) 
														delegate:nil 
											   cancelButtonTitle:nil 
											   otherButtonTitles:NSLocalizedString(@"STR-081", nil), nil];
		
		[alart show];
		return;
	}
	
	
	NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int unitFlags = NSYearCalendarUnit |
	NSMonthCalendarUnit |
	NSDayCalendarUnit;
	
	NSDateComponents *components = [cal components:unitFlags fromDate:self.date_];
	int year = [components year];
	int month = [components month];
	int day = [components day];
	
	[self.history_ edit_date:year month:month day:day];
	[self.history_ edit_category:self.category_name_];
	[self.history_ edit_val:[self.val_text_field_.text intValue]];
	[self.history_ edit_memo:self.memo_text_field_.text];
	
	NSArray *allControllers = self.navigationController.viewControllers;
	id parent_vc = allControllers[[allControllers count] - 2];
	[parent_vc data_changed];
	
	[self.navigationController popViewControllerAnimated:YES];
}

//ダイアログのボタンが押された場合
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	//削除の場合
	if(buttonIndex == 0){
		//カテゴリーを削除する
		[self.history_ del_history];
				
		NSArray *allControllers = self.navigationController.viewControllers;
		id parent_vc = allControllers[[allControllers count] - 2];
		[parent_vc data_changed];

		[self.navigationController popViewControllerAnimated:YES];
	}
	//キャンセル
	else{
		return;
	}
}

@end
