//
//  History_YearList.m
//  kakeibo
//
//  Created by hiro on 12/06/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "History_YearList.h"
#import "MyModel.h"
#import "History_HistoryList.h"
#import "History_MonthList.h"


@implementation History_YearList

//ビューが表示される直前
- (void)viewWillAppear:(BOOL)animated {
	NSArray* history_list = [g_model_ get_all_history_list];
	if([history_list count] > 0){
		DBHistory* start_history = history_list[[history_list count] - 1];
		DBHistory* end_history = history_list[0];
		
		start_year = start_history.cur.year;
		end_year = end_history.cur.year;
		
		if(start_year > end_year){
			end_year = start_history.cur.year;
			start_year = end_history.cur.year;
		}
	}
	else{
		start_year = 0;
		end_year = 0;
	}
	
	[self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.title = @"履歴";
	start_year = 0;
	end_year = 0;	
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section == 0){
		return 1;
	}
	else{
		if(start_year == 0 || end_year == 0){
			return 0;
		}
		else{
			return (end_year - start_year) + 1;
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
    // Configure the cell...
	if(indexPath.section == 0){
		cell.textLabel.text = NSLocalizedString(@"STR-214", nil);
	}
	else{
		cell.textLabel.text = [NSString stringWithFormat:@"%d年", start_year + indexPath.row];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
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
    if(indexPath.section == 0){
		UIViewController* next_view = [[History_HistoryList alloc] init:0 month:0 day:0];
		[self.navigationController pushViewController:next_view animated:YES];
	}
	else{	
		UIViewController* next_view = [[History_MonthList alloc] init:start_year + indexPath.row];
		[self.navigationController pushViewController:next_view animated:YES];
	}
}


@end
