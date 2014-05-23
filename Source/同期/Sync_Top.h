//
//  Sync_Top.h
//  kakeibo
//
//  Created by hiro on 11/04/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUITableView.h"
#import "MyUIViewController.h"
#import "GData.h"
#import "MyDBCategory.h"
#import "MyDBHistory.h"
#import "MyDBCustomAna.h"


@interface Sync_Top : MyUIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	IBOutlet MyUITableView* table_view_;
	IBOutlet UIButton* start_button_;
	IBOutlet UIProgressView* progress_;
	IBOutlet UILabel* status_label_;
	
	NSString* usr_name_;
	NSString* usr_pass_;
	Boolean is_remember_name_pass_;
	NSString* db_name_;
	
	BOOL is_syncing_;
	
	NSMutableArray* db_category_list_;
	NSInteger db_category_next_id_;
	NSMutableArray* db_history_list_;
	NSInteger db_history_next_id_;
	NSMutableArray* db_custom_list_;
	NSInteger db_custom_next_id_;
	
	NSMutableArray* _new_category_list_;
	NSInteger new_category_next_id_;
	NSMutableArray* _new_history_list_;
	NSInteger new_history_next_id_;
	NSMutableArray* _new_custom_list_;
	NSInteger new_custom_next_id_;	
	
	//google docs用
	GDataServiceGoogleDocs* service_docs;
	GDataServiceGoogleSpreadsheet* service_sheet;
	
	GDataServiceTicket* ticket_authenticate_service;
	GDataServiceTicket* ticket_get_doc_list;
	GDataServiceTicket* ticket_update_db;
	GDataServiceTicket* ticket_upload_new_db;
	GDataHTTPFetcher* db_doc_fetcher;
	
	GDataEntryDocBase* update_db_doc_;
	
	NSString* org_db_doc_id_;
	GDataDateTime* org_db_doc_lastupdate_date_;
}

@property (copy) NSString* usr_name_;
@property (copy) NSString* usr_pass_;
@property (copy) NSString* db_name_;
@property (assign) BOOL is_syncing_;

@property (strong) NSMutableArray* db_category_list_;
@property (assign) NSInteger db_category_next_id_;
@property (strong) NSMutableArray* db_history_list_;
@property (assign) NSInteger db_history_next_id_;
@property (strong) NSMutableArray* db_custom_list_;
@property (assign) NSInteger db_custom_next_id_;

@property (strong) NSMutableArray* anew_category_list_;
@property (assign) NSInteger new_category_next_id_;
@property (strong) NSMutableArray* anew_history_list_;
@property (assign) NSInteger new_history_next_id_;
@property (strong) NSMutableArray* anew_custom_list_;
@property (assign) NSInteger new_custom_next_id_;

@property (strong) GDataServiceGoogleDocs* service_docs;
@property (strong) GDataServiceGoogleSpreadsheet* service_sheet;
@property (strong) GDataServiceTicket* ticket_authenticate_service;
@property (strong) GDataServiceTicket* ticket_get_doc_list;
@property (strong) GDataServiceTicket* ticket_update_db;
@property (strong) GDataServiceTicket* ticket_upload_new_db;
@property (strong) GDataHTTPFetcher* db_doc_fetcher;

@property (copy) NSString* org_db_doc_id_;
@property (copy) GDataDateTime* org_db_doc_lastupdate_date_;
@property (strong) GDataEntryDocBase* update_db_doc_;

- (IBAction) start_button_tap_;
- (BOOL) name_edit_end:(UITextField *)textField;
- (BOOL) pass_edit_end:(UITextField *)textField;
- (IBAction) remenber_settingSwitchChanged:(id)sender;

- (void) set_db_name:(NSString*) db_name;

//google docs用
- (MyDBCategory*) get_db_cat:(NSInteger) cat_id;
- (MyDBCategory*) get_new_cat:(NSInteger) cat_id;

- (MyDBHistory*) get_db_his:(NSInteger) his_id;
- (MyDBHistory*) get_new_his:(NSInteger) his_id;

- (MyDBCustomAna*) get_db_custom:(NSInteger) ana_id;
- (MyDBCustomAna*) get_new_custom:(NSInteger) ana_id;

- (void) error_sync:(NSString*)err_meg;
- (void) cancel_sync;

- (void) init_service;
- (void) req_authenticate_service;
- (void) ack_authenticate_service:(GDataServiceTicket *)ticket authenticatedWithError:(NSError *)error;
- (void) req_get_doc_list;
- (void) ack_get_doc_list:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedDocList *)feed error:(NSError *)error;
- (void) create_new_db;
- (void) req_download_db:(GDataEntrySpreadsheetDoc*) sheet_entry;
- (void) ack_download_db:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data;
- (void) ack_download_db:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error;
- (void) get_db_data:(NSString*)data_text;


- (void) init_new_db;
- (void) new_db_apply_category_change:(NSArray*) add_list del:(NSArray*) del_list edit:(NSArray*)edit_list;
- (void) new_db_apply_history_change:(NSArray*) add_list del:(NSArray*) del_list edit:(NSArray*)edit_list;
- (void) new_db_apply_custom_change:(NSArray*) add_list del:(NSArray*) del_list edit:(NSArray*)edit_list;

- (void) check_conflict;
- (void) new_db_apply_conflict:(NSArray*)conflict_category_list history:(NSArray*)conflict_history_list custom:(NSArray*)conflict_custom_list;

- (NSData*) create_new_db_data;
- (void) req_get_doc_list2;
- (void) ack_get_doc_list2:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedDocList *)feed error:(NSError *)error;
- (void) req_update_db:(GDataEntryDocBase*) db_doc;
- (void) ack_update_db:(GDataServiceTicket *)ticket finishedWithEntry:(GDataEntryStandardDoc *)entry error:(NSError *)error;
- (void) update_local_db;
- (void) req_upload_new_db;
- (void) ack_upload_new_db:(GDataServiceTicket *)ticket finishedWithEntry:(GDataEntryStandardDoc *)entry error:(NSError *)error;

@end
