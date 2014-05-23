//
//  Debug_AllCategoryList.m
//  kakeibo
//
//  Created by hiro on 11/03/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Debug_AllCategoryList.h"
#import "DBCategory.h"
#import "MyModel.h"


@implementation Debug_AllCategoryList

@synthesize category_list_;


#pragma mark -
#pragma mark Initialization


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	int next_tmp_cat_id = [settings integerForKey:@"NEXT_TMP_CAT_ID"];

	//ナビゲーションバーの設定
	self.navigationItem.title = [NSString stringWithFormat:@"全カテゴリー(next_tmp_id:%d)", next_tmp_cat_id];
}


//ビューが表示される直前
- (void)viewWillAppear:(BOOL)animated {
	self.category_list_ = [[NSMutableArray alloc] initWithArray:[g_model_ get_all_category_list]];
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
    return [category_list_ count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	DBCategory* category = category_list_[indexPath.row];
	
	cell.textLabel.text = [NSString stringWithFormat:@"%d, %d, %@, %@, %@", category.index, category.cat_id, category.diff_type, category.org.name, category.cur.name];
	
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

