//
//  Add_CategoryList.m
//  kakeibo
//
//  Created by hiro on 11/03/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Add_CategoryList.h"
#import "DBCategory.h"
#import "MyModel.h"
#import "Add_CategoryDetail.h"
#import "Add_CategoryAdd.h"
#import "Add_InputHistory.h"
#import "Add_SeparatorAdd.h"
#import "Add_SeparatorDetail.h"


@implementation Add_CategoryList

@synthesize category_list_;


#pragma mark -
#pragma mark Initialization


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

	//ナビゲーションバーの設定
	self.navigationItem.title = NSLocalizedString(@"STR-033", nil);
	//self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(tap_add)] autorelease];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR-044", nil) style:UIBarButtonItemStyleBordered 
																			  target:self 
																			  action:@selector(sort_button_tap)];
	
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


//ビューが表示される直前
- (void)viewWillAppear:(BOOL)animated {
	self.category_list_ = [[NSMutableArray alloc] initWithArray:[g_model_ get_show_category_list]];
	[self.tableView reloadData];
	
    [super viewWillAppear:animated];
}


/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


#pragma mark -
#pragma mark Table view data source

//セルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	
	if(indexPath.section == 0){
		DBCategory* category = category_list_[indexPath.row];
		
		//セパレーターの場合
		if([category is_separator] == true){
			return 35;
		}
	}
	
	if([settings boolForKey:@"IS_NARROW_CELL"] == true){
		return 35;
	}
	else{
		return 44;
	}
}

//スワイプでの削除を防ぐ
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return UITableViewCellEditingStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 1){
		return 2;
	}
	else{
		return [category_list_ count];
	}
}

//セクション名
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 1){
		return @"";
	}
	else{
		return NSLocalizedString(@"STR-045", nil);
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CategoryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	if(indexPath.section == 1){
		if(indexPath.row == 0){
			cell.textLabel.text = NSLocalizedString(@"STR-046", nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else{
			cell.textLabel.text = NSLocalizedString(@"STR-187", nil);;//NSLocalizedString(@"STR-187", nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		cell.textLabel.textColor = [UIColor blackColor];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	else{
		DBCategory* category = category_list_[indexPath.row];
		
		//セパレーターの場合
		if([category is_separator] == true){
			cell.textLabel.text = category.cur.name;
			cell.textLabel.textColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else{
			cell.textLabel.text = category.cur.name;
			cell.textLabel.textColor = [UIColor blackColor];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		}
		
		//セルに詳細表示アイコンを表示
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section == 0){
		DBCategory* category = category_list_[indexPath.row];
		
		if([category is_separator] == true){
			cell.backgroundColor = [[UIColor alloc] initWithRed:60.0f/255.0f green:140.0f/255.0f blue:1.00f alpha:1.0f];
		}
		else{
			cell.backgroundColor = [UIColor whiteColor];
		}	
	}
	else{
		cell.backgroundColor = [UIColor whiteColor];
	}
}


//並べ替えできるようにする
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 1){
		return NO;
	}
	else{
		return YES;
	}
}


- (NSIndexPath*)tableView:(UITableView*)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath*)sourceIndexPath
	  toProposedIndexPath:(NSIndexPath*)proposedDestinationIndexPath
{
	if(proposedDestinationIndexPath.section == 1){
		return sourceIndexPath;
	}
	else{
		return proposedDestinationIndexPath;
	}
}



//セルの並び替え
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSUInteger fromRow = fromIndexPath.row;
	NSUInteger toRow = toIndexPath.row;
	
	//モデル内の並び替え
	[g_model_ swap_category:fromRow to_index:toRow];
	
	//カテゴリーリストを再取得
	self.category_list_ = [[NSMutableArray alloc] initWithArray:[g_model_ get_show_category_list]];

	[self.tableView reloadData];
}


//詳細表示ボタンが押された
-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath{
	if(tableView.editing == TRUE){
		return;
	}
	else{
		DBCategory* category = (self.category_list_)[indexPath.row];
		
		if([category is_separator] == true){
			UIViewController* next_view = [[Add_SeparatorDetail alloc] initWithCategory:category];
			[self.navigationController pushViewController:next_view animated:YES];
		}
		else{
			UIViewController* next_view = [[Add_CategoryDetail alloc] initWithCategory:category];
			[self.navigationController pushViewController:next_view animated:YES];
		}
	}
}



//項目が編集された
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {  
    //削除の場合
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		//カテゴリーを削除
		DBCategory* del_category = category_list_[indexPath.row];
		[g_model_ del_category:del_category];
		
		//カテゴリーリストを再取得
		self.category_list_ = [[NSMutableArray alloc] initWithArray:[g_model_ get_show_category_list]];
		
        //テーブルからも削除
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		
		//テーブルの表示内容を更新
		for(int i = indexPath.row; i < [self.category_list_ count]; i++){
			DBCategory* category = category_list_[i];

			UITableViewCell* cell = (UITableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
			cell.textLabel.text = category.cur.name;
		}
    }
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

//セルが選択された
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 1){
		if(indexPath.row == 0){
			[self tap_add];
		}
		else{
			UIViewController* next_view = [[Add_SeparatorAdd alloc] init];
			[self.navigationController pushViewController:next_view animated:YES];
		}
	}
	else{
		DBCategory* category = category_list_[indexPath.row];
		
		//セパレーター
		if([category is_separator] == true){
			return;
		}		
		
		if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"jp.oka.hirow.app.kakeibo.free"]){
			if([g_model_ get_show_history_num] >= 100){
				UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"STR-135", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"STR-081", nil),nil];
				[alert show];
				return;
			}
		}
		
		DBCategory* cat = (self.category_list_)[indexPath.row];
		
		UIViewController* next_view = [[Add_InputHistory alloc] initWithCategoryName:cat.cur.name];
		
		//タブバー非表示
		//next_view.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:next_view animated:YES];
	}
}


//追加ボタンが押された場合
- (void) tap_add{
	UIViewController* next_view = [[Add_CategoryAdd alloc] init];
	[self.navigationController pushViewController:next_view animated:YES];
}


//編集ボタンが押された場合
- (void) tap_edit{
	
}


//並べ替えボタンが押された場合
- (void) sort_button_tap{
	if(self.tableView.editing == FALSE){
		self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"STR-047", nil);
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
		
		//self.navigationItem.leftBarButtonItem = nil;

		[self.tableView setEditing:TRUE animated:YES];
	}
	else{
		self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"STR-044", nil);
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;

		//self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(tap_add)] autorelease];
				
		[self.tableView setEditing:FALSE animated:YES];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}




@end

