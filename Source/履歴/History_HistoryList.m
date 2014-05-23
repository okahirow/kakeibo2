//
//  History_HistoryList.m
//  kakeibo
//
//  Created by hiro on 12/06/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "History_HistoryList.h"
#import "MyModel.h"
#import "MyHistoryCell.h"
#import "CommonAPI.h"
#import "History_EditHistory.h"

@interface History_HistoryList ()

@end

@implementation History_HistoryList
@synthesize year, month, day, history_list;

- (id) init:(int)year_ month:(int)month_ day:(int)day_{
	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.year = year_;
		self.month = month_;
		self.day = day_;
		self.history_list = nil;
		
		[self load_data];
    }
	
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) data_changed{
	[self load_data];
	
	[self.tableView reloadData];
}

- (void) load_data{
	//すべて
	if(year <= 0){
		self.title = @"すべて";
		self.history_list = [g_model_ get_all_history_list];
	}
	//年
	else if(month <= 0){
		self.title = [NSString stringWithFormat:@"%d年", year];
		NSPredicate* pred = [NSPredicate predicateWithFormat:@"year_cur == %d and diff_type != %@", year, @"del"];
		self.history_list = [g_model_ get_history_list_with_pred:pred];
	}
	//月
	else if(day <= 0){
		self.title = [NSString stringWithFormat:@"%d年%d月", year, month];
		NSPredicate* pred = [NSPredicate predicateWithFormat:@"year_cur == %d and month_cur == %d and diff_type != %@", year, month, @"del"];
		self.history_list = [g_model_ get_history_list_with_pred:pred];
	}
	//日
	else{
		self.title = [NSString stringWithFormat:@"%d年%d月%d日", year, month, day];
		NSPredicate* pred = [NSPredicate predicateWithFormat:@"year_cur == %d and month_cur == %d and day_cur == %d and diff_type != %@", year, month, day, @"del"];
		self.history_list = [g_model_ get_history_list_with_pred:pred];
	}
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	if([settings boolForKey:@"IS_SORT_ASCEND"] == TRUE){
		self.history_list = [self.history_list sortedArrayUsingSelector:@selector(compare_date_ascend:)];
	}
	else{
		self.history_list = [self.history_list sortedArrayUsingSelector:@selector(compare_date_descend:)];
	}
}

//ビューが表示される直前
- (void)viewWillAppear:(BOOL)animated {	
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

//セルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

//履歴セルを返す
- (UITableViewCell *)get_history_cell:(UITableView *)tableView year:(NSInteger)year_ month:(NSInteger)month_ day:(NSInteger)day_ category:(NSString*)category_ val:(NSInteger)val_ memo:(NSString*)memo_{
	static NSString *CellIdentifier = @"HistoryCell";
	
	MyHistoryCell *cell = (MyHistoryCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		UIViewController *controller = [[UIViewController alloc] initWithNibName:@"MyHistoryCell" bundle:nil];
		cell = (MyHistoryCell *)controller.view;
	}
	
	cell.date_.text = [NSString stringWithFormat:@"%d/%02d/%02d", year_, month_, day_];
	cell.category_.text = category_;
	cell.val_.text = [CommonAPI money_str:val_];
	cell.memo_.text = memo_;
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	
	return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.history_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    DBHistory* his = (self.history_list)[indexPath.row];
	
	return [self get_history_cell:tableView year:his.cur.year month:his.cur.month day:his.cur.day category:his.cur.category val:his.cur.val memo:his.cur.memo];
}

//詳細表示ボタンが押された
-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath{
	DBHistory* history = (self.history_list)[indexPath.row];
	
	UIViewController* next_view = [[History_EditHistory alloc] initWithHistory:history];
	[self.navigationController pushViewController:next_view animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


@end
