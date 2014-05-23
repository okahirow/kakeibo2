//
//  Sync_Top.m
//  kakeibo
//
//  Created by hiro on 11/04/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Sync_Top.h"
#import "GDataDocs.h"
#import "MyDBCategory.h"
#import "MyDBHistory.h"
#import "MyConflictCategory.h"
#import "MyConflictHistory.h"
#import "MyConflictCustomAna.h"
#import "MyModel.h"
#import "Sync_SelectDB.h"
#import "Sync_Conflict.h"


@implementation Sync_Top

@synthesize usr_pass_, usr_name_, db_name_, is_syncing_, db_category_list_, db_category_next_id_, db_history_list_, db_history_next_id_, db_custom_list_, db_custom_next_id_;
@synthesize anew_category_list_, new_category_next_id_, anew_history_list_, new_history_next_id_, anew_custom_list_, new_custom_next_id_;
@synthesize service_docs, service_sheet, ticket_authenticate_service, ticket_get_doc_list, ticket_update_db, db_doc_fetcher, org_db_doc_id_, org_db_doc_lastupdate_date_, update_db_doc_, ticket_upload_new_db;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	[start_button_ setTitle:NSLocalizedString(@"STR-055", nil) forState:UIControlStateNormal];
	
	//初期値の読み込み
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	is_remember_name_pass_ = [settings boolForKey:@"IS_REMEMBER_NAME_PASS"];
	
	if(is_remember_name_pass_ == TRUE){
		self.usr_name_ = [settings stringForKey:@"USR_NAME"];
		self.usr_pass_ = [settings stringForKey:@"USR_PASS"];
	}
	else{
		self.usr_name_ = @"";
		self.usr_pass_ = @"";
	}
	
	self.db_name_ = [settings stringForKey:@"DB_NAME"];
	
	
	//ナビゲーションバーの設定
	self.navigationItem.title = NSLocalizedString(@"STR-056", nil);
	
	self.is_syncing_ = FALSE;
	table_view_.allowsSelection = TRUE;
	
	if(self.is_syncing_ == FALSE){
		//プログレスバーは非表示
		[progress_ setHidden:TRUE];
		[status_label_ setHidden:TRUE];
	}
	else{
		[progress_ setHidden:FALSE];
		[status_label_ setHidden:FALSE];
	}
	
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0){
		return 3;
	}
	else{
		return 1;
	}
}


//セクション名
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 0){
		return NSLocalizedString(@"STR-057", nil);
	}
	else{
		return NSLocalizedString(@"STR-058", nil);
	}	
}


//セルの作成
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    //GoogleDocsアカウント
    if(indexPath.section == 0){
		//ユーザー名
		if(indexPath.row == 0){
			cell.textLabel.text = NSLocalizedString(@"STR-059", nil);
			
			UITextField *text_field = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 170.0, 22.0)];
			text_field.text = self.usr_name_;
			text_field.placeholder = NSLocalizedString(@"STR-059", nil);
			text_field.textAlignment = NSTextAlignmentLeft;
			text_field.autocapitalizationType = UITextAutocapitalizationTypeNone;
			text_field.keyboardType = UIKeyboardTypeEmailAddress;
			text_field.returnKeyType = UIReturnKeyDone;
			[text_field addTarget:self action:@selector(name_edit_end:) forControlEvents:UIControlEventEditingDidEndOnExit];
			[text_field addTarget:self action:@selector(name_edit_end:) forControlEvents:UIControlEventEditingDidEnd];
			if(self.is_syncing_ == TRUE){
				[text_field setEnabled:FALSE];
			}
			
			cell.accessoryView = text_field;
			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		//パスワード
		else if(indexPath.row == 1){
			cell.textLabel.text = NSLocalizedString(@"STR-060", nil);
			
			UITextField *text_field = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 170.0, 22.0)];
			text_field.text = self.usr_pass_;
			text_field.placeholder = NSLocalizedString(@"STR-060", nil);
			text_field.textAlignment = NSTextAlignmentLeft;
			text_field.autocapitalizationType = UITextAutocapitalizationTypeNone;
			text_field.keyboardType = UIKeyboardTypeASCIICapable;
			text_field.returnKeyType = UIReturnKeyDone;
			text_field.secureTextEntry = YES;
			[text_field addTarget:self action:@selector(pass_edit_end:) forControlEvents:UIControlEventEditingDidEndOnExit];
			[text_field addTarget:self action:@selector(pass_edit_end:) forControlEvents:UIControlEventEditingDidEnd];
			if(self.is_syncing_ == TRUE){
				[text_field setEnabled:FALSE];
			}
			
			cell.accessoryView = text_field;
			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		//保存するかどうか
		else{
			cell.textLabel.text = NSLocalizedString(@"STR-061", nil);
			
			UISwitch *switchObj = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 20.0)];
			switchObj.on = is_remember_name_pass_;
			[switchObj addTarget:self action:@selector(remenber_settingSwitchChanged:) forControlEvents:UIControlEventValueChanged];
			if(self.is_syncing_ == TRUE){
				[switchObj setEnabled:FALSE];
			}
			
			cell.accessoryView = switchObj;
			
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		
	}
	//マスターデータ
	else if(indexPath.section == 1){
		cell.textLabel.text = self.db_name_;
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.accessoryView = nil;
		
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	
    return cell;
}


//セルが選択された
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //DB変更の場合
	if(indexPath.section == 1){
		[self init_service];
		
		UIViewController* next_view = [[Sync_SelectDB alloc] initWithSpreadsheetService:self.service_sheet];
		[self.navigationController pushViewController:next_view animated:YES];
	}	
}


//開始ボタンタップ
- (IBAction) start_button_tap_{
	if(self.is_syncing_ == FALSE){
		NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
		[settings setValue:@"" forKey:@"SYNC_LOG"];
		
		//プログレスバーを表示
		[progress_ setHidden:FALSE];
		[progress_ setProgress:0.0f];
		[status_label_ setHidden:FALSE];
		status_label_.text = @"";
		self.is_syncing_ = TRUE;
		table_view_.allowsSelection = FALSE;
		[start_button_ setTitle:NSLocalizedString(@"STR-062", nil) forState:UIControlStateNormal];
		//[start_button_ setTintColor:[UIColor redColor]];
		[start_button_ setValue:[UIColor redColor] forKey:@"tintColor"];
		[table_view_ reloadData];
		
		//タブバーをDisableに
		self.tabBarController.tabBar.userInteractionEnabled = NO;
		
		[self init_service];
		
		//同期処理開始
		[self req_authenticate_service];
	}
	else{
		[self cancel_sync];
	}
}


//ユーザー名の編集完了
- (BOOL) name_edit_end:(UITextField *)textField{
	self.usr_name_ = textField.text;
	
	if(is_remember_name_pass_ == TRUE){
		NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
		[settings setValue:self.usr_name_ forKey:@"USR_NAME"];
	}
	
	[textField resignFirstResponder];
	
	return TRUE;
}


//パスワードの編集完了
- (BOOL) pass_edit_end:(UITextField *)textField{
	self.usr_pass_ = textField.text;
	
	if(is_remember_name_pass_ == TRUE){
		NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
		[settings setValue:self.usr_pass_ forKey:@"USR_PASS"];
	}	
	
	[textField resignFirstResponder];
	
	return TRUE;
}


//スイッチが変更
- (IBAction) remenber_settingSwitchChanged:(id)sender{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	
	if([sender isOn] == TRUE){
		is_remember_name_pass_ = TRUE;
		[settings setValue:self.usr_name_ forKey:@"USR_NAME"];
		[settings setValue:self.usr_pass_ forKey:@"USR_PASS"];
	}
	else{
		is_remember_name_pass_ = FALSE;
		[settings setValue:@"" forKey:@"USR_NAME"];
		[settings setValue:@"" forKey:@"USR_PASS"];
	}
	
	[settings setBool:is_remember_name_pass_ forKey:@"IS_REMEMBER_NAME_PASS"];
}



//対象のDBを変更
- (void) set_db_name:(NSString*) db_name{
	self.db_name_ = db_name;
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	[settings setValue:self.db_name_ forKey:@"DB_NAME"];
	
	[table_view_ reloadData];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
/*	
	if(is_syncing_ == true){
		[self cancel_sync];		
	}
*/ 
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (void) add_sync_log:(NSString*) log{
	//NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	//[settings setValue:[NSString stringWithFormat:@"%@\n%@", [settings valueForKey:@"SYNC_LOG"], log] forKey:@"SYNC_LOG"];
}


//■■■■■■■■■■■■■■■■■■■■■ Google API ■■■■■■■■■■■■■■■■■■■■
//サービスを初期化
- (void) init_service{	
	self.service_docs = [[GDataServiceGoogleDocs alloc] init];		
	[self.service_docs setUserAgent:@"com.okahirow.app.Kakeibo"]; // 自分のアプリに固有な名称  
	[self.service_docs setShouldCacheDatedData:YES];
	[self.service_docs setServiceShouldFollowNextLinks:YES];
	[self.service_docs setUserCredentialsWithUsername:self.usr_name_ password:self.usr_pass_];
	
	self.service_sheet = [[GDataServiceGoogleSpreadsheet alloc] init];		
	[self.service_sheet setUserAgent:@"com.okahirow.app.Kakeibo"]; // 自分のアプリに固有な名称  
	[self.service_sheet setShouldCacheDatedData:YES];
	[self.service_sheet setServiceShouldFollowNextLinks:YES];
	[self.service_sheet setUserCredentialsWithUsername:self.usr_name_ password:self.usr_pass_];
}

//サービスの認証
- (void) req_authenticate_service{
	status_label_.text = NSLocalizedString(@"STR-063", nil);
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	self.ticket_authenticate_service = [self.service_sheet authenticateWithDelegate:self didAuthenticateSelector:@selector(ack_authenticate_service:authenticatedWithError:)];
}

- (void) ack_authenticate_service:(GDataServiceTicket *)ticket authenticatedWithError:(NSError *)error {
	NSLog(@"ack_authenticate_service\nerror:%@", error);
	self.ticket_authenticate_service = nil;
	
	if(error != nil){
		[self error_sync:NSLocalizedString(@"STR-064", nil)];
		return;
	}
	
	[progress_ setProgress:0.05f];
	
	//ファイル一覧取得
	[self req_get_doc_list];
}


//ファイル一覧取得
- (void) req_get_doc_list{
	status_label_.text = NSLocalizedString(@"STR-065", nil);
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	NSURL *feedURL = [GDataServiceGoogleDocs docsFeedURL];
	
	GDataQueryDocs *query = [GDataQueryDocs documentQueryWithFeedURL:feedURL];
	[query setMaxResults:1000];
	[query setShouldShowFolders:NO];
	
	self.ticket_get_doc_list = [self.service_docs fetchFeedWithQuery:query delegate:self didFinishSelector:@selector(ack_get_doc_list:finishedWithFeed:error:)];
	if(self.ticket_get_doc_list == nil){
		[self error_sync:NSLocalizedString(@"STR-066", nil)];
	}
}

- (void) ack_get_doc_list:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedDocList *)feed error:(NSError *)error{
	NSLog(@"ack_get_doc_list feed: %@ \nerror:%@", feed, error);
	self.ticket_get_doc_list = nil;
	
	if(error != nil){
		[self error_sync:NSLocalizedString(@"STR-066", nil)];
		return;
	}
	
	[progress_ setProgress:0.15f];
	
	//同じ名前のスプレッドシートがあるかチェック
	NSArray* doc_list = [feed entries];
	
	for(int i=0; i<[doc_list count]; i ++){
		GDataEntryBase* doc = doc_list[i];
		NSString* name = [[doc title] stringValue];
		BOOL is_spreadsheet = [[doc class] isEqual:[GDataEntrySpreadsheetDoc class]];
		
		if(is_spreadsheet == TRUE && [name compare:self.db_name_] == NSOrderedSame){
			self.org_db_doc_id_ = [doc identifier];
			self.org_db_doc_lastupdate_date_ = [doc updatedDate];
			NSLog(@"id:%@, date:%@", self.org_db_doc_id_, self.org_db_doc_lastupdate_date_);
				
			//ダウンロード開始
			[self req_download_db:(GDataEntrySpreadsheetDoc*)doc];
			return;			
		}
	}
	
	//新規DB作成
	[self create_new_db];
}


//新規DB作成
- (void) create_new_db{
	status_label_.text = NSLocalizedString(@"STR-067", nil);
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	//■■■　同期後のカテゴリ一覧を作成　■■■
	self.anew_category_list_ = [[NSMutableArray alloc] init];
	self.new_category_next_id_ = 0;
	
	NSArray* local_show_category_list = [g_model_ get_show_category_list];
	for(int i=0; i<[local_show_category_list count]; i++){
		DBCategory* local_cat = local_show_category_list[i];
		
		MyDBCategory* new_cat = [[MyDBCategory alloc] init];
		new_cat.id_ = self.new_category_next_id_;
		self.new_category_next_id_ ++;
				
		new_cat.name_ = local_cat.cur.name;
		new_cat.index_ = local_cat.index;
		[self.anew_category_list_ addObject:new_cat];
	}
	
	//■■■　同期後のカスタム集計方法一覧を作成　■■■
	self.anew_custom_list_ = [[NSMutableArray alloc] init];
	self.new_custom_next_id_ = 0;
	
	NSArray* local_show_custom_list = [g_model_ get_show_custom_ana_list];
	for(int i=0; i<[local_show_custom_list count]; i++){
		DBCustomAna* local_ana = local_show_custom_list[i];
		
		MyDBCustomAna* new_ana = [[MyDBCustomAna alloc] init];
		new_ana.id_ = self.new_custom_next_id_;
		self.new_custom_next_id_ ++;
		
		new_ana.name_ = local_ana.cur.name;
		new_ana.formula_ = local_ana.cur.formula;
		new_ana.unit_ = local_ana.cur.unit;
		new_ana.index_ = local_ana.index;
		new_ana.is_show_ = local_ana.is_show;
		[self.anew_custom_list_ addObject:new_ana];
	}	
	
	//■■■　同期後の履歴一覧を作成　■■■
	self.anew_history_list_ = [[NSMutableArray alloc] init];
	self.new_history_next_id_ = 0;
	
	NSArray* local_show_history_list = [g_model_ get_show_history_list];
	for(int i=0; i<[local_show_history_list count]; i++){
		DBHistory* local_his = local_show_history_list[i];
		
		MyDBHistory* new_his = [[MyDBHistory alloc] init];
		new_his.id_ = self.new_history_next_id_;
		self.new_history_next_id_ ++;
		
		new_his.year_ = local_his.cur.year;
		new_his.month_ = local_his.cur.month;
		new_his.day_ = local_his.cur.day;
		new_his.category_ = local_his.cur.category;
		new_his.val_ = local_his.cur.val;
		new_his.memo_ = local_his.cur.memo;
		
		[self.anew_history_list_ addObject:new_his];
	}	
	
	
	[progress_ setProgress:0.35f];
		
	//アップロード開始
	[self req_upload_new_db];
}


//DBのダウンロード
- (void) req_download_db:(GDataEntrySpreadsheetDoc*) sheet_entry{
	status_label_.text = NSLocalizedString(@"STR-068", nil);
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	GDataQuery *query = [GDataQuery queryWithFeedURL:[[sheet_entry content] sourceURL]];
	[query addCustomParameterWithName:@"exportFormat" value:@"csv"];
	
	NSURLRequest* request = [self.service_sheet requestForURL:[query URL] ETag:nil httpMethod:nil];  
	self.db_doc_fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
	[self.db_doc_fetcher setUserData:sheet_entry];
	
	[self.db_doc_fetcher beginFetchWithDelegate:self 
							  didFinishSelector:@selector(ack_download_db:finishedWithData:)
								didFailSelector:@selector(ack_download_db:failedWithError:)];
}

//ダウンロード成功
- (void) ack_download_db:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data{
	//ダウンロードしたファイルの中身を取得
	NSString* db_data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	//NSLog(@"DB data:\n%@", db_data);
	
	self.db_doc_fetcher = nil;
	
	[progress_ setProgress:0.25f];
	
	//データを解析
	[self get_db_data:db_data];
}

//ダウンロード失敗
- (void) ack_download_db:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error{
	NSLog(@"ack_download_db fetcher: %@ \nerror:%@", fetcher, error);
	
	self.db_doc_fetcher = nil;
	
	[self error_sync:NSLocalizedString(@"STR-069", nil)];
}


//DB内のデータ取得
- (void) get_db_data:(NSString*)data_text{
	status_label_.text = NSLocalizedString(@"STR-070", nil);
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	self.db_category_list_ = [[NSMutableArray alloc] init];
	self.db_history_list_ = [[NSMutableArray alloc] init];
	self.db_custom_list_ = [[NSMutableArray alloc] init];
	
	//改行コードを統一
	data_text = [data_text stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
	data_text = [data_text stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
	
	
	//読み込み進捗
	int read_state = 0;	//0:Category列, 1:Categoryタイトル列, 2:カテゴリ列, 3:CustomAna列, 4:集計方法タイトル列, 5:集計方法列, 6:History列, 7:Historyタイトル列, 8:History列
		
	NSArray* line_list = [data_text componentsSeparatedByString:@"\n"];
	NSArray* elem_list;
	
	for(int i=0; i<[line_list count]; i++){
		NSString* line = line_list[i];
		
		//空列
		if([line isEqualToString:@""]){
			continue;
		}
		
		elem_list = [line componentsSeparatedByString:@","];
		
		switch (read_state){
		case 0:	//Category列
			{
			if([elem_list count] < 3){
				[self error_sync:[NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"STR-071", nil), i + 1, NSLocalizedString(@"STR-072", nil)]];
				return;
			}
			
			if([elem_list[0] isEqualToString:NSLocalizedString(@"STR-113", nil)] && [elem_list[1] isEqualToString:NSLocalizedString(@"STR-114", nil)]){
				self.db_category_next_id_ = [elem_list[2] intValue];
				read_state ++;
				break;	
			}
			else{
				[self error_sync:[NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"STR-071", nil), i + 1, NSLocalizedString(@"STR-072", nil)]];
				return;
			}
			}
		case 1:	//Categoryタイトル列
			{
			if([elem_list count] < 2){
				[self error_sync:[NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"STR-071", nil), i + 1, NSLocalizedString(@"STR-072", nil)]];
				return;
			}
			
			if([elem_list[0] isEqualToString:NSLocalizedString(@"STR-115", nil)] && [elem_list[1] isEqualToString:NSLocalizedString(@"STR-116", nil)]){
				read_state ++;
				break;	
			}
			else{
				[self error_sync:[NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"STR-071", nil), i + 1, NSLocalizedString(@"STR-072", nil)]];
				return;
			}
			}
		case 2:	//カテゴリ列
			{
			//CustomAnaが出てきた場合
			if([elem_list[0] isEqualToString:NSLocalizedString(@"STR-117", nil)]){
				i --;
				read_state ++;
				break;
			}
			
			if([elem_list count] < 2){
				[self error_sync:[NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"STR-071", nil), i + 1, NSLocalizedString(@"STR-072", nil)]];
				return;
			}
			
			//カテゴリーのデータを取得
			MyDBCategory* cat = [[MyDBCategory alloc] init];
			if([elem_list[0] isEqualToString:@""]){
				cat.id_ = self.db_category_next_id_;
				self.db_category_next_id_ ++;
			}
			else{
				cat.id_ = [elem_list[0] intValue];
			}
			cat.name_ = elem_list[1];
			[self.db_category_list_ addObject:cat];
			
			break;
			}
		case 3:	//CustomAna列
			{
			if([elem_list count] < 3){
				[self error_sync:[NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"STR-071", nil), i + 1, NSLocalizedString(@"STR-072", nil)]];
				return;
			}
			
			if([elem_list[0] isEqualToString:NSLocalizedString(@"STR-117", nil)] && [elem_list[1] isEqualToString:NSLocalizedString(@"STR-114", nil)]){
				self.db_custom_next_id_ = [elem_list[2] intValue];
				read_state ++;
				break;	
			}
			else{
				[self error_sync:[NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"STR-071", nil), i + 1, NSLocalizedString(@"STR-072", nil)]];
				return;
			}
			}
		case 4:	//集計方法タイトル列
			{
			if([elem_list count] < 4){
				[self error_sync:[NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"STR-071", nil), i + 1, NSLocalizedString(@"STR-072", nil)]];
				return;
			}
			
			if([elem_list[0] isEqualToString:NSLocalizedString(@"STR-115", nil)] && [elem_list[1] isEqualToString:NSLocalizedString(@"STR-118", nil)] && [elem_list[2] isEqualToString:NSLocalizedString(@"STR-119", nil)] && [elem_list[3] isEqualToString:NSLocalizedString(@"STR-120", nil)]){
				read_state ++;
				break;	
			}
			else{
				[self error_sync:[NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"STR-071", nil), i + 1, NSLocalizedString(@"STR-072", nil)]];
				return;
			}
			}
		case 5:	//集計方法列
			{
			//Historyが出てきた場合
			if([elem_list[0] isEqualToString:NSLocalizedString(@"STR-121", nil)]){
				i --;
				read_state ++;
				break;
			}
				
			if([elem_list count] < 4){
				[self error_sync:[NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"STR-071", nil), i + 1, NSLocalizedString(@"STR-072", nil)]];
				return;
			}
			
			//集計方法のデータを取得
			MyDBCustomAna* ana = [[MyDBCustomAna alloc] init];
			if([elem_list[0] isEqualToString:@""]){
				ana.id_ = self.db_custom_next_id_;
				self.db_custom_next_id_ ++;
			}
			else{
				ana.id_ = [elem_list[0] intValue];
			}
			ana.name_ = elem_list[1];
			ana.formula_ = elem_list[2];
			ana.unit_ = elem_list[3];
					
			[self.db_custom_list_ addObject:ana];
			
			break;
			}
		case 6:	//History列
			{
			if([elem_list count] < 3){
				[self error_sync:[NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"STR-071", nil), i + 1, NSLocalizedString(@"STR-072", nil)]];
				return;
			}
			
			if([elem_list[0] isEqualToString:NSLocalizedString(@"STR-121", nil)] && [elem_list[1] isEqualToString:NSLocalizedString(@"STR-114", nil)]){
				self.db_history_next_id_ = [elem_list[2] intValue];
				read_state ++;
				break;	
			}
			else{
				[self error_sync:[NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"STR-071", nil), i + 1, NSLocalizedString(@"STR-072", nil)]];
				return;
			}
			}
		case 7:	//Historyタイトル列
			{
			if([elem_list count] < 7){
				[self error_sync:[NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"STR-071", nil), i + 1, NSLocalizedString(@"STR-072", nil)]];
				return;
			}
			
			if([elem_list[0] isEqualToString:NSLocalizedString(@"STR-115", nil)] && [elem_list[1] isEqualToString:NSLocalizedString(@"STR-122", nil)] && [elem_list[2] isEqualToString:NSLocalizedString(@"STR-123", nil)] && [elem_list[3] isEqualToString:NSLocalizedString(@"STR-124", nil)] && [elem_list[4] isEqualToString:NSLocalizedString(@"STR-125", nil)] && [elem_list[5] isEqualToString:NSLocalizedString(@"STR-126", nil)] && [elem_list[6] isEqualToString:NSLocalizedString(@"STR-127", nil)]){
				read_state ++;
				break;	
			}
			else{
				[self error_sync:[NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"STR-071", nil), i + 1, NSLocalizedString(@"STR-072", nil)]];
				return;
			}
			}
		case 8:	//History列
			{
			if([elem_list count] < 6){
				[self error_sync:[NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"STR-071", nil), i + 1, NSLocalizedString(@"STR-072", nil)]];
				return;
			}
			
			//履歴のデータを取得
			MyDBHistory* history = [[MyDBHistory alloc] init];
			if([elem_list[0] isEqualToString:@""]){
				history.id_ = self.db_history_next_id_;
				self.db_history_next_id_ ++;
			}
			else{
				history.id_ = [elem_list[0] intValue];
			}
			history.id_ = [elem_list[0] intValue];
			history.year_ = [elem_list[1] intValue];
			history.month_ = [elem_list[2] intValue];
			history.day_ = [elem_list[3] intValue];
			history.category_ = elem_list[4];
			history.val_ = [elem_list[5] intValue];
			if([elem_list count] > 6){
				history.memo_ = elem_list[6];
			}
			else{
				history.memo_ = @"";
			}
			
			[self.db_history_list_ addObject:history];
			
			break;
			}
		default:
			{
			break;
			}
		}
	}
	
	[progress_ setProgress:0.3f];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	//新しいDBを初期化
	[self init_new_db];
}


//新しいDBを初期化
- (void) init_new_db{
	status_label_.text = NSLocalizedString(@"STR-199", nil);
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	//元のDBで初期化
	self.anew_category_list_ = [[NSMutableArray alloc] initWithArray:self.db_category_list_];
	self.new_category_next_id_ = self.db_category_next_id_;
	
	self.anew_history_list_ = [[NSMutableArray alloc] initWithArray:self.db_history_list_];
	self.new_history_next_id_ = self.db_history_next_id_;
	
	self.anew_custom_list_ = [[NSMutableArray alloc] initWithArray:self.db_custom_list_];
	self.new_custom_next_id_ = self.db_custom_next_id_;
	
	//現在のローカルのカテゴリーの並び順を付加する
	int max_index = [g_model_ get_all_category_num];
	for(int i=0; i<[self.anew_category_list_ count]; i++){
		MyDBCategory* new_cat = (self.anew_category_list_)[i];
		
		DBCategory* local_cat = [g_model_ get_category_with_id:new_cat.id_];
		if(local_cat != nil){
			if([local_cat.diff_type isEqualToString:@"del"] == FALSE){
				new_cat.index_ = local_cat.index;
			}
			else{
				//ローカルにないカテゴリは最後尾へ
				new_cat.index_ = max_index;
			}
		}
		else{
			//ローカルにないカテゴリは最後尾へ
			new_cat.index_ = max_index;
		}
	}	
	
	//現在のローカルのカスタム集計方法の並び順と表示非表示を付加する
	max_index = [g_model_ get_all_custom_ana_num];
	for(int i=0; i<[self.anew_custom_list_ count]; i++){
		MyDBCustomAna* new_ana = (self.anew_custom_list_)[i];
		
		DBCustomAna* local_ana = [g_model_ get_custom_ana_with_id:new_ana.id_];
		if(local_ana != nil){
			if([local_ana.diff_type isEqualToString:@"del"] == FALSE){
				new_ana.index_ = local_ana.index;
				new_ana.is_show_ = local_ana.is_show;
			}
			else{
				//ローカルにない集計方法は最後尾へ
				new_ana.index_ = max_index;
				
				new_ana.is_show_ = TRUE;
			}
		}
		else{
			//ローカルにない集計方法は最後尾へ
			new_ana.index_ = max_index;
			
			new_ana.is_show_ = TRUE;
		}
	}	
	
	//コンフリクトを確認
	[self check_conflict];
}


//コンフリクトを確認
- (void) check_conflict{
	[self add_sync_log:@"check_conflict START"];
	status_label_.text = NSLocalizedString(@"STR-200", nil);
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	//■■■　カテゴリのコンフリクトを確認　■■■
	NSMutableArray* conflict_category_list = [[NSMutableArray alloc] init];
	
	//■　追加のコンフリクトしているものとしていないものをリストアップ
	//追加はコンフリクトしない
	NSMutableArray* category_no_conflict_add_list = [[NSMutableArray alloc] initWithArray:[g_model_ get_category_list_with_diff_type:@"add"]];
	
	[self add_sync_log:@"check_conflict2"];
	
	//■　削除のコンフリクトしているものとしていないものをリストアップ
	NSMutableArray* category_no_conflict_del_list = [[NSMutableArray alloc] init];
	
	//削除のコンフリクトの条件：ローカルで削除したカテゴリが、サーバー上では編集されている
	NSArray* local_category_del_list = [g_model_ get_category_list_with_diff_type:@"del"];
	
	[self add_sync_log:@"check_conflict3"];
	
	for(int i=0; i<[local_category_del_list count]; i++){
		[self add_sync_log:@"check_conflict3.0"];
		
		DBCategory* local_cat = local_category_del_list[i];
		[self add_sync_log:[NSString stringWithFormat:@"%@:\n%@", @"check_conflict3.1", local_cat]];
		
		MyDBCategory* db_cat = [self get_db_cat:local_cat.cat_id];
		[self add_sync_log:[NSString stringWithFormat:@"%@:\n%@", @"check_conflict3.2", db_cat]];
		
		if(db_cat != nil){
			if([local_cat.org.name isEqualToString:db_cat.name_] == false){
				[self add_sync_log:@"check_conflict3.3"];
				//コンフリクトしている
				MyConflictCategory* conf_cat = [[MyConflictCategory alloc] init];
				conf_cat.local_ = local_cat;
				conf_cat.db_ = db_cat;
				conf_cat.is_apply_local_ = true;
				[conflict_category_list addObject:conf_cat];				
			}
			else{
				[self add_sync_log:@"check_conflict3.4"];
				[category_no_conflict_del_list addObject:local_cat];
			}
		}
		else{
			[self add_sync_log:@"check_conflict3.5"];
			[category_no_conflict_del_list addObject:local_cat];
		}
	}
	
	[self add_sync_log:@"check_conflict4"];
	
	//■　編集のコンフリクトしているものとしていないものをリストアップ
	NSMutableArray* category_no_conflict_edit_list = [[NSMutableArray alloc] init];
	
	//編集のコンフリクトの条件１：ローカルで編集したカテゴリが、サーバー上でも編集されている
	//編集のコンフリクトの条件２：ローカルで編集したカテゴリが、サーバー上で削除されている
	NSArray* local_category_edit_list = [g_model_ get_category_list_with_diff_type:@"edit"];
	
	[self add_sync_log:@"check_conflict5"];
	
	for(int i=0; i<[local_category_edit_list count]; i++){
		[self add_sync_log:@"check_conflict5.0"];
		
		DBCategory* local_cat = local_category_edit_list[i];
		[self add_sync_log:[NSString stringWithFormat:@"%@:\n%@", @"check_conflict5.1", local_cat]];
		
		MyDBCategory* db_cat = [self get_db_cat:local_cat.cat_id];
		[self add_sync_log:[NSString stringWithFormat:@"%@:\n%@", @"check_conflict5.2", db_cat]];
		
		if(db_cat != nil){
			if([local_cat.org.name isEqualToString:db_cat.name_] == false){
				[self add_sync_log:@"check_conflict5.3"];
				//コンフリクトしている
				MyConflictCategory* conf_cat = [[MyConflictCategory alloc] init];
				conf_cat.local_ = local_cat;
				conf_cat.db_ = db_cat;
				conf_cat.is_apply_local_ = true;
				[conflict_category_list addObject:conf_cat];				
			}
			else{
				[self add_sync_log:@"check_conflict5.4"];
				[category_no_conflict_edit_list addObject:local_cat];
			}
		}
		else{
			[self add_sync_log:@"check_conflict5.5"];
			//コンフリクトしている
			MyConflictCategory* conf_cat = [[MyConflictCategory alloc] init];
			conf_cat.local_ = local_cat;
			conf_cat.db_ = nil;
			conf_cat.is_apply_local_ = true;
			[conflict_category_list addObject:conf_cat];
		}
	}
	
	[self add_sync_log:@"check_conflict6"];
	
	//コンフリクトしていないものは適用
	[self new_db_apply_category_change:category_no_conflict_add_list del:category_no_conflict_del_list edit:category_no_conflict_edit_list];
	
	[self add_sync_log:@"check_conflict7"];
	
	//■■■　カスタム集計方法のコンフリクトを確認　■■■
	NSMutableArray* conflict_custom_list = [[NSMutableArray alloc] init];
	
	//■　追加のコンフリクトしているものとしていないものをリストアップ
	//追加はコンフリクトしない
	NSMutableArray* custom_no_conflict_add_list = [[NSMutableArray alloc] initWithArray:[g_model_ get_custom_ana_list_with_diff_type:@"add"]];
	
	[self add_sync_log:@"check_conflict8"];
	
	//■　削除のコンフリクトしているものとしていないものをリストアップ
	NSMutableArray* custom_no_conflict_del_list = [[NSMutableArray alloc] init];
	
	//削除のコンフリクトの条件：ローカルで削除したカテゴリが、サーバー上では編集されている
	NSArray* local_custom_del_list = [g_model_ get_custom_ana_list_with_diff_type:@"del"];
	
	[self add_sync_log:@"check_conflict9"];
	
	for(int i=0; i<[local_custom_del_list count]; i++){
		[self add_sync_log:@"check_conflict9.0"];
		
		DBCustomAna* local_ana = local_custom_del_list[i];
		[self add_sync_log:[NSString stringWithFormat:@"%@:\n%@", @"check_conflict9.1", local_ana]];
		
		MyDBCustomAna* db_ana = [self get_db_custom:local_ana.ana_id];
		[self add_sync_log:[NSString stringWithFormat:@"%@:\n%@", @"check_conflict9.2", db_ana]];
		
		if(db_ana != nil){
			if([local_ana.org.name isEqualToString:db_ana.name_] == false || 
			   [local_ana.org.unit isEqualToString:db_ana.unit_] == false ||
			   [local_ana.org.formula isEqualToString:db_ana.formula_] == false )
			{
				[self add_sync_log:@"check_conflict9.3"];
				//コンフリクトしている
				MyConflictCustomAna* conf_ana = [[MyConflictCustomAna alloc] init];
				conf_ana.local_ = local_ana;
				conf_ana.db_ = db_ana;
				conf_ana.is_apply_local_ = true;
				[conflict_custom_list addObject:conf_ana];				
			}
			else{
				[self add_sync_log:@"check_conflict9.4"];
				[custom_no_conflict_del_list addObject:local_ana];
			}
		}
		else{
			[self add_sync_log:@"check_conflict9.5"];
			[custom_no_conflict_del_list addObject:local_ana];
		}
	}
	
	[self add_sync_log:@"check_conflict10"];
	
	//■　編集のコンフリクトしているものとしていないものをリストアップ
	NSMutableArray* custom_no_conflict_edit_list = [[NSMutableArray alloc] init];
	
	//編集のコンフリクトの条件１：ローカルで編集したカテゴリが、サーバー上でも編集されている
	//編集のコンフリクトの条件２：ローカルで編集したカテゴリが、サーバー上で削除されている
	NSArray* local_custom_edit_list = [g_model_ get_custom_ana_list_with_diff_type:@"edit"];
	
	[self add_sync_log:@"check_conflict11"];
	
	for(int i=0; i<[local_custom_edit_list count]; i++){
		[self add_sync_log:@"check_conflict11.0"];
		
		DBCustomAna* local_ana = local_custom_edit_list[i];
		[self add_sync_log:[NSString stringWithFormat:@"%@:\n%@", @"check_conflict11.1", local_ana]];
		
		MyDBCustomAna* db_ana = [self get_db_custom:local_ana.ana_id];
		[self add_sync_log:[NSString stringWithFormat:@"%@:\n%@", @"check_conflict11.2", db_ana]];
		
		if(db_ana != nil){
			//NSLog(@"CustomAna\n\"%@\"\n\"%@\"\n\"%@\"\n\"%@\"",local_ana.org.name,db_ana.name_,local_ana.formula_org,db_ana.formula_);
			if([local_ana.org.name isEqualToString:db_ana.name_] == false || 
			   [local_ana.org.unit isEqualToString:db_ana.unit_] == false ||
			   [local_ana.org.formula isEqualToString:db_ana.formula_] == false )
			{
				//コンフリクトしている
				[self add_sync_log:@"check_conflict11.3"];
				MyConflictCustomAna* conf_ana = [[MyConflictCustomAna alloc] init];
				conf_ana.local_ = local_ana;
				conf_ana.db_ = db_ana;
				conf_ana.is_apply_local_ = true;
				[conflict_custom_list addObject:conf_ana];				
			}
			else{
				[self add_sync_log:@"check_conflict11.4"];
				[custom_no_conflict_edit_list addObject:local_ana];
			}
		}
		else{
			[self add_sync_log:@"check_conflict11.5"];
			//コンフリクトしている
			MyConflictCustomAna* conf_ana = [[MyConflictCustomAna alloc] init];
			conf_ana.local_ = local_ana;
			conf_ana.db_ = nil;
			conf_ana.is_apply_local_ = true;
			[conflict_custom_list addObject:conf_ana];
		}
	}
	
	[self add_sync_log:@"check_conflict12"];
	
	//コンフリクトしていないものは適用
	[self new_db_apply_custom_change:custom_no_conflict_add_list del:custom_no_conflict_del_list edit:custom_no_conflict_edit_list];
	
	[self add_sync_log:@"check_conflict13"];
	
	//■■■　履歴のコンフリクトを確認　■■■
	NSMutableArray* conflict_history_list = [[NSMutableArray alloc] init];
	
	//■　追加のコンフリクトしているものとしていないものをリストアップ
	//追加はコンフリクトしない
	NSMutableArray* history_no_conflict_add_list = [[NSMutableArray alloc] initWithArray:[g_model_ get_history_list_with_diff_type:@"add"]];
	
	[self add_sync_log:@"check_conflict14"];
	
	//削除のコンフリクトしているものとしていないものをリストアップ
	NSMutableArray* history_no_conflict_del_list = [[NSMutableArray alloc] init];
	
	//削除のコンフリクトの条件：ローカルで削除した履歴が、サーバー上では編集されている
	NSArray* local_history_del_list = [g_model_ get_history_list_with_diff_type:@"del"];
	
	[self add_sync_log:@"check_conflict15"];
	
	for(int i=0; i<[local_history_del_list count]; i++){
		[self add_sync_log:@"check_conflict15.0"];
		
		DBHistory* local_his = local_history_del_list[i];
		[self add_sync_log:[NSString stringWithFormat:@"%@:\n%@", @"check_conflict15.1", local_his]];
		
		MyDBHistory* db_his = [self get_db_his:local_his.his_id];
		[self add_sync_log:[NSString stringWithFormat:@"%@:\n%@", @"check_conflict15.2", db_his]];
		
		if(db_his != nil){
			if([local_his.org.category isEqualToString:db_his.category_] == false ||
			   [local_his.org.memo isEqualToString:db_his.memo_] == false ||
			   local_his.org.year != db_his.year_ ||
			   local_his.org.month != db_his.month_ ||
			   local_his.org.day != db_his.day_ ||
			   local_his.org.val != db_his.val_){
				[self add_sync_log:@"check_conflict15.3"];
				//コンフリクトしている
				MyConflictHistory* conf_his = [[MyConflictHistory alloc] init];
				conf_his.local_ = local_his;
				conf_his.db_ = db_his;
				conf_his.is_apply_local_ = true;
				[conflict_history_list addObject:conf_his];				
			}
			else{
				[self add_sync_log:@"check_conflict15.4"];
				[history_no_conflict_del_list addObject:local_his];
			}
		}
		else{
			[self add_sync_log:@"check_conflict15.5"];
			[history_no_conflict_del_list addObject:local_his];
		}
	}
	
	[self add_sync_log:@"check_conflict16"];
	
	//編集のコンフリクトしているものとしていないものをリストアップ
	NSMutableArray* history_no_conflict_edit_list = [[NSMutableArray alloc] init];
	
	//編集のコンフリクトの条件１：ローカルで編集した履歴が、サーバー上でも編集されている
	//編集のコンフリクトの条件２：ローカルで編集した履歴が、サーバー上で削除されている
	NSArray* local_history_edit_list = [g_model_ get_history_list_with_diff_type:@"edit"];
	
	[self add_sync_log:@"check_conflict17"];
	
	for(int i=0; i<[local_history_edit_list count]; i++){
		[self add_sync_log:@"check_conflict17.0"];
		
		DBHistory* local_his = local_history_edit_list[i];
		[self add_sync_log:[NSString stringWithFormat:@"%@:\n%@", @"check_conflict17.1", local_his]];
		
		MyDBHistory* db_his = [self get_db_his:local_his.his_id];
		[self add_sync_log:[NSString stringWithFormat:@"%@:\n%@", @"check_conflict17.2", db_his]];
		
		if(db_his != nil){
			if([local_his.org.category isEqualToString:db_his.category_] == false ||
			   [local_his.org.memo isEqualToString:db_his.memo_] == false ||
			   local_his.org.year != db_his.year_ ||
			   local_his.org.month != db_his.month_ ||
			   local_his.org.day != db_his.day_ ||
			   local_his.org.val != db_his.val_){
				[self add_sync_log:@"check_conflict17.3"];
				//コンフリクトしている
				MyConflictHistory* conf_his = [[MyConflictHistory alloc] init];
				conf_his.local_ = local_his;
				conf_his.db_ = db_his;
				conf_his.is_apply_local_ = true;
				[conflict_history_list addObject:conf_his];		
			}
			else{
				[self add_sync_log:@"check_conflict17.4"];
				[history_no_conflict_edit_list addObject:local_his];
			}
		}
		else{
			[self add_sync_log:@"check_conflict17.5"];
			//コンフリクトしている
			MyConflictHistory* conf_his = [[MyConflictHistory alloc] init];
			conf_his.local_ = local_his;
			conf_his.db_ = nil;
			conf_his.is_apply_local_ = true;
			[conflict_history_list addObject:conf_his];
		}
	}
	
	[self add_sync_log:@"check_conflict18"];
	
	//コンフリクトしていないものは適用
	[self new_db_apply_history_change:history_no_conflict_add_list del:history_no_conflict_del_list edit:history_no_conflict_edit_list];
	
	[self add_sync_log:@"check_conflict19"];
	
	[progress_ setProgress:0.325f];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	//コンフリクトがある場合
	if([conflict_category_list count] > 0 || [conflict_history_list count] > 0 || [conflict_custom_list count] > 0){
		[self add_sync_log:@"check_conflict20"];
		
		//コンフリクトをどうするか確認
		UIViewController* next_view = [[Sync_Conflict alloc] initWithConflict:conflict_category_list history:conflict_history_list custom:conflict_custom_list];
		[self.navigationController pushViewController:next_view animated:YES];
		
		[self add_sync_log:@"check_conflict END"];
	}
	//コンフリクトがない場合
	else{
		[self add_sync_log:@"check_conflict END"];
		//ファイル一覧を再取得
		[self req_get_doc_list2];
	}
}


//新しいDBにローカルでのカテゴリの修正を適用
- (void) new_db_apply_category_change:(NSArray*)add_list del:(NSArray*)del_list edit:(NSArray*)edit_list{
	//ローカルのAdd分の反映
	if(add_list != nil){
		for(int i=0; i<[add_list count]; i++){
			DBCategory* local_cat = add_list[i];
			
			MyDBCategory* new_cat = [[MyDBCategory alloc] init];
			new_cat.id_ = self.new_category_next_id_;
			new_cat.name_ = local_cat.cur.name;
			new_cat.index_ = local_cat.index;
			[anew_category_list_ addObject:new_cat];
			
			self.new_category_next_id_ ++;
		}		
	}
		
	//ローカルのDel分の反映
	if(del_list != nil){
		for(int i=0; i<[del_list count]; i++){
			DBCategory* local_cat = del_list[i];
			
			MyDBCategory* del_cat = [self get_new_cat:local_cat.cat_id];
			[self.anew_category_list_ removeObject:del_cat];
		}
	}
	
	//ローカルのEdit分の反映
	if(edit_list != nil){
		for(int i=0; i<[edit_list count]; i++){
			DBCategory* local_cat = edit_list[i];
			
			//古いの削除
			MyDBCategory* del_cat = [self get_new_cat:local_cat.cat_id];
			[self.anew_category_list_ removeObject:del_cat];
			
			//新しいの追加
			MyDBCategory* new_cat = [[MyDBCategory alloc] init];
			new_cat.id_ = local_cat.cat_id;
			new_cat.name_ = local_cat.cur.name;
			new_cat.index_ = local_cat.index;
			[anew_category_list_ addObject:new_cat];
		}	
	}
}


//新しいDBにローカルでのカスタム集計方法の修正を適用
- (void) new_db_apply_custom_change:(NSArray*)add_list del:(NSArray*)del_list edit:(NSArray*)edit_list{
	//ローカルのAdd分の反映
	if(add_list != nil){
		for(int i=0; i<[add_list count]; i++){
			DBCustomAna* local_ana = add_list[i];
			
			MyDBCustomAna* new_ana = [[MyDBCustomAna alloc] init];
			new_ana.id_ = self.new_custom_next_id_;
			new_ana.name_ = local_ana.cur.name;
			new_ana.formula_ = local_ana.cur.formula;
			new_ana.unit_ = local_ana.cur.unit;
			new_ana.is_show_ = local_ana.is_show;
			new_ana.index_ = local_ana.index;
			[anew_custom_list_ addObject:new_ana];
			
			self.new_custom_next_id_ ++;
		}		
	}
	
	//ローカルのDel分の反映
	if(del_list != nil){
		for(int i=0; i<[del_list count]; i++){
			DBCustomAna* local_ana = del_list[i];
			
			MyDBCustomAna* del_ana = [self get_new_custom:local_ana.ana_id];
			[self.anew_custom_list_ removeObject:del_ana];
		}
	}
	
	//ローカルのEdit分の反映
	if(edit_list != nil){
		for(int i=0; i<[edit_list count]; i++){
			DBCustomAna* local_ana = edit_list[i];
			
			//古いの削除
			MyDBCustomAna* del_ana = [self get_new_custom:local_ana.ana_id];
			[self.anew_custom_list_ removeObject:del_ana];
			
			//新しいの追加
			MyDBCustomAna* new_ana = [[MyDBCustomAna alloc] init];
			new_ana.id_ = local_ana.ana_id;
			new_ana.name_ = local_ana.cur.name;
			new_ana.formula_ = local_ana.cur.formula;
			new_ana.unit_ = local_ana.cur.unit;
			new_ana.is_show_ = local_ana.is_show;
			new_ana.index_ = local_ana.index;
			[anew_custom_list_ addObject:new_ana];
		}	
	}
}


//新しいDBにローカルでの履歴の修正を適用
- (void) new_db_apply_history_change:(NSArray*) add_list del:(NSArray*) del_list edit:(NSArray*)edit_list{
	//ローカルのAdd分の反映
	if(add_list != nil){
		for(int i=0; i<[add_list count]; i++){
			DBHistory* local_his = add_list[i];
			
			MyDBHistory* new_his = [[MyDBHistory alloc] init];
			new_his.id_ = self.new_history_next_id_;
			new_his.year_ = local_his.cur.year;
			new_his.month_ = local_his.cur.month;
			new_his.day_ = local_his.cur.day;
			new_his.category_ = local_his.cur.category;
			new_his.val_ = local_his.cur.val;
			new_his.memo_ = local_his.cur.memo;		
			[self.anew_history_list_ addObject:new_his];
			
			self.new_history_next_id_ ++;
		}		
	}
	
	//ローカルのDel分の反映
	if(del_list != nil){
		for(int i=0; i<[del_list count]; i++){
			DBHistory* local_his = del_list[i];
			
			MyDBHistory* del_his = [self get_new_his:local_his.his_id];
			[self.anew_history_list_ removeObject:del_his];
		}
	}
	
	//ローカルのEdit分の反映
	if(edit_list != nil){
		for(int i=0; i<[edit_list count]; i++){
			DBHistory* local_his = edit_list[i];
			
			//古いの削除
			MyDBHistory* del_his = [self get_new_his:local_his.his_id];
			[self.anew_history_list_ removeObject:del_his];
			
			//新しいの追加
			MyDBHistory* new_his = [[MyDBHistory alloc] init];			
			new_his.id_ = self.new_history_next_id_;
			new_his.year_ = local_his.cur.year;
			new_his.month_ = local_his.cur.month;
			new_his.day_ = local_his.cur.day;
			new_his.category_ = local_his.cur.category;
			new_his.val_ = local_his.cur.val;
			new_his.memo_ = local_his.cur.memo;
			[self.anew_history_list_ addObject:new_his];
		}	
	}
}


//新しいDBに適用するコンフリクトを適用
- (void) new_db_apply_conflict:(NSArray*)conflict_category_list history:(NSArray*)conflict_history_list custom:(NSArray*)conflict_custom_list{
	[progress_ setHidden:FALSE];
	[status_label_ setHidden:FALSE];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	//■■■　カテゴリー　■■■
	NSMutableArray* category_apply_del_list = [[NSMutableArray alloc] init];
	NSMutableArray* category_apply_edit_list = [[NSMutableArray alloc] init];
	
	for(int i=0; i<[conflict_category_list count]; i++){
		MyConflictCategory* conflict = conflict_category_list[i];
		
		if(conflict.is_apply_local_ == TRUE){
			if([conflict.local_.diff_type isEqualToString:@"del"]){
				[category_apply_del_list addObject:conflict.local_];
			}
			else{
				[category_apply_edit_list addObject:conflict.local_];
			}
		}
	}
	
	//コンフリクトを適用
	[self new_db_apply_category_change:nil del:category_apply_del_list edit:category_apply_edit_list];
	
	
	//■■■　カスタム集計方法　■■■
	NSMutableArray* custom_apply_del_list = [[NSMutableArray alloc] init];
	NSMutableArray* custom_apply_edit_list = [[NSMutableArray alloc] init];
	
	for(int i=0; i<[conflict_custom_list count]; i++){
		MyConflictCustomAna* conflict = conflict_custom_list[i];
		
		if(conflict.is_apply_local_ == TRUE){
			if([conflict.local_.diff_type isEqualToString:@"del"]){
				[custom_apply_del_list addObject:conflict.local_];
			}
			else{
				[custom_apply_edit_list addObject:conflict.local_];
			}
		}
	}
	
	//コンフリクトを適用
	[self new_db_apply_custom_change:nil del:custom_apply_del_list edit:custom_apply_edit_list];
	
	
	//■■■　履歴　■■■
	NSMutableArray* history_apply_del_list = [[NSMutableArray alloc] init];
	NSMutableArray* history_apply_edit_list = [[NSMutableArray alloc] init];
	
	for(int i=0; i<[conflict_history_list count]; i++){
		MyConflictHistory* conflict = conflict_history_list[i];
		
		if(conflict.is_apply_local_ == TRUE){
			if([conflict.local_.diff_type isEqualToString:@"del"]){
				[history_apply_del_list addObject:conflict.local_];
			}
			else{
				[history_apply_edit_list addObject:conflict.local_];
			}
		}
	}
	
	//コンフリクトを適用
	[self new_db_apply_history_change:nil del:history_apply_del_list edit:history_apply_edit_list];
	
	
	[progress_ setProgress:0.25f];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	//ファイル一覧を再取得
	[self req_get_doc_list2];
}


//ファイル一覧再取得
- (void) req_get_doc_list2{	
	status_label_.text = NSLocalizedString(@"STR-065", nil);
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	NSURL *feedURL = [GDataServiceGoogleDocs docsFeedURL];
	
	GDataQueryDocs *query = [GDataQueryDocs documentQueryWithFeedURL:feedURL];
	[query setMaxResults:1000];
	[query setShouldShowFolders:NO];
	
	self.ticket_get_doc_list = [self.service_docs fetchFeedWithQuery:query delegate:self didFinishSelector:@selector(ack_get_doc_list2:finishedWithFeed:error:)];
	if(self.ticket_get_doc_list == nil){
		[self error_sync:NSLocalizedString(@"STR-066", nil)];
	}
}

- (void) ack_get_doc_list2:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedDocList *)feed error:(NSError *)error{
	NSLog(@"ack_get_doc_list2 feed: %@ \nerror:%@", feed, error);
	self.ticket_get_doc_list = nil;
	
	if(error != nil){
		[self error_sync:NSLocalizedString(@"STR-066", nil)];
		return;
	}
	
	[progress_ setProgress:0.45f];
	
	//同じスプレッドシートがあるかチェック
	NSArray* doc_list = [feed entries];
	
	for(int i=0; i<[doc_list count]; i ++){
		GDataEntryDocBase* doc = doc_list[i];
		NSString* identifier = [doc identifier];
		GDataDateTime* lastupdate_date = [doc updatedDate];
		NSLog(@"id:%@, date:%@, ETag:%@", identifier, lastupdate_date, doc.ETag);
		
		if([identifier isEqualToString:self.org_db_doc_id_] == TRUE){
			if([lastupdate_date isEqual:self.org_db_doc_lastupdate_date_] == TRUE){
				//サーバ上のDB更新
				[self req_update_db:doc];
				return;
			}
			else{
				//誰かにDBを編集された
				[self error_sync:NSLocalizedString(@"STR-073", nil)];
				return;
			}	
		}
	}
	
	//誰かにDBを削除された
	[self error_sync:NSLocalizedString(@"STR-073", nil)];
}


//サーバ上のDBを更新
- (void) req_update_db:(GDataEntryDocBase*) db_doc{
	status_label_.text = NSLocalizedString(@"STR-074", nil);
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	[start_button_ setEnabled:FALSE];
	
	NSData* db_data = [self create_new_db_data];
	
	[db_doc setTitleWithString:self.db_name_];
	[db_doc setUploadSlug:self.db_name_];
	[db_doc setUploadData:db_data];
	[db_doc setUploadMIMEType:@"text/csv"];
	
	NSLog(@"eTag:%@", db_doc.ETag);
	
/*	GDataQueryDocs *query = [GDataQueryDocs queryWithFeedURL:[[db_doc editLink] URL]]; 
	[query setShouldCreateNewRevision:YES]; 
	self.ticket_update_db = [self.service_docs fetchEntryByUpdatingEntry:db_doc 
														forEntryURL:[query URL] 
														   delegate:self 
												  didFinishSelector:@selector(ack_update_db:finishedWithEntry:error:)]; 
*/	
	self.ticket_update_db = [self.service_docs fetchEntryByUpdatingEntry:db_doc delegate:self didFinishSelector:@selector(ack_update_db:finishedWithEntry:error:)];
	if(self.ticket_update_db == nil){
		[self error_sync:NSLocalizedString(@"STR-075", nil)];
	}
}

- (void) ack_update_db:(GDataServiceTicket *)ticket finishedWithEntry:(GDataEntryStandardDoc *)entry error:(NSError *)error{
	NSLog(@"ack_update_db entry: %@ \nerror:%@", entry, error);
	self.ticket_update_db = nil;
	
	if(error != nil){
		[self req_get_doc_list2];
		
		//[self error_sync:NSLocalizedString(@"STR-075", nil)];
		return;
	}
	
	[progress_ setProgress:0.55f];
	
	//ローカルのDBをを更新
	[self update_local_db];
}


//新しいDBをアップロード
- (void) req_upload_new_db{
	status_label_.text = NSLocalizedString(@"STR-076", nil);
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	[start_button_ setEnabled:FALSE];
	
	NSData* db_data = [self create_new_db_data];
	
	GDataEntryStandardDoc* newEntry = [GDataEntryStandardDoc documentEntry];
	[newEntry setTitleWithString:self.db_name_];
	[newEntry setUploadSlug:self.db_name_];
	[newEntry setUploadData:db_data];
	[newEntry setUploadMIMEType:@"text/csv"];
		
	NSURL *uploadURL = [GDataServiceGoogleDocs docsUploadURL];
	
	self.ticket_upload_new_db = [self.service_docs fetchEntryByInsertingEntry:newEntry forFeedURL:uploadURL delegate:self didFinishSelector:@selector(ack_upload_new_db:finishedWithEntry:error:)];
	if(self.ticket_upload_new_db == nil){
		[self error_sync:NSLocalizedString(@"STR-077", nil)];
	}
}

- (void) ack_upload_new_db:(GDataServiceTicket *)ticket finishedWithEntry:(GDataEntryStandardDoc *)entry error:(NSError *)error{
	NSLog(@"ack_upload_new_db entry: %@ \nerror:%@", entry, error);
	self.ticket_upload_new_db = nil;
	
	if(error != nil){
		[self error_sync:NSLocalizedString(@"STR-077", nil)];
		return;
	}
	
	[progress_ setProgress:0.55f];
	
	//ローカルのDBをを更新
	[self update_local_db];
}


//新しいDBのデータを作成
- (NSData*) create_new_db_data{
	//カテゴリ一覧をID順にソート
	[self.anew_category_list_ sortUsingSelector:@selector(compare:)];
	
	//履歴一覧を日付順にソート
	[self.anew_history_list_ sortUsingSelector:@selector(compare:)];
	
	//DBファイルを作成
	NSMutableString* db_text = [NSMutableString stringWithString:@""];
	
	[db_text appendFormat:@"%@,%@,%d\n", NSLocalizedString(@"STR-113", nil), NSLocalizedString(@"STR-114", nil), self.new_category_next_id_];
	[db_text appendFormat:@"%@,%@\n", NSLocalizedString(@"STR-115", nil), NSLocalizedString(@"STR-116", nil)];
	
	for(int i=0; i<[self.anew_category_list_ count]; i++){
		MyDBCategory* cat = (self.anew_category_list_)[i];
		[db_text appendFormat:@"%d,%@\n",cat.id_, cat.name_];
	}
	
	[db_text appendFormat:@"%@,%@,%d\n", NSLocalizedString(@"STR-117", nil), NSLocalizedString(@"STR-114", nil), self.new_custom_next_id_];
	[db_text appendFormat:@"%@,%@,%@,%@\n", NSLocalizedString(@"STR-115", nil), NSLocalizedString(@"STR-118", nil), NSLocalizedString(@"STR-119", nil), NSLocalizedString(@"STR-120", nil)];
	
	for(int i=0; i<[self.anew_custom_list_ count]; i++){
		MyDBCustomAna* ana = (self.anew_custom_list_)[i];
		[db_text appendFormat:@"%d,%@,%@,%@\n",ana.id_, ana.name_, ana.formula_, ana.unit_];
	}
	
	[db_text appendFormat:@"%@,%@,%d\n", NSLocalizedString(@"STR-121", nil), NSLocalizedString(@"STR-114", nil), self.new_history_next_id_];
	[db_text appendFormat:@"%@,%@,%@,%@,%@,%@,%@\n", NSLocalizedString(@"STR-115", nil), NSLocalizedString(@"STR-122", nil), NSLocalizedString(@"STR-123", nil), NSLocalizedString(@"STR-124", nil), NSLocalizedString(@"STR-125", nil), NSLocalizedString(@"STR-126", nil), NSLocalizedString(@"STR-127", nil)];
	
	for(int i=0; i<[self.anew_history_list_ count]; i++){
		MyDBHistory* history = (self.anew_history_list_)[i];
		[db_text appendFormat:@"%d,%d,%d,%d,%@,%d,%@\n",history.id_, history.year_, history.month_, history.day_, history.category_, history.val_, history.memo_];
	}
	
	//NSLog(@"New DB\n%@", db_text);
	
	//データ化する
	NSData* db_data = [db_text dataUsingEncoding:NSUTF8StringEncoding];
	
	return db_data;
}


//ローカルのDBを更新
- (void) update_local_db{
	status_label_.text = NSLocalizedString(@"STR-078", nil);
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	//■■■カテゴリの更新 ■■■
	//データベースを全削除
	[g_model_ del_all_category_actuary];
	
	[progress_ setProgress:0.555f];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	//新しくカテゴリを追加
	for(int i=0; i<[self.anew_category_list_ count]; i++){
		MyDBCategory* cat = (self.anew_category_list_)[i];
		
		[g_model_ add_category_actuary:cat.name_ cat_id:cat.id_ index:cat.index_];
		
		[progress_ setProgress:0.555f + 0.02f * i / [self.anew_category_list_ count]];
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	}
	
	//カテゴリの並び順を設定
	NSArray* new_local_category_list = [g_model_ get_show_category_list];
	for(int i=0; i<[new_local_category_list count]; i++){
		DBCategory* cat = new_local_category_list[i];
		
		cat.index = i;
	}
	[g_model_ save_model];
	
	//TMP IDをリセット
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	[settings setInteger:-1 forKey:@"NEXT_TMP_CAT_ID"];
	
	[progress_ setProgress:0.575f];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	
	//■■■カスタム集計方法の更新 ■■■
	//データベースを全削除
	[g_model_ del_all_custom_ana_actuary];
	
	[progress_ setProgress:0.58f];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	//新しくカスタム集計方法を追加
	for(int i=0; i<[self.anew_custom_list_ count]; i++){
		MyDBCustomAna* ana = (self.anew_custom_list_)[i];
		
		[g_model_ add_custom_ana_actuary:ana.name_ formula:ana.formula_ unit:ana.unit_ is_show:ana.is_show_ ana_id:ana.id_ index:ana.index_];
		
		[progress_ setProgress:0.58f + 0.02f * i / [self.anew_custom_list_ count]];
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	}
	
	//カスタム集計方法の並び順を設定
	NSArray* new_local_custom_list = [g_model_ get_show_custom_ana_list];
	for(int i=0; i<[new_local_custom_list count]; i++){
		DBCustomAna* ana = new_local_custom_list[i];
		ana.index = i;
	}
	[g_model_ save_model];
	
	//TMP IDをリセット
	[settings setInteger:-1 forKey:@"NEXT_TMP_ANA_ID"];
	
	[progress_ setProgress:0.6f];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	
	//■■■ 履歴の更新 ■■■	
	//データベースを全削除
	[g_model_ del_all_history_actuary];
	
	[progress_ setProgress:0.65f];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	//新しくカテゴリを追加
	for(int i=0; i<[self.anew_history_list_ count]; i++){
		MyDBHistory* his = (self.anew_history_list_)[i];
		
		[g_model_ add_history_actuary:his.id_ year:his.year_ month:his.month_ day:his.day_ category:his.category_ val:his.val_ memo:his.memo_];
		
		[progress_ setProgress:0.65f + 0.35f * i / [self.anew_history_list_ count]];
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	}
	
	//TMP IDをリセット
	[settings setInteger:-1 forKey:@"NEXT_TMP_HIS_ID"];	
	
	[progress_ setProgress:1.0f];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	//同期完了
	UIAlertView* alart = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STR-079", nil) 
													 message:@"" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:NSLocalizedString(@"STR-006", nil), nil];
	
	[alart show];
	[progress_ setHidden:TRUE];
	[status_label_ setHidden:TRUE];
	[start_button_ setTitle:NSLocalizedString(@"STR-055", nil) forState:UIControlStateNormal];
	//[start_button_ setTintColor:[UIColor blueColor]];
	[start_button_ setValue:[UIColor blueColor] forKey:@"tintColor"];
	[start_button_ setEnabled:TRUE];
	self.is_syncing_ = FALSE;
	table_view_.allowsSelection = TRUE;
	[table_view_ reloadData];
	
	//タブバーをEnableに
	self.tabBarController.tabBar.userInteractionEnabled = YES;
}


//指定したIDのDBのカテゴリを取得
- (MyDBCategory*) get_db_cat:(NSInteger) cat_id{
	for(int i=0; i<[self.db_category_list_ count]; i++){
		MyDBCategory* cat = (self.db_category_list_)[i];
		
		if(cat.id_ == cat_id){
			return cat;
		}
	}
	
	return nil;
}

//指定したIDのNewDBのカテゴリを取得
- (MyDBCategory*) get_new_cat:(NSInteger) cat_id{
	for(int i=0; i<[self.anew_category_list_ count]; i++){
		MyDBCategory* cat = (self.anew_category_list_)[i];
		
		if(cat.id_ == cat_id){
			return cat;
		}
	}
	
	return nil;
}


//指定したIDのDBの履歴を取得
- (MyDBHistory*) get_db_his:(NSInteger) his_id{
	for(int i=0; i<[self.db_history_list_ count]; i++){
		MyDBHistory* his = (self.db_history_list_)[i];
		
		if(his.id_ == his_id){
			return his;
		}
	}
	
	return nil;
}

//指定したIDのNewDBの履歴を取得
- (MyDBHistory*) get_new_his:(NSInteger) his_id{
	for(int i=0; i<[self.db_history_list_ count]; i++){
		MyDBHistory* his = (self.db_history_list_)[i];
		
		if(his.id_ == his_id){
			return his;
		}
	}
	
	return nil;
}

//指定したIDのDBのカスタム集計を取得
- (MyDBCustomAna*) get_db_custom:(NSInteger) ana_id{
	for(int i=0; i<[self.db_custom_list_ count]; i++){
		MyDBCustomAna* custom = (self.db_custom_list_)[i];
		
		if(custom.id_ == ana_id){
			return custom;
		}
	}
	
	return nil;
}

//指定したIDのNewDBのカスタム集計を取得
- (MyDBCustomAna*) get_new_custom:(NSInteger) ana_id{
	for(int i=0; i<[self.anew_custom_list_ count]; i++){
		MyDBCustomAna* custom = (self.anew_custom_list_)[i];
		
		if(custom.id_ == ana_id){
			return custom;
		}
	}
	
	return nil;
}




//エラー発生
- (void) error_sync:(NSString*)err_meg{
	[self cancel_sync];
	
	UIAlertView* alart = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STR-080", nil) 
													 message:err_meg 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:NSLocalizedString(@"STR-081", nil), nil];
	
	[alart show];
}


//中止
- (void) cancel_sync{
	if(is_syncing_ == false) return;
	
	if(self.ticket_authenticate_service != nil){
		[self.ticket_authenticate_service cancelTicket];
		self.ticket_authenticate_service = nil;
	}
	if(self.ticket_get_doc_list != nil){
		[self.ticket_get_doc_list cancelTicket];
		self.ticket_get_doc_list = nil;
	}
	if(self.ticket_update_db != nil){
		[self.ticket_update_db cancelTicket];
		self.ticket_update_db = nil;
	}
	if(self.ticket_upload_new_db != nil){
		[self.ticket_upload_new_db cancelTicket];
		self.ticket_upload_new_db = nil;
	}
	if(self.db_doc_fetcher != nil){
		[self.db_doc_fetcher stopFetching];
		self.db_doc_fetcher = nil;
	}
	
	[progress_ setHidden:TRUE];
	[status_label_ setHidden:TRUE];
	[start_button_ setTitle:NSLocalizedString(@"STR-055", nil) forState:UIControlStateNormal];
	//[start_button_ setTintColor:[UIColor blueColor]];
	[start_button_ setValue:[UIColor blueColor] forKey:@"tintColor"];
	[start_button_ setEnabled:TRUE];
	self.is_syncing_ = FALSE;
	table_view_.allowsSelection = TRUE;
	[table_view_ reloadData];
	
	//タブバーをEnableに
	self.tabBarController.tabBar.userInteractionEnabled = YES;
}




@end
