//
//  History_DayList.m
//  kakeibo
//
//  Created by hiro on 12/06/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "History_DayList.h"
#import "History_HistoryList.h"

@implementation History_DayList

- (id) init:(int)year_ month:(int)month_{
	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
		year = year_;
		month = month_;
    }
	
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.title = [NSString stringWithFormat:@"%d年%d月", year, month];
	
	//最終日の取得
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:year];
	[comps setMonth:month];
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDate *date = [cal dateFromComponents:comps];
	NSRange range = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
	last_day = range.length;
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
		return last_day;
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
		cell.textLabel.text = [NSString stringWithFormat:@"%d日", indexPath.row + 1];
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
		UIViewController* next_view = [[History_HistoryList alloc] init:year month:month day:0];
		[self.navigationController pushViewController:next_view animated:YES];
	}
	else{	
		UIViewController* next_view = [[History_HistoryList alloc] init:year month:month day:indexPath.row + 1];
		[self.navigationController pushViewController:next_view animated:YES];
	}
}



@end
