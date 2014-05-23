//
//  Sync_SelectDB.m
//  PSPTimer
//
//  Created by hiro on 10/11/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Sync_SelectDB.h"
#import "Sync_Top.h"
#import	"Sync_NewDB.h"
#import "LoadingCell.h"

@implementation Sync_SelectDB
@synthesize service_sheet, spreadsheet_feed, ticket_get_spreadsheet_list;

#pragma mark -
#pragma mark Initialization


- (id) initWithSpreadsheetService:(GDataServiceGoogleSpreadsheet*)service{
	if((self = [super initWithStyle:UITableViewStyleGrouped])){
		self.title = NSLocalizedString(@"STR-087", nil);
		
        self.service_sheet = service;
		
		self.spreadsheet_feed = nil;	
		self.ticket_get_spreadsheet_list = nil;
		is_loading = false;
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR-003", nil) style:UIBarButtonItemStyleBordered 
																			 target:self 
																			 action:@selector(cancel_button_tap)];
	
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self req_get_spreadsheet_list];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	
	if(is_loading == true){
		[self cancel_load];		
	}
}


- (void) cancel_button_tap{
	[self cancel_load];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) cancel_load{
	if(self.ticket_get_spreadsheet_list != nil){
		[self.ticket_get_spreadsheet_list cancelTicket];
	}
	
	is_loading = false;
	
	[self.tableView reloadData];
}

- (void) error_load:(NSString*)err_meg{
	[self cancel_load];
	
	UIAlertView* alart = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STR-051", nil) 
													 message:err_meg 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:NSLocalizedString(@"STR-081", nil), nil];
	
	[alart show];
}

- (void) req_get_spreadsheet_list{
	is_loading = TRUE;
	
	NSURL *feedURL = [NSURL URLWithString:kGDataGoogleSpreadsheetsPrivateFullFeed];
	self.ticket_get_spreadsheet_list = [self.service_sheet fetchFeedWithURL:feedURL delegate:self didFinishSelector:@selector(ack_get_spreadsheet_list:finishedWithFeed:error:)];
	if(self.ticket_get_spreadsheet_list == nil){
		[self error_load:NSLocalizedString(@"STR-082", nil)];
	}
}

- (void) ack_get_spreadsheet_list:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedSpreadsheet *)feed error:(NSError *)error{
	NSLog(@"ack_get_spreadsheet_list feed: %@ \nerror:%@", feed, error);
	self.ticket_get_spreadsheet_list = nil;
	self.spreadsheet_feed = feed;
	
	if(error != nil){
		[self error_load:NSLocalizedString(@"STR-082", nil)];
		return;
	}
	
	//完了
	is_loading = false;
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark Table view data source

//セクション数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


//セルの数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0){
		return 1;
	}
	else{
		if(is_loading == TRUE){
			return 1;
		}
		else{
			return [[self.spreadsheet_feed entries] count];
		}
	}
}


//セクション名
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 0){
		return @"";
	}
	else{
		return NSLocalizedString(@"STR-083", nil);
	}	
}


//セルの作成
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* cell;
	
	//新規作成
	if(indexPath.section == 0){
		static NSString *CellIdentifier = @"Cell_new_db";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		cell.textLabel.text = NSLocalizedString(@"STR-084", nil);
		
		cell.textLabel.minimumScaleFactor = 10.0;
		cell.textLabel.adjustsFontSizeToFitWidth = TRUE;
		cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
	}
	//スプレッドシート一覧
	else{
		if(is_loading == TRUE){
			static NSString *CellIdentifier = @"LoadingCell";
			
			cell = (LoadingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				UIViewController *controller = [[UIViewController alloc] initWithNibName:@"LoadingCell" bundle:nil];
				cell = (LoadingCell *)controller.view;
				
				[(LoadingCell *)cell add_indicator];
			}
			
			((LoadingCell*)cell).title.text = NSLocalizedString(@"STR-085", nil);
			cell.textLabel.minimumScaleFactor = 10.0;
			cell.textLabel.adjustsFontSizeToFitWidth = TRUE;
			cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
		}
		else{
			static NSString *CellIdentifier = @"Cell_sheets";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
			}
			
			NSDateFormatter* form = [[NSDateFormatter alloc] init];
			[form setDateStyle:NSDateFormatterMediumStyle];
			[form setTimeStyle:NSDateFormatterShortStyle];
			
			GDataEntrySpreadsheet* sel_sheet = [self.spreadsheet_feed entries][indexPath.row];
			NSString* sheet_name = [[sel_sheet title] stringValue];
			cell.textLabel.text = sheet_name;
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"STR-086", nil), [form stringFromDate:[[sel_sheet updatedDate] date]]];
			
			cell.textLabel.minimumScaleFactor = 10.0;
			cell.textLabel.adjustsFontSizeToFitWidth = TRUE;
			cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
		}
	}
	
	return cell;
}


#pragma mark -
#pragma mark Table view delegate

//項目が選択された場合
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//新規作成
	if(indexPath.section == 0){
		[self cancel_load];
		
		UIViewController* next_view = [[Sync_NewDB alloc] init];
		[self.navigationController pushViewController:next_view animated:YES];
	}
	//スプレッドシート一覧
	else{
		if(is_loading == TRUE){
			return;		
		}
		else{
			NSArray *allControllers = self.navigationController.viewControllers;
			
			Sync_Top* parent = (Sync_Top*)allControllers[[allControllers count] - 2];
			
			GDataEntrySpreadsheet* sel_sheet = [self.spreadsheet_feed entries][indexPath.row];
			[parent set_db_name:[[sel_sheet title] stringValue]];
			
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
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

