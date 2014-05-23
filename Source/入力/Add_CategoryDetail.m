//
//  Add_CategoryDetail.m
//  kakeibo
//
//  Created by hiro on 11/04/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Add_CategoryDetail.h"
#import "CommonAPI.h"
#import "MyUIActionSheet.h"


@implementation Add_CategoryDetail

@synthesize category_;


- (id) initWithCategory:(DBCategory*)category{
	if((self = [super init])){
		//ナビゲーションバーの設定
		self.title = NSLocalizedString(@"STR-036", nil);
		
		self.category_ = category;
	}
	
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	text_field_.text = self.category_.cur.name;
	text_field_.placeholder = NSLocalizedString(@"STR-035", nil);
	[text_field_ addTarget:self action:@selector(text_edit:) forControlEvents:UIControlEventEditingChanged];
	
	[del_button_ setTitle:NSLocalizedString(@"STR-037", nil) forState:UIControlStateNormal];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR-003", nil) style:UIBarButtonItemStyleBordered 
																			 target:self 
																			 action:@selector(cancel_button_tap)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																							target:self 
																							action:@selector(save_button_tap)];

	
	[self update_add_button];
}


//削除ボタンが押された場合
- (IBAction) del_button_tap{
	UIActionSheet* sheet = [[MyUIActionSheet alloc] init];
	sheet.delegate = self;
	sheet.title = NSLocalizedString(@"STR-038", nil);
	[sheet addButtonWithTitle:NSLocalizedString(@"STR-008", nil)];
	[sheet addButtonWithTitle:NSLocalizedString(@"STR-003", nil)];
	sheet.destructiveButtonIndex = 0;
	sheet.cancelButtonIndex = 1;
	sheet.tag = 1;
	[sheet showInView:self.tabBarController.view];	
	
	return;
}


//ダイアログのボタンが押された場合
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	//削除確認
	if(actionSheet.tag == 1){
		//削除の場合
		if(buttonIndex == 0){
			//カテゴリーを削除する
			[self.category_ del_category];
			
			[self.navigationController popViewControllerAnimated:YES];
		}
		//キャンセル
		else{
			return;
		}
	}
	//名前変更
	else if(actionSheet.tag == 2){
		//はい
		if(buttonIndex == 0){			
			//履歴も変更
			NSPredicate* pred = [NSPredicate predicateWithFormat:@"category_cur == %@ and diff_type != %@", self.category_.cur.name, @"del"];
			NSArray* history_list = [g_model_ get_history_list_with_pred:pred];
			for(int i=0; i<[history_list count]; i++){
				DBHistory* history = history_list[i];
				[history edit_category:text_field_.text];
			}
			
			//名前の変更
			[self.category_ edit_name:text_field_.text];
			
			[self.navigationController popViewControllerAnimated:YES];
		}
		//いいえ
		else if(buttonIndex == 1){
			//名前の変更
			[self.category_ edit_name:text_field_.text];
			
			[self.navigationController popViewControllerAnimated:YES];
		}
		//キャンセル
		else{
			return;
		}
	}
}

//名前を変更する場合
- (IBAction) confirm_change_history{
	UIActionSheet* sheet = [[MyUIActionSheet alloc] init];
	sheet.delegate = self;
	sheet.title = NSLocalizedString(@"STR-209", nil);
	[sheet addButtonWithTitle:NSLocalizedString(@"STR-210", nil)];
	[sheet addButtonWithTitle:NSLocalizedString(@"STR-211", nil)];
	[sheet addButtonWithTitle:NSLocalizedString(@"STR-003", nil)];
	sheet.destructiveButtonIndex = 0;
	sheet.cancelButtonIndex = 2;
	sheet.tag = 2;
	[sheet showInView:self.tabBarController.view];	
	
	return;
}


//テキストが編集された
- (BOOL) text_edit:(UITextField *)textField{
	[self update_add_button];
	
	return TRUE;
}


//テキストの編集が終わったとき
- (IBAction) text_edit_end:(UITextField *)textField{
	
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
	
	//履歴も同時に編集するか確認
	[self confirm_change_history];
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
