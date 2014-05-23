//
//  Ana_EditHistory.m
//  kakeibo
//
//  Created by hiro on 11/04/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Ana_EditHistory.h"
#import "MyModel.h"
#import "Ana_Top.h"
#import "MyCategorySelectCell.h"
#import "Ana_SelectCategory.h"
#import "Calc_UITextField.h"
#import "CommonAPI.h"
#import "MyUIActionSheet.h"


@implementation Ana_EditHistory
@synthesize history_, category_name_, date_, val_, memo_, val_text_field_, memo_text_field_;


- (id) initWithHistory:(DBHistory*)history{
	if((self = [super init])){
		//NavigationController用設定
		self.navigationItem.title = NSLocalizedString(@"STR-023", nil);
		
		self.history_ = history;
		
		NSCalendar* cal = [NSCalendar currentCalendar];
		NSDateComponents *components = [[NSDateComponents alloc] init];
		[components setYear:self.history_.cur.year];
		[components setMonth:self.history_.cur.month];
		[components setDay:self.history_.cur.day];
		
		self.category_name_ = self.history_.cur.category;
		self.date_ = [cal dateFromComponents:components];
		self.val_ = [NSString stringWithFormat:@"%d", self.history_.cur.val];
		self.memo_ = self.history_.cur.memo;
		
		self.val_text_field_ = nil;
		self.memo_text_field_ = nil;
	}
	
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	[del_button_ setTitle:NSLocalizedString(@"STR-024", nil) forState:UIControlStateNormal];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR-003", nil) style:UIBarButtonItemStyleBordered 
																			 target:self 
																			 action:@selector(cancel_button_tap)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																							target:self 
																							action:@selector(save_button_tap)];
	
	[self update_add_button];
	[date_picker_ setDate:self.date_ animated:NO];
	[self.view bringSubviewToFront:date_picker_];
	[self show_date_picker:FALSE anim:FALSE];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* return_cell;

	//カテゴリー
	if(indexPath.row == 0){
		static NSString *CellIdentifier = @"Category_Cell2";
		
		MyCategorySelectCell *cell = (MyCategorySelectCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			UIViewController *controller = [[UIViewController alloc] initWithNibName:@"MyCategorySelectCell" bundle:nil];
			cell = (MyCategorySelectCell *)controller.view;
		}

		cell.title_.text = NSLocalizedString(@"STR-025", nil);
		cell.category_.text = self.category_name_;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return_cell = cell;
	}
	//日付
	else if(indexPath.row == 1){
		static NSString *CellIdentifier = @"Date_Cell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
		}
		
		cell.textLabel.text = NSLocalizedString(@"STR-026", nil);
		
		NSDateFormatter* form = [[NSDateFormatter alloc] init];
		[form setDateStyle:NSDateFormatterMediumStyle];
		[form setTimeStyle:NSDateFormatterNoStyle];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 180.0, 22.0)];
		label.backgroundColor = [UIColor clearColor];
		label.text = [form stringFromDate:self.date_];
		label.textAlignment = NSTextAlignmentLeft;
		cell.accessoryView = label;

		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return_cell = cell;
	}
	//金額
	else if(indexPath.row == 2){
		static NSString *CellIdentifier = @"Val_Cell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
		}
		
		cell.textLabel.text = NSLocalizedString(@"STR-027", nil);
		
		Calc_UITextField *text_field = [[Calc_UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 180.0, 22.0)];
		text_field.text = self.val_;
		text_field.placeholder = NSLocalizedString(@"STR-028", nil);
		text_field.textAlignment = NSTextAlignmentLeft;
		text_field.autocapitalizationType = UITextAutocapitalizationTypeNone;
		text_field.keyboardType = UIKeyboardTypeNumberPad;
		text_field.returnKeyType = UIReturnKeyDone;
		[text_field addTarget:self action:@selector(val_edit_start:) forControlEvents:UIControlEventEditingDidBegin];
		[text_field addTarget:self action:@selector(val_edit:) forControlEvents:UIControlEventEditingChanged];
		[text_field addTarget:self action:@selector(val_edit_end:) forControlEvents:UIControlEventEditingDidEndOnExit];
		[text_field addTarget:self action:@selector(val_edit_end:) forControlEvents:UIControlEventEditingDidEnd];
		
		self.val_text_field_ = text_field;
		
		cell.accessoryView = text_field;
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return_cell = cell;
	}
	//メモ
	else{
		static NSString *CellIdentifier = @"Memo_Cell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
		}
		
		cell.textLabel.text = NSLocalizedString(@"STR-029", nil);
		
		UITextField *text_field = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 180.0, 22.0)];
		text_field.text = self.memo_;
		text_field.placeholder = NSLocalizedString(@"STR-030", nil);
		text_field.textAlignment = NSTextAlignmentLeft;
		text_field.autocapitalizationType = UITextAutocapitalizationTypeNone;
		text_field.keyboardType = UIKeyboardTypeDefault;
		text_field.returnKeyType = UIReturnKeyDone;
		[text_field addTarget:self action:@selector(memo_edit_start:) forControlEvents:UIControlEventEditingDidBegin];
		[text_field addTarget:self action:@selector(memo_edit_end:) forControlEvents:UIControlEventEditingDidEndOnExit];
		[text_field addTarget:self action:@selector(memo_edit_end:) forControlEvents:UIControlEventEditingDidEnd];
		
		self.memo_text_field_ = text_field;
		
		cell.accessoryView = text_field;
		
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return_cell = cell;
	}
	
	return return_cell;
}


//セルが選択された
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//カテゴリー
	if(indexPath.row == 0){
		//カテゴリ選択画面へ
		UIViewController* next_view = [[Ana_SelectCategory alloc] initWithStyle:UITableViewStyleGrouped];
		[self.navigationController pushViewController:next_view animated:YES];
	}
	//日付
	if(indexPath.row == 1){
		if(self.val_text_field_ != nil){
			[self val_edit_end:self.val_text_field_];
		}
		if(self.memo_text_field_ != nil){
			[self memo_edit_end:self.memo_text_field_];
		}
		
		[date_picker_ setDate:self.date_ animated:NO];
		[self show_date_picker:TRUE anim:TRUE];
	}
	//金額
	else if(indexPath.row == 2){
		if(self.memo_text_field_ != nil){
			[self memo_edit_end:self.memo_text_field_];
		}
		
		[self show_date_picker:FALSE anim:TRUE];
		
		[self.val_text_field_ becomeFirstResponder];
	}
	//メモ
	else{
		if(self.val_text_field_ != nil){
			[self val_edit_end:self.val_text_field_];
		}
		
		[self show_date_picker:FALSE anim:TRUE];
		
		[self.memo_text_field_ becomeFirstResponder];
	}
}


//金額の編集完了
- (BOOL) val_edit_end:(UITextField *)textField{
	self.val_ = textField.text;
	
	[textField resignFirstResponder];
	
	[self update_add_button];
	
	return TRUE;
}

//金額の編集開始
- (BOOL) val_edit_start:(UITextField *)textField{
	[self show_date_picker:FALSE anim:TRUE];

	return TRUE;
}


//金額の変更
- (BOOL) val_edit:(UITextField *)textField{
	self.val_ = textField.text;
	
	[self update_add_button];
	
	return TRUE;
}


//メモの編集完了
- (BOOL) memo_edit_end:(UITextField *)textField{
	self.memo_ = textField.text;
	
	[textField resignFirstResponder];
	
	return TRUE;
}


//メモの編集開始
- (BOOL) memo_edit_start:(UITextField *)textField{
	[self show_date_picker:FALSE anim:TRUE];
	
	return TRUE;
}


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
	
	//トップに戻って再集計
	NSArray *allControllers = self.navigationController.viewControllers;
	
	Ana_Top* top = (Ana_Top*)allControllers[0];

	[top get_ana_data];
	[self.navigationController popToViewController:top animated:YES];
}


//登録ボタンの更新
- (void) update_add_button{
	if([self.val_ isEqualToString:@""] || [self.category_name_ isEqualToString:@""]){
		[self.navigationItem.rightBarButtonItem setEnabled:FALSE];
	}
	else{
		[self.navigationItem.rightBarButtonItem setEnabled:TRUE];
	}
}


- (void) show_date_picker:(BOOL)is_show anim:(BOOL)is_anim{
	if(is_anim == TRUE){
		[UIView beginAnimations:NULL context:NULL];
	}
	
	if(is_show == TRUE && date_picker_.alpha == 0.0f){
		//　現在のビューの中心位置を取得
		CGPoint center = date_picker_.center;
		//　現在のビューの矩形と高さを取得
		CGRect picker_frame = date_picker_.frame;
		CGFloat height = CGRectGetHeight(picker_frame);
		//　不透明化して上に移動
		date_picker_.alpha = 1.0f;
		center.y -= height;
		//　中心位置を変更
		date_picker_.center = center;
		
		//スクロールする
		[table_view_ scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
	}
	else if(is_show == FALSE && date_picker_.alpha == 1.0f){		
		//　現在のビューの中心位置を取得
		CGPoint center = date_picker_.center;
		//　現在のビューの矩形と高さを取得
		CGRect frame = date_picker_.frame;
		CGFloat height = CGRectGetHeight(frame);
		//　不透明化して上に移動
		date_picker_.alpha = 0.0f;
		center.y += height;
		//　中心位置を変更
		date_picker_.center = center;
	}
	
	if(is_anim == TRUE){
		[UIView commitAnimations];
	}	
}

- (IBAction) pickerDidChange:(UIDatePicker*)date_picker{
	self.date_ = date_picker.date;
	
	[table_view_ reloadData];
}


- (void) set_category_name:(NSString*)name{
	self.category_name_ = name;
	[table_view_ reloadData];
}


//削除ボタンが押された場合
- (IBAction) del_button_tap{
	UIActionSheet* sheet = [[MyUIActionSheet alloc] init];
	sheet.delegate = self;
	sheet.title = NSLocalizedString(@"STR-031", nil);
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
		[self.history_ del_history];
		
		//トップに戻って再集計
		NSArray *allControllers = self.navigationController.viewControllers;
		
		Ana_Top* top = (Ana_Top*)allControllers[0];
		
		[top get_ana_data];
		[self.navigationController popToViewController:top animated:YES];
	}
	//キャンセル
	else{
		return;
	}
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
