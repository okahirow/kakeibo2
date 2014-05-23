//
//  Settings_CustomAna_Add.m
//  kakeibo
//
//  Created by hiro on 11/04/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Settings_CustomAna_Add.h"
#import "Settings_CustomAna_SelCategory.h"
#import "DBCustomAna.h"
#import <QuartzCore/QuartzCore.h>
#import "CommonAPI.h"


@implementation Settings_CustomAna_Add


- (id) init{
	if((self = [super init])){
		//ナビゲーションバーの設定
		self.title = NSLocalizedString(@"STR-001", nil);
	}
	
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	text_field_.text = @"";
	[text_field_ addTarget:self action:@selector(text_edit:) forControlEvents:UIControlEventEditingChanged];
	text_field_.delegate = self;
	
	text_view_.text = @"";
	text_view_.font = [UIFont systemFontOfSize:14];
	text_view_.layer.borderWidth = 1;
	text_view_.layer.borderColor = [[UIColor grayColor] CGColor];
	text_view_.layer.cornerRadius = 8;
	text_view_.clipsToBounds = YES;
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	[segment_ setTitle:[settings stringForKey:@"MONEY_UNIT"] forSegmentAtIndex:0];

	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR-003", nil) style:UIBarButtonItemStyleBordered 
																			 target:self 
																			 action:@selector(cancel_button_tap)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																							target:self 
																							action:@selector(save_button_tap)];
	
	
	[self update_add_button];
}


//ラベルが編集された
- (BOOL) text_edit:(UITextField *)textField{
	[self update_add_button];
	
	return TRUE;
}


//ラベルの編集が終わったとき
- (IBAction) text_edit_end:(UITextField *)textField{
	return;
}


//ラベルの編集が終わったとき
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	
	return TRUE;
}


//式の編集が終わったとき
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
        return NO;
    }
	return YES;
}




//登録ボタンの更新
- (void) update_add_button{
	if([text_field_.text isEqualToString:@""]){
		[self.navigationItem.rightBarButtonItem setEnabled:FALSE];
	}
	else{
		[self.navigationItem.rightBarButtonItem setEnabled:TRUE];
	}
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
		NSString* unit;
		
		if(segment_.selectedSegmentIndex == 0){
			unit = @"￥";
		}
		else{
			unit = @"%";
		}
		
		//カテゴリを追加
		[g_model_ add_custom_ana:text_field_.text formula:text_view_.text unit:unit is_show:TRUE];
		
		[self.navigationController popViewControllerAnimated:YES];
	}
	else {
		UIAlertView* alart = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STR-101", nil) 
														 message:@"" 
														delegate:nil 
											   cancelButtonTitle:nil 
											   otherButtonTitles:NSLocalizedString(@"STR-006", nil), nil];
		
		[alart show];		
	}
}


//キャンセルボタンが押された
- (IBAction) cancel_button_tap{
	[self.navigationController popViewControllerAnimated:YES];
}


//カテゴリー挿入ボタンが押された
- (IBAction) insert_button_tap{
	UIViewController* next_view = [[Settings_CustomAna_SelCategory alloc] init];
	[self.navigationController pushViewController:next_view animated:YES];
}


//カテゴリー名を挿入
- (void) Settings_CustomAna_Add:(NSString*) name{
	text_view_.text = [NSString stringWithFormat:@"%@ [%@] ",text_view_.text, name];
	
	[text_view_ becomeFirstResponder];
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
