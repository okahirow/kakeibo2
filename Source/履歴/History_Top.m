//
//  History_Top.m
//  kakeibo2
//
//  Created by hiro on 2013/04/21.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "History_Top.h"
#import "HistoryList_Top.h"
#import "GoogleCalender.h"
#import "MyModel.h"
#import "DBEvent.h"
#import "CommonAPI.h"
#import "EditHistory.h"

@interface History_Top ()

@property(strong) IBOutlet UITableView* table_view;

@property(strong) NSArray* history_normal_list;
@property(strong) NSArray* history_recurrence_list;
@property(strong) NSArray* history_exception_list;
@property(strong) NSArray* history_show_list;

- (IBAction)sumc_db_event:(id)sender;

@end

@implementation History_Top

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.history_recurrence_list = @[];
	self.history_exception_list = @[];
	self.history_normal_list = @[];
	self.history_show_list = @[];
	
	//DB変更の監視
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(update_list) name:@"DB_UPDATE" object:nil];
	
	[self update_list];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//セクションの数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

//セルの数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if(section == 0){
		return [self.history_recurrence_list count];
	}
	else if(section == 1){
		return [self.history_exception_list count];
	}
	else if(section == 2){
		return [self.history_normal_list count];
	}
	else{
		return [self.history_show_list count];
	}
}

//セルの高さ
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section == 0){
		return 550;
	}
	else if(indexPath.section == 1){
		return 400;
	}
	else if(indexPath.section == 2){
		return 400;
	}
	else{
		return 150;
	}
}

//セクション名
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 0){
		return @"繰り返し";
	}
	else if(section == 1){
		return @"繰り返しの例外";
	}
	else if(section == 2){
		return @"通常イベント";
	}
	else{
		return @"イベントのインスタンス";
	}
}

//セル作成
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
	
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
							
	if(indexPath.section == 0){
		DBEvent_Recurrence* event = self.history_recurrence_list[indexPath.row];
		
		cell.textLabel.text = [NSString stringWithFormat:@"%@:%d", event.category, event.val];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"date:%@\nperson:%@\nmemo:%@\nevent_status:%@\nsync_status:%@\nid:%@\nlast_update:%@\netag:%@\nlink:%@\nrecu:%@", [CommonAPI get_day_string:event.date], event.person, event.memo, event.event_status, event.sync_status, event.identifier, [outputFormatter stringFromDate:event.last_update], event.eTag, event.html_link, event.recurrence];
	}
	else if(indexPath.section == 1){
		DBEvent_Exception* event = self.history_exception_list[indexPath.row];
		
		cell.textLabel.text = [NSString stringWithFormat:@"%@:%d", event.category, event.val];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"date:%@\norg_date:%@\nperson:%@\nmemo:%@\nevent_status:%@\nsync_status:%@\nid:%@\nlast_update:%@\netag:%@\norg:%@\nlink:%@", [CommonAPI get_day_string:event.date], [CommonAPI get_day_string:event.org_date], event.person, event.memo, event.event_status, event.sync_status, event.identifier, [outputFormatter stringFromDate:event.last_update], event.eTag, event.org_event.identifier, event.html_link];
	}
	else if(indexPath.section == 2){
		DBEvent_Normal* event = self.history_normal_list[indexPath.row];
		
		cell.textLabel.text = [NSString stringWithFormat:@"%@:%d", event.category, event.val];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"date:%@\nperson:%@\nmemo:%@\nevent_status:%@\nsync_status:%@\nid:%@\nlast_update:%@\netag:%@\nlink:%@", [CommonAPI get_day_string:event.date], event.person, event.memo, event.event_status, event.sync_status, event.identifier, [outputFormatter stringFromDate:event.last_update], event.eTag, event.html_link];
	}
	else{
		Event* event = self.history_show_list[indexPath.row];
		
		cell.textLabel.text = [NSString stringWithFormat:@"%@:%d", event.db_event.category, event.db_event.val];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"date:%@\nperson:%@\nmemo:%@\nevent_status:%@\nsync_status:%@\nid:%@", [CommonAPI get_day_string:event.date], event.db_event.person, event.db_event.memo, event.db_event.event_status, event.db_event.sync_status, event.db_event.identifier];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	
	cell.detailTextLabel.numberOfLines = 30;
	return cell;
}

- (void) update_list{
	self.history_normal_list = [g_model_ get_all_event_normal_list];
	self.history_recurrence_list = [g_model_ get_all_event_recurrence_list];
	self.history_exception_list = [g_model_ get_all_event_exception_list];
	self.history_show_list = [g_model_ event_instance_list_with_start:[CommonAPI get_date_year:2013 month:5 day:1] end:[CommonAPI get_date_year:2013 month:5 day:31]];
	
	[self.table_view reloadData];
}

- (void) did_get_history_list:(NSArray*)history_list{
	self.history_normal_list = [g_model_ get_all_event_normal_list];
	self.history_recurrence_list = [g_model_ get_all_event_recurrence_list];
	self.history_exception_list = [g_model_ get_all_event_exception_list];
	self.history_show_list = [g_model_ event_instance_list_with_start:[CommonAPI get_date_year:2013 month:5 day:1] end:[CommonAPI get_date_year:2013 month:5 day:31]];
	
	[self.table_view reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //GoogleCalender* cal = [GoogleCalender shared_obj];
	//[cal edit_history:self.history_list[indexPath.row]];
}

- (IBAction)sumc_db_event:(id)sender{
	GoogleCalender* cal = [GoogleCalender shared_obj];
	[cal sync_db];
}

//詳細表示
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	if(tableView.isEditing == NO){
		if(indexPath.section == 3){
			Event* event = self.history_show_list[indexPath.row];
			
			EditHistory* controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"EditHistory"];
			[controller setup_with_event:event];
			
			[self.navigationController pushViewController:controller animated:YES];
		}
	}
}

@end
