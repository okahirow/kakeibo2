//
//  Debug_AllCategoryList.m
//  kakeibo
//
//  Created by hiro on 11/03/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Debug_AllCustomAnaList.h"
#import "DBCustomAna.h"
#import "MyModel.h"


@implementation Debug_AllCustomAnaList

@synthesize custom_ana_list_;


#pragma mark -
#pragma mark Initialization


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	int next_tmp_ana_id = [settings integerForKey:@"NEXT_TMP_ANA_ID"];

	//ナビゲーションバーの設定
	self.navigationItem.title = [NSString stringWithFormat:@"全カスタム集計(next_tmp_id:%d)", next_tmp_ana_id];
}


//ビューが表示される直前
- (void)viewWillAppear:(BOOL)animated {
	self.custom_ana_list_ = [[NSMutableArray alloc] initWithArray:[g_model_ get_all_custom_ana_list]];
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
    return [custom_ana_list_ count];
}

//セルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 80;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	DBCustomAna* ana = custom_ana_list_[indexPath.row];
	
	cell.textLabel.text = [NSString stringWithFormat:@"%d, %d, %@, %@, %@, %d", ana.index, ana.ana_id, ana.diff_type, ana.org.name, ana.cur.name, ana.is_show];
	[cell.detailTextLabel setNumberOfLines:4];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", ana.org.formula, ana.cur.formula];
	
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

