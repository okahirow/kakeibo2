//
//  Sync_SelectDB.m
//  PSPTimer
//
//  Created by hiro on 12/11/02.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "Sync_SelectDB.h"
#import "Sync_Top.h"
#import	"Sync_Conflict.h"
#import "MyConflictCell_Category.h"
#import "MyConflictCell_History.h"
#import "MyConflictCell_CustomAna.h"
#import "MyConflictCategory.h"
#import "MyConflictHistory.h"
#import "MyConflictCustomAna.h"
#import "CommonAPI.h"


@implementation Sync_Conflict
@synthesize conflict_category_list_, conflict_history_list_, conflict_custom_list_, img_radio_button_on_, img_radio_button_off_;


#pragma mark -
#pragma mark Initialization


- (id) initWithConflict:(NSArray*)conflict_category_list history:(NSArray*)conflict_history_list custom:(NSArray*)conflict_custom_list{
	if((self = [super initWithStyle:UITableViewStyleGrouped])){
		self.title = NSLocalizedString(@"STR-089", nil);
		
		self.conflict_category_list_ = conflict_category_list;
		self.conflict_history_list_ = conflict_history_list;
		self.conflict_custom_list_ = conflict_custom_list;
		
		//アイコンの読み込み
		NSString* imagePath = [[NSBundle mainBundle] pathForResource:@"RadioButton-Selected" ofType:@"png"];
		self.img_radio_button_on_ = [[UIImage alloc] initWithContentsOfFile:imagePath];
		imagePath = [[NSBundle mainBundle] pathForResource:@"RadioButton-Unselected" ofType:@"png"];
		self.img_radio_button_off_ = [[UIImage alloc] initWithContentsOfFile:imagePath];
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR-062", nil) style:UIBarButtonItemStyleBordered 
																			 target:self 
																			 action:@selector(cancel_button_tap)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self 
																			 action:@selector(done_button_tap)];
}


//ビューが表示される直前
- (void)viewWillAppear:(BOOL)animated {
	UIAlertView* alart = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STR-090", nil) 
													 message:NSLocalizedString(@"STR-091", nil) 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:NSLocalizedString(@"STR-081", nil), nil];
	
	[alart show];
	
    [super viewWillAppear:animated];
}



#pragma mark -
#pragma mark Table view data source

//セクション数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.conflict_category_list_ count] + [self.conflict_history_list_ count] + [self.conflict_custom_list_ count];
}


//セルの数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}


//セクション名
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
	if(section < [self.conflict_category_list_ count]){
		return NSLocalizedString(@"STR-025", nil);
	}
	else if(section < [self.conflict_category_list_ count] + [self.conflict_custom_list_ count]){
		return NSLocalizedString(@"STR-092", nil);
	}
	else{
		return NSLocalizedString(@"STR-093", nil);
	}
}


//セルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section < [self.conflict_category_list_ count]){
		return 44;
	}
	else if(indexPath.section < [self.conflict_category_list_ count] + [self.conflict_custom_list_ count]){
		return 90;
	}
	else{
		return 56;
	}
}


//セルの作成
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* return_cell;
	
	//カテゴリー
	if(indexPath.section < [self.conflict_category_list_ count]){
		//static NSString *CellIdentifier_category = @"MyConflictCell_Category";
		
		//MyConflictCell_Category* cell = (MyConflictCell_Category*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier_category];
		//if (cell == nil) {
			UIViewController *controller = [[UIViewController alloc] initWithNibName:@"MyConflictCell_Category" bundle:nil];
			MyConflictCell_Category* cell = (MyConflictCell_Category *)controller.view;
		//}
		
		int conflict_index = indexPath.section;
		MyConflictCategory* conflict = (self.conflict_category_list_)[conflict_index];
		
		//元データ
		if(indexPath.row == 0){
			cell.label_src_.text = NSLocalizedString(@"STR-094", nil);
			cell.label_val_.text = conflict.local_.org.name;
			cell.label_val_.textColor = [UIColor blackColor];
		}
		//ローカルデータ
		else if(indexPath.row == 1){
			cell.label_src_.text = NSLocalizedString(@"STR-095", nil);
			
			if([conflict.local_.diff_type isEqualToString:@"del"]){
				cell.label_val_.text = NSLocalizedString(@"STR-096", nil);
				cell.label_val_.textColor = [UIColor redColor];
			}
			else{
				cell.label_val_.text = conflict.local_.cur.name;
				cell.label_val_.textColor = [UIColor blackColor];
			}
			
			if(conflict.is_apply_local_ == TRUE){
				cell.radio_button_.image = img_radio_button_on_;
			}
			else{
				cell.radio_button_.image = img_radio_button_off_;
			}
		}
		//サーバーデータ
		else{
			cell.label_src_.text = NSLocalizedString(@"STR-097", nil);
			
			if(conflict.db_ == nil){
				cell.label_val_.text = NSLocalizedString(@"STR-096", nil);
				cell.label_val_.textColor = [UIColor redColor];
			}
			else{
				cell.label_val_.text = conflict.db_.name_;
				cell.label_val_.textColor = [UIColor blackColor];
			}
			
			if(conflict.is_apply_local_ == TRUE){
				cell.radio_button_.image = img_radio_button_off_;
			}
			else{
				cell.radio_button_.image = img_radio_button_on_;
			}
		}
		
		return_cell = (UITableViewCell*)cell;
	}
	//カスタム集計方法
	else if(indexPath.section < [self.conflict_category_list_ count] + [self.conflict_custom_list_ count]){
		//static NSString *CellIdentifier_category = @"MyConflictCell_Category";
		
		//MyConflictCell_Category* cell = (MyConflictCell_Category*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier_category];
		//if (cell == nil) {
		UIViewController *controller = [[UIViewController alloc] initWithNibName:@"MyConflictCell_CustomAna" bundle:nil];
		MyConflictCell_CustomAna* cell = (MyConflictCell_CustomAna *)controller.view;
		//}
		
		int conflict_index = indexPath.section - [self.conflict_category_list_ count];
		MyConflictCustomAna* conflict = (self.conflict_custom_list_)[conflict_index];
		
		//元データ
		if(indexPath.row == 0){
			cell.label_src_.text = NSLocalizedString(@"STR-094", nil);
			cell.label_name_.text = conflict.local_.org.name;
			cell.label_name_.textColor = [UIColor blackColor];
			
			cell.label_formula_.text = conflict.local_.org.formula;
			cell.label_formula_.textColor = [UIColor blackColor];
			
			cell.label_unit_.text = [NSString stringWithFormat:@"単位:%@", conflict.local_.org.unit];
			cell.label_unit_.textColor = [UIColor blackColor];
		}
		//ローカルデータ
		else if(indexPath.row == 1){
			cell.label_src_.text = NSLocalizedString(@"STR-095", nil);
			
			if([conflict.local_.diff_type isEqualToString:@"del"]){
				cell.label_name_.text = NSLocalizedString(@"STR-096", nil);
				cell.label_name_.textColor = [UIColor redColor];
				
				cell.label_formula_.text = @"";
				cell.label_formula_.textColor = [UIColor blackColor];
				
				cell.label_unit_.text = @"";
				cell.label_unit_.textColor = [UIColor blackColor];
			}
			else{
				cell.label_name_.text = conflict.local_.cur.name;
				cell.label_name_.textColor = [UIColor blackColor];
				
				cell.label_formula_.text = conflict.local_.cur.formula;
				cell.label_formula_.textColor = [UIColor blackColor];
				
				cell.label_unit_.text = [NSString stringWithFormat:@"単位:%@", conflict.local_.org.unit];
				cell.label_unit_.textColor = [UIColor blackColor];
			}
			
			if(conflict.is_apply_local_ == TRUE){
				cell.radio_button_.image = img_radio_button_on_;
			}
			else{
				cell.radio_button_.image = img_radio_button_off_;
			}
		}
		//サーバーデータ
		else{
			cell.label_src_.text = NSLocalizedString(@"STR-097", nil);
			
			if(conflict.db_ == nil){
				cell.label_name_.text = NSLocalizedString(@"STR-096", nil);
				cell.label_name_.textColor = [UIColor redColor];
				
				cell.label_formula_.text = @"";
				cell.label_formula_.textColor = [UIColor blackColor];
				
				cell.label_unit_.text = @"";
				cell.label_unit_.textColor = [UIColor blackColor];
			}
			else{
				cell.label_name_.text = conflict.db_.name_;
				cell.label_name_.textColor = [UIColor blackColor];
				
				cell.label_formula_.text = conflict.db_.formula_;
				cell.label_formula_.textColor = [UIColor blackColor];
				
				cell.label_unit_.text = [NSString stringWithFormat:@"単位:%@", conflict.local_.org.unit];
				cell.label_unit_.textColor = [UIColor blackColor];
			}
			
			if(conflict.is_apply_local_ == TRUE){
				cell.radio_button_.image = img_radio_button_off_;
			}
			else{
				cell.radio_button_.image = img_radio_button_on_;
			}
		}
		
		return_cell = (UITableViewCell*)cell;
	}
	//履歴
	else{
		//static NSString *CellIdentifier_history = @"MyConflictCell_History";
		
		//MyConflictCell_History* cell = (MyConflictCell_History*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier_history];
		//if (cell == nil) {
			UIViewController *controller = [[UIViewController alloc] initWithNibName:@"MyConflictCell_History" bundle:nil];
			MyConflictCell_History* cell = (MyConflictCell_History *)controller.view;
		//}
		
		int conflict_index = indexPath.section - [self.conflict_category_list_ count] - [self.conflict_custom_list_ count];
		MyConflictHistory* conflict = (self.conflict_history_list_)[conflict_index];
		
		//元データ
		if(indexPath.row == 0){
			cell.label_src_.text = NSLocalizedString(@"STR-094", nil);
			
			cell.label_date_.text = [NSString stringWithFormat:@"%d/%02d/%02d", conflict.local_.org.year, conflict.local_.org.month, conflict.local_.org.day];
			cell.label_category_.text = conflict.local_.org.category;
			cell.label_val_.text = [CommonAPI money_str:conflict.local_.org.val];
			cell.label_memo_.text = conflict.local_.org.memo;
									
			cell.label_category_.textColor = [UIColor blackColor];
		}
		//ローカルデータ
		else if(indexPath.row == 1){
			cell.label_src_.text = NSLocalizedString(@"STR-095", nil);
			
			if([conflict.local_.diff_type isEqualToString:@"del"]){
				cell.label_date_.text = @"";
				cell.label_val_.text = @"";
				cell.label_memo_.text = @"";
				cell.label_category_.text = NSLocalizedString(@"STR-096", nil);
				cell.label_category_.textColor = [UIColor redColor];
			}
			else{
				cell.label_date_.text = [NSString stringWithFormat:@"%d/%02d/%02d", conflict.local_.cur.year, conflict.local_.cur.month, conflict.local_.cur.day];
				cell.label_category_.text = conflict.local_.cur.category;
				cell.label_val_.text = [CommonAPI money_str:conflict.local_.cur.val];
				cell.label_memo_.text = conflict.local_.cur.memo;
										
				cell.label_val_.textColor = [UIColor blackColor];
			}
			
			if(conflict.is_apply_local_ == TRUE){
				cell.radio_button_.image = img_radio_button_on_;
			}
			else{
				cell.radio_button_.image = img_radio_button_off_;
			}
		}
		//サーバーデータ
		else{
			cell.label_src_.text = NSLocalizedString(@"STR-097", nil);
			
			if(conflict.db_ == nil){
				cell.label_date_.text = @"";
				cell.label_val_.text = @"";
				cell.label_memo_.text = @"";
				cell.label_category_.text = NSLocalizedString(@"STR-096", nil);
				cell.label_category_.textColor = [UIColor redColor];
			}
			else{
				cell.label_date_.text = [NSString stringWithFormat:@"%d/%02d/%02d", conflict.db_.year_, conflict.db_.month_, conflict.db_.day_];
				cell.label_category_.text = conflict.db_.category_;
				cell.label_val_.text = [CommonAPI money_str:conflict.db_.val_];
				cell.label_memo_.text = conflict.db_.memo_;
				
				cell.label_category_.textColor = [UIColor blackColor];
			}
			
			if(conflict.is_apply_local_ == TRUE){
				cell.radio_button_.image = img_radio_button_off_;
			}
			else{
				cell.radio_button_.image = img_radio_button_on_;
			}
		}
		
		return_cell = (UITableViewCell*)cell;
	}
	
	return return_cell;
}


#pragma mark -
#pragma mark Table view delegate

//項目が選択された場合
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//カテゴリ
	if(indexPath.section < [self.conflict_category_list_ count]){
		int conflict_index = indexPath.section;
		
		MyConflictCategory* conflict = (self.conflict_category_list_)[conflict_index];
		
		if(indexPath.row == 1){
			if(conflict.is_apply_local_ == FALSE){
				conflict.is_apply_local_ = TRUE;
				[tableView reloadData];
			}
		}
		else if(indexPath.row == 2){
			if(conflict.is_apply_local_ == TRUE){
				conflict.is_apply_local_ = FALSE;
				[tableView reloadData];
			}
		}
	}
	//集計
	else if(indexPath.section < [self.conflict_category_list_ count] + [self.conflict_custom_list_ count]){
		int conflict_index = indexPath.section - [self.conflict_category_list_ count];
		
		MyConflictCustomAna* conflict = (self.conflict_custom_list_)[conflict_index];
		
		if(indexPath.row == 1){
			if(conflict.is_apply_local_ == FALSE){
				conflict.is_apply_local_ = TRUE;
				[tableView reloadData];
			}
		}
		else if(indexPath.row == 2){
			if(conflict.is_apply_local_ == TRUE){
				conflict.is_apply_local_ = FALSE;
				[tableView reloadData];
			}
		}
	}
	//履歴
	else{
		int conflict_index = indexPath.section - [self.conflict_category_list_ count] - [self.conflict_custom_list_ count];
		
		MyConflictHistory* conflict = (self.conflict_history_list_)[conflict_index];
		
		if(indexPath.row == 1){
			if(conflict.is_apply_local_ == FALSE){
				conflict.is_apply_local_ = TRUE;
				[tableView reloadData];
			}
		}
		else if(indexPath.row == 2){
			if(conflict.is_apply_local_ == TRUE){
				conflict.is_apply_local_ = FALSE;
				[tableView reloadData];
			}
		}
		
	}
}


//キャンセルボタンをタップ
- (void) cancel_button_tap{
	NSArray *allControllers = self.navigationController.viewControllers;
	
	Sync_Top* parent = (Sync_Top*)allControllers[[allControllers count] - 2];
	
	[parent cancel_sync];
	[self.navigationController popViewControllerAnimated:YES];
}


//完了ボタンをタップ
- (void) done_button_tap{
	NSArray *allControllers = self.navigationController.viewControllers;
	
	Sync_Top* parent = (Sync_Top*)allControllers[[allControllers count] - 2];
	
	[parent new_db_apply_conflict:self.conflict_category_list_ history:self.conflict_history_list_ custom:self.conflict_custom_list_];
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}




@end

