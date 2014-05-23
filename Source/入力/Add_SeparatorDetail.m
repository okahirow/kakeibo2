//
//  Add_CategoryDetail.m
//  kakeibo
//
//  Created by hiro on 11/04/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Add_SeparatorDetail.h"
#import "CommonAPI.h"
#import "MyUIActionSheet.h"

@implementation Add_SeparatorDetail

@synthesize category_;


- (id) initWithCategory:(DBCategory*)category{
	if((self = [super init])){
		//ナビゲーションバーの設定
		self.title = NSLocalizedString(@"STR-191", nil);
		
		self.category_ = category;
	}
	
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	text_field_.text = self.category_.cur.name;
	text_field_.placeholder = NSLocalizedString(@"STR-189", nil);
	
	[del_button_ setTitle:NSLocalizedString(@"STR-192", nil) forState:UIControlStateNormal];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR-003", nil) style:UIBarButtonItemStyleBordered 
																			 target:self 
																			 action:@selector(cancel_button_tap)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																							target:self 
																							action:@selector(save_button_tap)];

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


//ダイアログのボタンが押された場合
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
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

//テキストの編集が終わったとき
- (IBAction) text_edit_end:(UITextField *)textField{
	
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
	
	//名前の変更
	[self.category_ edit_name:text_field_.text];
	
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
