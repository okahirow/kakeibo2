//
//  Sync_SelectDB.h
//  PSPTimer
//
//  Created by hiro on 10/11/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUITableViewController.h"
#import "GData.h"

@interface Sync_SelectDB : MyUITableViewController {
	GDataServiceGoogleSpreadsheet* service_sheet;
	
	GDataFeedSpreadsheet* spreadsheet_feed;
	GDataServiceTicket* ticket_get_spreadsheet_feed;
	
	Boolean is_loading;
}

@property (strong) GDataServiceGoogleSpreadsheet* service_sheet;
@property (strong) GDataFeedSpreadsheet* spreadsheet_feed;
@property (strong) GDataServiceTicket* ticket_get_spreadsheet_list;


- (id) initWithSpreadsheetService:(GDataServiceGoogleSpreadsheet*)service;

- (void) cancel_button_tap;
- (void) cancel_load;
- (void) error_load:(NSString*)err_meg;

- (void) req_get_spreadsheet_list;
- (void) ack_get_spreadsheet_list:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedSpreadsheet *)feed error:(NSError *)error;

@end
