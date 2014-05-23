//
//  Debug_AllHistoryList.m
//  kakeibo
//
//  Created by hiro on 11/03/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Debug_AllHistoryList.h"
#import "DBHistory.h"
#import "MyModel.h"
#import "MyDebugHistoryCell.h"


@implementation Debug_AllHistoryList

@synthesize history_list_;


#pragma mark -
#pragma mark Initialization


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	int next_tmp_his_id = [settings integerForKey:@"NEXT_TMP_HIS_ID"];
	
	//ナビゲーションバーの設定
	self.navigationItem.title = [NSString stringWithFormat:@"全履歴(next_tmp_id:%d)", next_tmp_his_id];
}


//ビューが表示される直前
- (void)viewWillAppear:(BOOL)animated {
	self.history_list_ = [[NSMutableArray alloc] initWithArray:[g_model_ get_all_history_list]];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [history_list_ count];
}


//セルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 66;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Debug_History_Cell";
	
	MyDebugHistoryCell* cell = (MyDebugHistoryCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		UIViewController *controller = [[UIViewController alloc] initWithNibName:@"MyDebugHistoryCell" bundle:nil];
		cell = (MyDebugHistoryCell *)controller.view;
	}    
    // Configure the cell...
	
	DBHistory* history = history_list_[indexPath.row];
	
	cell.label1_.text = [NSString stringWithFormat:@"%d, %@", history.his_id, history.diff_type];
	cell.label2_.text = [NSString stringWithFormat:@"%d/%d/%d, %@, %d, %@", history.org.year, history.org.month, history.org.day, history.org.category, history.org.val, history.org.memo];
	cell.label3_.text = [NSString stringWithFormat:@"%d/%d/%d, %@, %d, %@", history.cur.year, history.cur.month, history.cur.day, history.cur.category, history.cur.val, history.cur.memo];

    return cell;
}


#pragma mark -
#pragma mark Table view delegate


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

