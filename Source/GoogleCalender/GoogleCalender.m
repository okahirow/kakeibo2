//
//  GoogleCalender.m
//  kakeibo2
//
//  Created by hiro on 2013/04/24.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "GoogleCalender.h"
#import "CommonAPI.h"
#import "MyModel.h"

@interface GoogleCalender (){
	GDataServiceGoogleCalendar* _service;
	GDataEntryCalendar* _target_calener;
	NSDate* _last_sync_date;
	NSDate* _sync_start_date;
	
	NSMutableArray* _new_event_list;
	NSMutableArray* _new_recurrence_event_list;
	NSMutableArray* _edited_event_list;
	NSMutableArray* _deleted_event_list;
	
	NSMutableArray* _tmp_added_db_event;
	NSMutableArray* _tmp_edited_db_event;
	NSMutableArray* _tmp_deleted_db_event;
	
	NSManagedObjectContext* _context;
	
	GDataServiceTicket* _ticket;
}


@end

@implementation GoogleCalender

static GoogleCalender* google_calender = nil;

+ (GoogleCalender*) shared_obj{
	static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        google_calender = [[GoogleCalender alloc] init];
    });
    return google_calender;
}

- (id)init{
    self = [super init];
    if (self) {
		_target_calener = nil;
		
        [self init_service];
    }
    return self;
}

//サービスを初期化
- (void) init_service{
	NSLog(@"%s", __func__);
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	
	NSString* usr_name = @"oka.hirow.apple@gmail.com";
	NSString* usr_pass = @"rirra9ma";
	//NSString* usr_name = [settings stringForKey:@"USR_NAME"];
	//NSString* usr_pass = [settings stringForKey:@"USR_PASS"];
	
	_service = [[GDataServiceGoogleCalendar alloc] init];
	[_service setUserAgent:@"com.okahirow.app.Kakeibo2"];
	[_service setShouldCacheDatedData:NO];
	[_service setServiceShouldFollowNextLinks:NO];
	[_service setUserCredentialsWithUsername:usr_name password:usr_pass];
}

//DBを更新
- (void) sync_db{
	_context = [[NSManagedObjectContext alloc] init];
	[_context setPersistentStoreCoordinator:g_model_.persistentStoreCoordinator];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	NSObject* data = [settings objectForKey:@"LAST_SYNC_DATE"];
	if(data == [NSNull null]){
		_last_sync_date = nil;
	}
	else{
		_last_sync_date = (NSDate*)data;
	}
	
	_sync_start_date = [NSDate date];
	
	[self get_calender_list];
}

//カレンダーリストを取得
- (void) get_calender_list{
	NSLog(@"%s", __func__);
	
	NSURL *feedURL = [NSURL URLWithString:kGDataGoogleCalendarDefaultOwnCalendarsFeed];
	_ticket = [_service fetchFeedWithURL:feedURL delegate:self didFinishSelector:@selector(did_get_calender_list:feed:error:)];
}

//カレンダーリスト取得完了
- (void) did_get_calender_list:(GDataServiceTicket *)ticket feed:(GDataFeedCalendar*)feed error:(NSError*)error{
	NSLog(@"%s\nerror:%@", __func__, error);
	
	_ticket = nil;
	
	_target_calener = nil;
	
	if(!error){
		int count = [[feed entries] count];
		for(int i=0; i<count; i++){
			GDataEntryCalendar* calendar = [[feed entries] objectAtIndex:i];
			NSString* name = [[calendar title] stringValue];
			
			if([name isEqualToString:@"家計簿"] == YES){
				_target_calener = calendar;
				break;
			}
		}
		
		if(_target_calener == nil){
			[self add_kakeibo_calender];
		}
		else{
			[self get_event_list];
		}
	}
	else{
		//エラー
	}
}

//家計簿カレンダーを作成
- (void) add_kakeibo_calender{
	NSLog(@"%s", __func__);
	
	GDataEntryCalendar* new_calender = [GDataEntryCalendar calendarEntry];
	[new_calender setTitleWithString:@"家計簿"];
	[new_calender setIsSelected:YES];

	_ticket = [_service fetchEntryByInsertingEntry:new_calender forFeedURL:[NSURL URLWithString:kGDataGoogleCalendarDefaultOwnCalendarsFeed] delegate:self didFinishSelector:@selector(did_add_calendar:entry:error:)];
}

//家計簿カレンダーを作成完了
- (void) did_add_calendar:(GDataServiceTicket *)ticket entry:(GDataEntryCalendar*)entry error:(NSError*)error{
	NSLog(@"%s\nerror:%@", __func__, error);
	
	_ticket = nil;
	
	if(!error){
		_target_calener = entry;
		
		[self get_event_list];
	}
	else{
		//エラー
	}
}

//イベントリスト取得
- (void) get_event_list{
	NSLog(@"%s", __func__);
	
	_new_event_list = [[NSMutableArray alloc] init];
	_new_recurrence_event_list = [[NSMutableArray alloc] init];
	_edited_event_list = [[NSMutableArray alloc] init];
	_deleted_event_list = [[NSMutableArray alloc] init];
	
	NSURL* feedURL = [[_target_calener alternateLink] URL];
	if(feedURL != nil){
        GDataQueryCalendar* query = [GDataQueryCalendar calendarQueryWithFeedURL:feedURL];
		[query setMaxResults:100];

        [query setOrderBy:@"starttime"];  // http://code.google.com/apis/calendar/docs/2.0/reference.html#Parameters
        [query setIsAscendingOrder:YES];
		
		[query setShouldShowDeleted:YES];
		//[query setShouldShowOnlyDeleted:YES];
		[query setShouldExpandRecurrentEvents:NO];
		
		if(_last_sync_date != nil){
			GDataDateTime* min_date = [GDataDateTime dateTimeWithDate:_last_sync_date timeZone:[NSTimeZone systemTimeZone]];
			[query setUpdatedMinDateTime:min_date];
		}
		else{
			
		}
		
        _ticket = [_service fetchFeedWithQuery:query delegate:self didFinishSelector:@selector(did_get_event_list:feed:error:)];
	}
	else{
		//エラー
	}
}

//イベントリスト取得完了
- (void)did_get_event_list:(GDataServiceTicket *)ticket feed:(GDataFeedCalendarEvent*)feed error:(NSError*)error{
	NSLog(@"%s\nerror:%@", __func__, error);
	
	_ticket = nil;
	
	if(!error){
		int count = [[feed entries] count];
		
		for(int i=0; i<count; i++){
			GDataEntryCalendarEvent* event = [[feed entries] objectAtIndex:i];
			NSString* title = [[event title] stringValue];
			NSArray* times = [event times];
			NSString* start = [[times[0] startTime] stringValue];
			NSDate* start_date = [[times[0] startTime] date];
			NSString* end = [[times[0] endTime] stringValue];
			GDataRecurrence* rec = [event recurrence];
			NSString* recurrence = [[event recurrence] stringValue];
			GDataOriginalEvent* org = [event originalEvent];
			NSString* url = [org href];
			BOOL is_deleted = [event isDeleted];
			GDataEventStatus* status = [event eventStatus];
			NSString* identifier = [event identifier];
			NSArray* id_elems = [identifier componentsSeparatedByString:@"/"];
			NSString* short_id = [id_elems lastObject];
			NSURL* edit_link = [[event editLink] URL];
			NSURL* feed_link = [[event feedLink] URL];
			GDataWhen *when = [[event objectsForExtensionClass:[GDataWhen class]] objectAtIndex:0];
			if(when != nil){
				NSDate *start_date = [[when startTime] date];
				NSDate *end_date = [[when endTime] date];
			}
			
			NSDate* update_date = [[event updatedDate] date];
			NSString* eTag = [event ETag];
			NSString* xml = [[event XMLDocument].rootElement XMLString];
			NSLog(@"%@\n\n", xml);
			
			
			//cancelイベント
			if([[status stringValue] isEqualToString:kGDataEventStatusCanceled] == YES){
				//通常イベントの削除
				if(org == nil){
					DBEvent* db_event = [g_model_ get_event_with_id:short_id];
					
					if(db_event != nil){
						//コンフリクト
						if([db_event.sync_status isEqualToString:@"tmp_edited"] == YES){
							//GoogleCalenderのデータのほうが古い
							if([db_event.last_update compare:update_date] != NSOrderedAscending){
								//GoogleCalenderのデータは無視
								
								//eTagだけはもらっておく
								db_event.eTag = eTag;
								
								continue;
							}
						}
						
						[_deleted_event_list addObject:event];
						[g_model_ del_event_actually:db_event];
					}
				}
				//繰り返しの例外(1日削除)
				else{
					DBEvent* db_event = [g_model_ get_event_with_id:short_id];
					
					//新規イベント
					if(db_event == nil){
						//後で追加する
						[_new_recurrence_event_list addObject:event];
					}
					//編集イベント
					else{
						//何も変わってなければ無視
						if([db_event.eTag isEqualToString:eTag] == YES){
							continue;
						}
						
						NSString* status = db_event.sync_status;
						
						//コンフリクト
						if([db_event.sync_status isEqualToString:@"tmp_edited"] == YES){
							//GoogleCalenderのデータのほうが古い
							if([db_event.last_update compare:update_date] != NSOrderedAscending){
								//GoogleCalenderのデータは無視
								
								//eTagだけはもらっておく
								db_event.eTag = eTag;
								
								continue;
							}
						}
						//コンフリクト
						else if([db_event.sync_status isEqualToString:@"tmp_deleted"] == YES){
							//GoogleCalenderのデータのほうが古い
							if([db_event.last_update compare:update_date] != NSOrderedAscending){
								//GoogleCalenderのデータは無視
								
								//eTagだけはもらっておく
								db_event.eTag = eTag;
								
								continue;
							}
						}
						
						[g_model_ del_event_actually:db_event];
						[g_model_ add_event:event];
						[_edited_event_list addObject:event];
					}
				}
			}
			//confirmedイベント
			else{
				DBEvent* db_event = [g_model_ get_event_with_id:short_id];
				
				//新規イベント
				if(db_event == nil){
					//繰り返しの例外
					if(org != nil){
						//後で追加する
						[_new_recurrence_event_list addObject:event];
					}
					else{
						//すぐ追加する
						[_new_event_list addObject:event];
						[g_model_ add_event:event];
					}
				}
				//編集イベント
				else{
					//何も変わってなければ無視
					if([db_event.eTag isEqualToString:eTag] == YES){
						continue;
					}
					
					NSString* status = db_event.sync_status;
					
					//コンフリクト
					if([db_event.sync_status isEqualToString:@"tmp_edited"] == YES){
						//GoogleCalenderのデータのほうが古い
						if([db_event.last_update compare:update_date] != NSOrderedAscending){
							//GoogleCalenderのデータは無視
							
							//eTagだけはもらっておく
							db_event.eTag = eTag;
							
							continue;
						}
					}
					//コンフリクト
					else if([db_event.sync_status isEqualToString:@"tmp_deleted"] == YES){
						//GoogleCalenderのデータのほうが古い
						if([db_event.last_update compare:update_date] != NSOrderedAscending){
							//GoogleCalenderのデータは無視
							
							//eTagだけはもらっておく
							db_event.eTag = eTag;
							
							continue;
						}
					}
					
					[g_model_ del_event_actually:db_event];
					[g_model_ add_event:event];
					[_edited_event_list addObject:event];
				}
			}
			
			//[g_model_ add_event:event];
			//[self.event_list addObject:event];
		}
		
		NSURL* nextURL = [[feed nextLink] URL];
		if(nextURL != nil){
			//残りのイベントを取りに行く
			_ticket = [_service fetchFeedWithURL:nextURL delegate:self didFinishSelector:@selector(did_get_event_list:feed:error:)];
		}
		else{
			//取得完了
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			
			//繰り返しの例外を追加
			for(GDataEntryCalendarEvent* event in _new_recurrence_event_list){
				[g_model_ add_event:event];
			}
			
			NSMutableArray* tmp_added_db_event = [NSMutableArray arrayWithArray:[g_model_ get_local_added_event]];
			NSMutableArray* tmp_edited_db_event = [NSMutableArray arrayWithArray:[g_model_ get_local_edited_event]];
			NSMutableArray* tmp_deleted_db_event = [NSMutableArray arrayWithArray:[g_model_ get_local_deleted_event]];

			[self upload_local_db_event];
			
			//ローカルの変更を適用する
			[g_model_ save_model];
			
			NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
			[settings setObject:_sync_start_date forKey:@"LAST_SYNC_DATE"];
		}
	}
	else{
		//エラー
	}
}

- (void) upload_local_db_event{
	_tmp_added_db_event = [NSMutableArray arrayWithArray:[g_model_ get_local_added_event]];
	_tmp_edited_db_event = [NSMutableArray arrayWithArray:[g_model_ get_local_edited_event]];
	_tmp_deleted_db_event = [NSMutableArray arrayWithArray:[g_model_ get_local_deleted_event]];

	[self upload_local_db_event2];
}

- (void) upload_local_db_event2{
	for(int i=0; i<[_tmp_added_db_event count]; i++){
		DBEvent* event = _tmp_added_db_event[0];
		
		[self add_event:event];
		return;
	}
	for(int i=0; i<[_tmp_edited_db_event count]; i++){
		DBEvent* event = _tmp_edited_db_event[0];
		
		[self edit_event:event];
		return;
	}
	for(int i=0; i<[_tmp_deleted_db_event count]; i++){
		DBEvent* event = _tmp_deleted_db_event[0];
		
		[self del_event_from_calender:event];
		return;
	}
	
	//すべて適用完了
	//ローカルの変更を適用する
	[g_model_ save_model];
}

- (void) add_event:(DBEvent*) event{
	NSLog(@"%s", __func__);
	
	GDataEntryCalendarEvent* newEntry = [GDataEntryCalendarEvent calendarEvent];
	
	//通常イベント
	if([[event class] isEqual:[DBEvent_Normal class]] == YES){
		DBEvent_Normal* db_event = (DBEvent_Normal*)event;
		
		GDataDateTime* start_time = [GDataDateTime dateTimeWithDate:event.date timeZone:[NSTimeZone systemTimeZone]];
		[start_time setHasTime:NO];
		
		[newEntry addTime:[GDataWhen whenWithStartTime:start_time endTime:start_time]];
		
		if([event.person isEqualToString:@""] == NO){
			[newEntry setTitleWithString:[NSString stringWithFormat:@"%@@%d@%@", event.category, event.val, event.person]];
		}
		else{
			[newEntry setTitleWithString:[NSString stringWithFormat:@"%@@%d", event.category, event.val]];
		}
		
		[newEntry setContentWithString:event.memo];
		[newEntry addLocation:[GDataWhere whereWithString:@""]];
	}
	//繰り返しイベント
	else if([[event class] isEqual:[DBEvent_Recurrence class]] == YES){
		DBEvent_Recurrence* db_event = (DBEvent_Recurrence*)event;
		
		GDataRecurrence* recurrence = [GDataRecurrence recurrenceWithString:db_event.recurrence];
		[newEntry setRecurrence:recurrence];
		
		if([event.person isEqualToString:@""] == NO){
			[newEntry setTitleWithString:[NSString stringWithFormat:@"%@@%d@%@", event.category, event.val, event.person]];
		}
		else{
			[newEntry setTitleWithString:[NSString stringWithFormat:@"%@@%d", event.category, event.val]];
		}
		
		[newEntry setContentWithString:event.memo];
		[newEntry addLocation:[GDataWhere whereWithString:@""]];
	}
	//繰り返しの例外イベント
	else if([[event class] isEqual:[DBEvent_Exception class]] == YES){
		//１日削除
		if([event.event_status isEqualToString:@"canceled"] == YES){
			DBEvent_Exception* db_event = (DBEvent_Exception*)event;
			
			if(db_event.html_link == nil){
				//これに相当するrecurrence instanceを取得
				[self get_recurrence_instance:db_event.org_event date:db_event.org_date];
				return;
			}
			else{
				//recurrence instanceを削除
				[self del_recurrence_instance:db_event];
				return;
			}
		}
		//１日変更
		else{
			DBEvent_Exception* db_event = (DBEvent_Exception*)event;
			
			if(db_event.html_link == nil){
				//これに相当するrecurrence instanceを取得
				[self get_recurrence_instance:db_event.org_event date:db_event.org_date];
				return;
			}
			else{
				//recurrence instanceを追加ではなく編集にする
				db_event.sync_status = @"tmp_edited";
				[_tmp_edited_db_event addObject:db_event];
				[_tmp_added_db_event removeObject:db_event];
				return;
			}
		}
	}
	
	[self add_event_to_calender:newEntry];
}

- (void)add_event_to_calender:(GDataEntryCalendarEvent*)event{
	NSLog(@"%s", __func__);
	
	_ticket = [_service fetchEntryByInsertingEntry:event forFeedURL:[[_target_calener alternateLink] URL] delegate:self didFinishSelector:@selector(did_add_event_to_calender:entry:error:)];
}

- (void)did_add_event_to_calender:(GDataServiceTicket *)ticket entry:(GDataEntryCalendarEvent*)entry error:(NSError*)error{
	NSLog(@"%s\nerror:%@", __func__, error);
	
	if(!error){
		NSString* identifier = [entry identifier];
		NSArray* id_elems = [identifier componentsSeparatedByString:@"/"];
		NSString* short_id = [id_elems lastObject];
		
		DBEvent* db_event = _tmp_added_db_event[0];
		db_event.eTag = [entry ETag];
		db_event.html_link = [[[entry editLink] URL] absoluteString];
		
		db_event.sync_status = @"synced";
		
		db_event.identifier = short_id;
		
		[_tmp_added_db_event removeObjectAtIndex:0];
	}
	else{
		
	}
	
	[self upload_local_db_event2];
}

DBEvent_Recurrence* tmp_db_event_recurrence;

- (void) get_recurrence_instance:(DBEvent_Recurrence*)db_event date:(NSDate*)date{
	tmp_db_event_recurrence = db_event;
	
	NSURL* feedURL = [[_target_calener alternateLink] URL];
	
    GDataQueryCalendar* query = [GDataQueryCalendar calendarQueryWithFeedURL:feedURL];
	//[query setMaxResults:100];
	
	[query setOrderBy:@"starttime"];  // http://code.google.com/apis/calendar/docs/2.0/reference.html#Parameters
	[query setIsAscendingOrder:YES];
	
	//[query setShouldShowDeleted:YES];
	//[query setShouldShowOnlyDeleted:YES];
	
	[query setShouldExpandRecurrentEvents:YES];
	GDataDateTime* min = [GDataDateTime dateTimeWithDate:date timeZone:[NSTimeZone defaultTimeZone]];
	[min setHasTime:NO];
	
	GDataDateTime* max = [GDataDateTime dateTimeWithDate:[NSDate dateWithTimeInterval:3600*24 sinceDate:date] timeZone:[NSTimeZone defaultTimeZone]];
	[max setHasTime:NO];
	
	[query setMinimumStartTime:min];
	[query setMaximumStartTime:max];
	
	_ticket = [_service fetchFeedWithQuery:query delegate:self didFinishSelector:@selector(did_get_recurrence_instance:feed:error:)];
}

- (void)did_get_recurrence_instance:(GDataServiceTicket *)ticket feed:(GDataFeedCalendarEvent*)feed error:(NSError*)error{
	NSLog(@"%s\nerror:%@", __func__, error);
	
	_ticket = nil;
	
	if(!error){
		int count = [[feed entries] count];
		
		for(int i=0; i<count; i++){
			GDataEntryCalendarEvent* event = [[feed entries] objectAtIndex:i];
			NSString* title = [[event title] stringValue];
			NSArray* times = [event times];
			NSString* start = [[times[0] startTime] stringValue];
			NSDate* start_date = [[times[0] startTime] date];
			NSString* end = [[times[0] endTime] stringValue];
			GDataRecurrence* rec = [event recurrence];
			NSString* recurrence = [[event recurrence] stringValue];
			GDataOriginalEvent* org = [event originalEvent];
			NSString* url = [org href];
			BOOL is_deleted = [event isDeleted];
			GDataEventStatus* status = [event eventStatus];
			NSString* identifier = [event identifier];
			NSArray* id_elems = [identifier componentsSeparatedByString:@"/"];
			NSString* short_id = [id_elems lastObject];
			NSURL* edit_link = [[event editLink] URL];
			NSURL* feed_link = [[event feedLink] URL];
			GDataWhen *when = [[event objectsForExtensionClass:[GDataWhen class]] objectAtIndex:0];
			if(when != nil){
				NSDate *start_date = [[when startTime] date];
				NSDate *end_date = [[when endTime] date];
			}
			
			NSDate* update_date = [[event updatedDate] date];
			NSString* eTag = [event ETag];
			NSString* xml = [[event XMLDocument].rootElement XMLString];
			NSLog(@"%@\n\n", xml);
			
			//目的のイベント発見
			if(org != nil){
				NSString* org_id = [org originalID];
				
				if([org_id isEqualToString:tmp_db_event_recurrence.identifier] == YES){
					DBEvent_Exception* db_event = _tmp_added_db_event[0];
					
					NSDate* org_date = [[[org originalStartTime] startTime] date];
					if([CommonAPI compare_date:org_date date2:db_event.org_date] == NSOrderedSame){
						db_event.eTag = [event ETag];
						db_event.html_link = [[[event editLink] URL] absoluteString];
						db_event.identifier = short_id;
						
						[self upload_local_db_event2];
						
						return;
					}
				}
			}
			
		}
		
		//エラー
		assert(NO);
	}
	else{
		//エラー
		assert(NO);
	}
}

- (void)del_recurrence_instance:(DBEvent*)db_event{
	NSLog(@"%s", __func__);
	
	NSURL* url = [NSURL URLWithString:db_event.html_link];
	
	_ticket = [_service deleteResourceURL:url ETag:db_event.eTag delegate:self didFinishSelector:@selector(did_del_recurrence_instance:entry:error:)];
}

- (void)did_del_recurrence_instance:(GDataServiceTicket *)ticket entry:(GDataEntryCalendarEvent*)entry error:(NSError*)error{
	NSLog(@"%s\nerror:%@", __func__, error);
	
	_ticket = nil;
	
	if(!error){
		DBEvent* db_event = _tmp_added_db_event[0];
		db_event.eTag = [entry ETag];
		db_event.sync_status = @"synced";
		
		[_tmp_added_db_event removeObjectAtIndex:0];
	}
	else{
		//コンフリクト
		//Error Domain=com.google.GDataServiceDomain Code=412 "The operation couldn’t be completed. (Mismatch: etags
		if(error.code == 412){
			//今回はパス
			[_tmp_added_db_event removeObjectAtIndex:0];
		}
	}
	
	[self upload_local_db_event2];
}

- (void)del_event_from_calender:(DBEvent*)db_event{
	NSLog(@"%s", __func__);
	
	NSURL* url = [NSURL URLWithString:db_event.html_link];
	
	_ticket = [_service deleteResourceURL:url ETag:db_event.eTag delegate:self didFinishSelector:@selector(did_del_event_from_calender:entry:error:)];
}

- (void)did_del_event_from_calender:(GDataServiceTicket *)ticket entry:(GDataEntryCalendarEvent*)entry error:(NSError*)error{
	NSLog(@"%s\nerror:%@", __func__, error);
	
	_ticket = nil;
	
	if(!error){
		DBEvent* db_event = _tmp_deleted_db_event[0];
		
		//繰り返しの例外(1日)の場合
		if([[db_event class] isEqual:[DBEvent_Exception class]] == YES){
			db_event.event_status = @"canceled";
			db_event.sync_status = @"synced";
		}
		else{
			[g_model_ del_event_actually:db_event];
		}
		
		[_tmp_deleted_db_event removeObjectAtIndex:0];
	}
	else{
		//コンフリクト
		//Error Domain=com.google.GDataServiceDomain Code=412 "The operation couldn’t be completed. (Mismatch: etags
		if(error.code == 412){
			//今回はパス
			[_tmp_deleted_db_event removeObjectAtIndex:0];
		}
	}
	
	[self upload_local_db_event2];
}

- (void) edit_event:(DBEvent*)event{
	NSLog(@"%s", __func__);
	
	//edit対象のentryを取得
	[self get_event_for_edit:event];
}

- (void) get_event_for_edit:(DBEvent*)event{
	NSLog(@"%s", __func__);
	
	_ticket = [_service fetchEntryWithURL:[NSURL URLWithString:event.html_link] delegate:self didFinishSelector:@selector(did_get_event_for_edit:entry:error:)];
}

- (void)did_get_event_for_edit:(GDataServiceTicket *)ticket entry:(GDataEntryCalendarEvent*)entry error:(NSError*)error{
	NSLog(@"%s\nerror:%@", __func__, error);
	
	_ticket = nil;
	
	if(!error){
		DBEvent* event = _tmp_edited_db_event[0];
		
		//通常イベント
		if([[event class] isEqual:[DBEvent_Normal class]] == YES){
			DBEvent_Normal* db_event = (DBEvent_Normal*)event;
			
			GDataDateTime* start_time = [GDataDateTime dateTimeWithDate:event.date timeZone:[NSTimeZone systemTimeZone]];
			[start_time setHasTime:NO];
			
			[entry addTime:[GDataWhen whenWithStartTime:start_time endTime:start_time]];
			
			if([event.person isEqualToString:@""] == NO){
				[entry setTitleWithString:[NSString stringWithFormat:@"%@@%d@%@", event.category, event.val, event.person]];
			}
			else{
				[entry setTitleWithString:[NSString stringWithFormat:@"%@@%d", event.category, event.val]];
			}
			
			[entry setContentWithString:event.memo];
		}
		//繰り返しイベント
		else if([[event class] isEqual:[DBEvent_Recurrence class]] == YES){
			DBEvent_Recurrence* db_event = (DBEvent_Recurrence*)event;
			
			GDataRecurrence* recurrence = [GDataRecurrence recurrenceWithString:db_event.recurrence];
			[entry setRecurrence:recurrence];
			
			if([event.person isEqualToString:@""] == NO){
				[entry setTitleWithString:[NSString stringWithFormat:@"%@@%d@%@", event.category, event.val, event.person]];
			}
			else{
				[entry setTitleWithString:[NSString stringWithFormat:@"%@@%d", event.category, event.val]];
			}
			
			[entry setContentWithString:event.memo];
		}
		//繰り返しの例外(1日変更)イベント
		else if([[event class] isEqual:[DBEvent_Exception class]] == YES){
			DBEvent_Exception* db_event = (DBEvent_Exception*)event;
			
			GDataDateTime* start_time = [GDataDateTime dateTimeWithDate:event.date timeZone:[NSTimeZone systemTimeZone]];
			[start_time setHasTime:NO];
			
			[entry addTime:[GDataWhen whenWithStartTime:start_time endTime:start_time]];
			
			if([event.person isEqualToString:@""] == NO){
				[entry setTitleWithString:[NSString stringWithFormat:@"%@@%d@%@", event.category, event.val, event.person]];
			}
			else{
				[entry setTitleWithString:[NSString stringWithFormat:@"%@@%d", event.category, event.val]];
			}
			
			[entry setContentWithString:event.memo];
		}
		
		[self edit_event_in_calender:entry];
	}
	else{
		//今回はパス
		[_tmp_edited_db_event removeObjectAtIndex:0];
	}
}

- (void) edit_event_in_calender:(GDataEntryCalendarEvent*)event{
	NSLog(@"%s", __func__);
	
	_ticket = [_service fetchEntryByUpdatingEntry:event delegate:self didFinishSelector:@selector(did_edit_event_in_calender:entry:error:)];
}

- (void)did_edit_event_in_calender:(GDataServiceTicket *)ticket entry:(GDataEntryCalendarEvent*)entry error:(NSError*)error{
	NSLog(@"%s\nerror:%@", __func__, error);
	
	_ticket = nil;
	
	if(!error){
		DBEvent* db_event = _tmp_edited_db_event[0];
		db_event.eTag = entry.ETag;
		db_event.sync_status = @"synced";
		
		[_tmp_edited_db_event removeObjectAtIndex:0];
	}
	else{
		//コンフリクト
		//Error Domain=com.google.GDataServiceDomain Code=412 "The operation couldn’t be completed. (Mismatch: etags
		if(error.code == 412){
			//今回はパス
			[_tmp_edited_db_event removeObjectAtIndex:0];
		}
	}
	
	[self upload_local_db_event2];
}

/*
- (void)did_get_org_event:(GDataServiceTicket *)ticket entry:(GDataEntryCalendarEvent*)entry error:(NSError*)error{
	NSLog(@"%s\nerror:%@", __func__, error);
	
	if(!error){
		GDataEntryCalendarEvent* event = entry;
		NSString* title = [[event title] stringValue];
		NSArray* times = [event times];
		NSString* start = [[times[0] startTime] stringValue];
		NSString* end = [[times[0] endTime] stringValue];
		GDataRecurrence* rec = [event recurrence];
		NSString* recurrence = [[event recurrence] stringValue];
		
		//[self edit_event:event];
	}
	else{
		
	}
}



- (void) update_db{
	
}

//履歴を追加
- (void) add_history:(History_Data*)data{
	NSLog(@"%s", __func__);
	
	if(_target_calener == nil){
		return;
	}
	
	GDataEntryCalendarEvent* newEntry = [GDataEntryCalendarEvent calendarEvent];
	
	if(data.period.type == ONE_DAY){
		GDataDateTime* start_time = [GDataDateTime dateTimeWithDate:data.period.start_date timeZone:[NSTimeZone systemTimeZone]];
		[start_time setHasTime:NO];
		
		[newEntry addTime:[GDataWhen whenWithStartTime:start_time endTime:start_time]];
	}
	else{
		NSString* recurrence_string = [data recurrence_string];
		GDataRecurrence* recurrence = [GDataRecurrence recurrenceWithString:recurrence_string];
		
		[newEntry setRecurrence:recurrence];
	}
	
	if([data.person isEqualToString:@""] == NO){
		[newEntry setTitleWithString:[NSString stringWithFormat:@"%@@%d@%@", data.category, data.val, data.person]];
	}
	else{
		[newEntry setTitleWithString:[NSString stringWithFormat:@"%@@%d", data.category, data.val]];
	}
	[newEntry setContentWithString:data.memo];
	[newEntry addLocation:[GDataWhere whereWithString:@""]];
									
	[self add_calendar_event:newEntry toCalendar:_target_calener];
}



- (void) del_history:(GDataEntryCalendarEvent*)event{
	NSLog(@"%s", __func__);
	
    GDataLink *link = [event editLink];
	
    if (link) {
		//[_service deleteEntry:event delegate:self didFinishSelector:@selector(did_del_history:entry:error:)];
		
		[_service deleteResourceURL:[link URL] ETag:event.ETag delegate:self didFinishSelector:@selector(did_del_history:entry:error:)];
    }
}

- (void)did_del_history:(GDataServiceTicket *)ticket entry:(GDataEntryCalendarEvent*)entry error:(NSError*)error{
	NSLog(@"%s\nerror:%@", __func__, error);
	
	if(!error){
		
	}
	else{
		
	}
}

- (void) edit_history:(GDataEntryCalendarEvent*)event{
	NSLog(@"%s", __func__);
	
	[self get_event:event];
}

- (void) get_event:(GDataEntryCalendarEvent*)event{
	NSLog(@"%s", __func__);
	
	if(_target_calener == nil){
		return;
	}
	
	NSURL* feedURL = [[_target_calener alternateLink] URL];
	if(feedURL){
		NSURL* selfLink = [[event selfLink] URL];
		NSURL* editLink = [[event editLink] URL];
		NSURL* feedLink = [[event feedLink] URL];
		
        GDataQueryCalendar* query = [GDataQueryCalendar calendarQueryWithFeedURL:feedURL];

		//[query setOrderBy:@"starttime"];  // http://code.google.com/apis/calendar/docs/2.0/reference.html#Parameters
       // [query setIsAscendingOrder:YES];
        [query setShouldExpandRecurrentEvents:YES];

		//[_service fetchFeedWithQuery:query delegate:self didFinishSelector:@selector(did_get_event:feed:error:)];
		[_service fetchEntryWithURL:selfLink delegate:self didFinishSelector:@selector(did_get_event:entry:error:)];
	}
}

- (void)did_get_event:(GDataServiceTicket *)ticket entry:(GDataEntryCalendarEvent*)entry error:(NSError*)error{
	NSLog(@"%s\nerror:%@", __func__, error);
	
	if(!error){
		GDataEntryCalendarEvent* event = entry;
		NSString* title = [[event title] stringValue];
		NSArray* times = [event times];
		NSString* start = [[times[0] startTime] stringValue];
		NSString* end = [[times[0] endTime] stringValue];
		GDataRecurrence* rec = [event recurrence];
		NSString* recurrence = [[event recurrence] stringValue];
	}
	else{
		
	}
}
*/
@end
