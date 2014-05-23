//
//  Add_CategoryAdd.m
//  kakeibo
//
//  Created by hiro on 11/04/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Add_CategoryAdd.h"
#import "CommonAPI.h"


@implementation Add_CategoryAdd


- (id) init{
	if((self = [super init])){
		//ナビゲーションバーの設定
		self.title = NSLocalizedString(@"STR-034", nil);
	}
	
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	text_field_.text = @"";
	text_field_.placeholder = NSLocalizedString(@"STR-035", nil);
	[text_field_ addTarget:self action:@selector(text_edit:) forControlEvents:UIControlEventEditingChanged];
	text_field_.delegate = self;
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR-003", nil) style:UIBarButtonItemStyleBordered 
																			 target:self 
																			 action:@selector(cancel_button_tap)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																							target:self 
																							action:@selector(save_button_tap)];
	
	
	[self update_add_button];
	
	[text_field_ becomeFirstResponder];
}


//テキストが編集された
- (BOOL) text_edit:(UITextField *)textField{
	[self update_add_button];
	
	return TRUE;
}


//テキストの編集が終わったとき
- (IBAction) text_edit_end:(UITextField *)textField{
	return;
}


//テキストの編集が終わったとき
-(BOOL)textFieldShouldReturn:(UITextField *)textField{	
	//空の場合
	if([textField.text length] == 0){
		return FALSE;
	}
	else{
		[self save_button_tap];
		return TRUE;
	}
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
	
	//同じカテゴリー名が存在する場合
	if([g_model_ is_exist_category:text_field_.text] == true){
		UIAlertView* alart = [[UIAlertView alloc] initWithTitle:nil 
														 message:NSLocalizedString(@"STR-208", nil) 
														delegate:nil 
											   cancelButtonTitle:nil 
											   otherButtonTitles:NSLocalizedString(@"STR-081", nil), nil];
		
		[alart show];
		return;
	}
	
	//カテゴリを追加
	[g_model_ add_category:text_field_.text];
	
	[self.navigationController popViewControllerAnimated:YES];
}


//キャンセルボタンが押された
- (IBAction) cancel_button_tap{
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
