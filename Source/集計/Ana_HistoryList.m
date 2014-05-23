//
//  Ana_HistoryList.m
//  kakeibo
//
//  Created by hiro on 11/04/13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Ana_HistoryList.h"
#import "MyHistoryCell.h"
#import "DBHistory.h"
#import "Ana_EditHistory.h"
#import "CommonAPI.h"


@implementation Ana_HistoryList
@synthesize category_, history_list_;

#pragma mark -
#pragma mark View lifecycle


- (id) init:(NSString*)category history_list:(NSArray*)history_list{
	if((self = [super init])){
		self.category_ = category;
		self.history_list_ = history_list;
		
		NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
		if([settings boolForKey:@"IS_SORT_ASCEND"] == TRUE){
			self.history_list_ = [history_list sortedArrayUsingSelector:@selector(compare_date_ascend:)];
		}
		else{
			self.history_list_ = [history_list sortedArrayUsingSelector:@selector(compare_date_descend:)];
		}
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.category_;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

//セルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}


//履歴セルを返す
- (UITableViewCell *)get_history_cell:(UITableView *)tableView year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day category:(NSString*)category val:(NSInteger)val memo:(NSString*)memo{
	static NSString *CellIdentifier = @"HistoryCell";
	
	MyHistoryCell *cell = (MyHistoryCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		UIViewController *controller = [[UIViewController alloc] initWithNibName:@"MyHistoryCell" bundle:nil];
		cell = (MyHistoryCell *)controller.view;
	}
	
	cell.date_.text = [NSString stringWithFormat:@"%d/%02d/%02d", year, month, day];
	cell.category_.text = category;
	cell.val_.text = [CommonAPI money_str:val];
	cell.memo_.text = memo;
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	
	return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.history_list_ count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBHistory* his = (self.history_list_)[indexPath.row];
	
	return [self get_history_cell:tableView year:his.cur.year month:his.cur.month day:his.cur.day category:his.cur.category val:his.cur.val memo:his.cur.memo];		
}

//詳細表示ボタンが押された
-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath{
	DBHistory* history = (self.history_list_)[indexPath.row];
		
	UIViewController* next_view = [[Ana_EditHistory alloc] initWithHistory:history];
	[self.navigationController pushViewController:next_view animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
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

