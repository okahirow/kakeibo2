//
//  Settings_CustomAna.m
//  kakeibo
//
//  Created by hiro on 11/03/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Settings_CustomAna.h"
#import "DBCustomAna.h"
#import "MyModel.h"
#import "Settings_CustomAna_Add.h"
#import "Settings_CustomAna_Edit.h"
#import "Settings_CustomSeparator_Add.h"
#import "Settings_CustomSeparator_Edit.h"


@implementation Settings_CustomAna

@synthesize custom_ana_list_;


#pragma mark -
#pragma mark Initialization


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

	//ナビゲーションバーの設定
	self.navigationItem.title = NSLocalizedString(@"STR-098", nil);
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR-044", nil) style:UIBarButtonItemStyleBordered 
																			  target:self 
																			  action:@selector(sort_button_tap)];
	
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


//ビューが表示される直前
- (void)viewWillAppear:(BOOL)animated {
	self.custom_ana_list_ = [[NSMutableArray alloc] initWithArray:[g_model_ get_show_custom_ana_list]];
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

//スワイプでの削除を防ぐ
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return UITableViewCellEditingStyleNone;
}

//セルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {	
	if(indexPath.section == 0){
		DBCustomAna* ana = custom_ana_list_[indexPath.row];
		
		//セパレーターの場合
		if([ana is_separator] == true){
			return 35;
		}
	}
	
	return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 1){
		return 2;
	}
	else{
		return [custom_ana_list_ count];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section == 0){
		DBCustomAna* ana = custom_ana_list_[indexPath.row];
		
		if([ana is_separator] == true){
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


//セクション名
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 0){
		return @"";
	}
	else{
		return @"";
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CustomAnaCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
	
	if(indexPath.section == 1){
		if(indexPath.row == 0){
			cell.textLabel.text = NSLocalizedString(@"STR-099", nil);
			cell.detailTextLabel.text = @"";
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else{
			cell.textLabel.text = @"新しいセパレーターを追加...";
			cell.detailTextLabel.text = @"";
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		cell.textLabel.textColor = [UIColor blackColor];
	}
	else{
		// Configure the cell...
		DBCustomAna* ana = custom_ana_list_[indexPath.row];
				
		//セパレーターの場合
		if([ana is_separator] == true){
			if(ana.is_show == TRUE){
				cell.textLabel.text = ana.cur.name;
			}
			else{
				cell.textLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"STR-100", nil), ana.cur.name];
			}
			
			cell.detailTextLabel.text = @"";
			
			cell.textLabel.textColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
		}
		else{
			if(ana.is_show == TRUE){
				cell.textLabel.text = ana.cur.name;
			}
			else{
				cell.textLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"STR-100", nil), ana.cur.name];
			}
			
			cell.detailTextLabel.text = ana.cur.formula;
			
			cell.textLabel.textColor = [UIColor blackColor];
		}
		
		//セルに詳細表示アイコンを表示
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
    return cell;
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
	[g_model_ swap_custom_ana:fromRow to_index:toRow];
	
	//カテゴリーリストを再取得
	self.custom_ana_list_ = [[NSMutableArray alloc] initWithArray:[g_model_ get_show_custom_ana_list]];

	[self.tableView reloadData];
}


//詳細表示ボタンが押された
-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath{
	if(tableView.editing == TRUE){
		return;
	}
	else{
		DBCustomAna* custom_ana = (self.custom_ana_list_)[indexPath.row];
		
		if([custom_ana is_separator] == true){
			UIViewController* next_view = [[Settings_CustomSeparator_Edit alloc] initWithCustomAna:custom_ana];
			[self.navigationController pushViewController:next_view animated:YES];
		}
		else{
			UIViewController* next_view = [[Settings_CustomAna_Edit alloc] initWithCustomAna:custom_ana];
			[self.navigationController pushViewController:next_view animated:YES];
		}
	}
}



//項目が編集された
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {  
    //削除の場合
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		//カテゴリーを削除
		DBCustomAna* del_ana = custom_ana_list_[indexPath.row];
		[g_model_ del_custom_ana:del_ana];
		
		//カテゴリーリストを再取得
		self.custom_ana_list_ = [[NSMutableArray alloc] initWithArray:[g_model_ get_show_custom_ana_list]];
		
        //テーブルからも削除
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		
		//テーブルの表示内容を更新
		for(int i = indexPath.row; i < [self.custom_ana_list_ count]; i++){
			DBCustomAna* custom_ana = custom_ana_list_[i];

			UITableViewCell* cell = (UITableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
			cell.textLabel.text = custom_ana.cur.name;
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
			UIViewController* next_view = [[Settings_CustomSeparator_Add alloc] init];
			[self.navigationController pushViewController:next_view animated:YES];
		}
	}
}


//追加ボタンが押された場合
- (void) tap_add{
	UIViewController* next_view = [[Settings_CustomAna_Add alloc] init];
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

		[self.tableView setEditing:TRUE animated:YES];
	}
	else{
		self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"STR-044", nil);
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;

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

