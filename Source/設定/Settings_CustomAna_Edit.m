//
//  Settings_CustomAna_Edit.m
//  kakeibo
//
//  Created by hiro on 11/04/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Settings_CustomAna_Edit.h"
#import "Settings_CustomAna_SelCategory.h"
#import "DBCustomAna.h"
#import "CommonAPI.h"
#import "MyUIActionSheet.h"


@implementation Settings_CustomAna_Edit
@synthesize custom_ana_;


- (id) initWithCustomAna:(DBCustomAna*) ana{
	if((self = [super init])){
		self.custom_ana_ = nil;
		self.custom_ana_ = ana;
	}
	
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"STR-002", nil);
	
	text_field_.text = self.custom_ana_.cur.name;
	[text_field_ addTarget:self action:@selector(text_edit:) forControlEvents:UIControlEventEditingChanged];
	text_field_.delegate = self;
	
	text_view_.text = self.custom_ana_.cur.formula;
	text_view_.font = [UIFont systemFontOfSize:14];
	
	[del_button_ setTitle:NSLocalizedString(@"STR-004", nil) forState:UIControlStateNormal];
	
	[switch_ setOn:self.custom_ana_.is_show];
	
	if([self.custom_ana_.cur.unit isEqualToString:@"￥"]){
		[segment_ setSelectedSegmentIndex:0];
	}
	else{
		[segment_ setSelectedSegmentIndex:1];
	}
	
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
	
	if([DBCustomAna is_valid_formula:text_view_.text] == TRUE){
		//変更
		self.custom_ana_.is_show = switch_.on;
		[self.custom_ana_ edit_name:text_field_.text];
		[self.custom_ana_ edit_formula:text_view_.text];

		if(segment_.selectedSegmentIndex == 0){
			[self.custom_ana_ edit_unit:@"￥"];
		}
		else{
			[self.custom_ana_ edit_unit:@"%"];
		}
		
		[self.navigationController popViewControllerAnimated:YES];
	}
	else {
		UIAlertView* alart = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STR-005", nil) 
														 message:@"" 
														delegate:nil 
											   cancelButtonTitle:nil 
											   otherButtonTitles:NSLocalizedString(@"STR-006", nil), nil];
		
		[alart show];		
	}
}


//削除ボタンが押された場合
- (IBAction) del_button_tap{
	UIActionSheet* sheet = [[MyUIActionSheet alloc] init];
	sheet.delegate = self;
	sheet.title = NSLocalizedString(@"STR-007", nil);
	[sheet addButtonWithTitle:NSLocalizedString(@"STR-008", nil)];
	[sheet addButtonWithTitle:NSLocalizedString(@"STR-003", nil)];
	sheet.destructiveButtonIndex = 0;
	sheet.cancelButtonIndex = 1;
	[sheet showInView:self.tabBarController.view];	
	
	return;
}


//ダイアログのボタンが押された場合
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	//削除の場合
	if(buttonIndex == 0){
		//カテゴリーを削除する
		[self.custom_ana_ del_custom_ana];
		
		[self.navigationController popViewControllerAnimated:YES];
	}
	//キャンセル
	else{
		return;
	}
}


//ONOFF更新
- (IBAction) SwitchChanged:(UISwitch*)sender{
	
}




@end
