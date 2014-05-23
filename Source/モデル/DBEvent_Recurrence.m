//
//  DBEvent_Recurrence.m
//  kakeibo2
//
//  Created by hiro on 2013/05/03.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "DBEvent_Recurrence.h"
#import "DBEvent_Exception.h"
#import "RRULE_BYDAY.h"
#import "CommonAPI.h"
#import "Event.h"

@implementation DBEvent_Recurrence

@dynamic recurrence;
@dynamic rrule_freq;
@dynamic rrule_until;
@dynamic rrule_interval;
@dynamic rrule_count;
@dynamic rrule_bymonthday;
@dynamic exceptions;
@dynamic rrule_byday;

/*
 DTSTART;TZID=Asia/Tokyo:20130509T100000
 DTEND;TZID=Asia/Tokyo:20130509T110000
 RRULE:FREQ=WEEKLY;UNTIL=20130718T010000Z;INTERVAL=2;BYDAY=WE,TH
 BEGIN:VTIMEZONE
 TZID:Asia/Tokyo
 X-LIC-LOCATION:Asia/Tokyo
 BEGIN:STANDARD
 TZOFFSETFROM:+0900
 TZOFFSETTO:+0900
 TZNAME:JST
 DTSTART:19700101T000000
 END:STANDARD
 END:VTIMEZONE
 */

- (BOOL) parse_recurrence:(NSManagedObjectContext*) context{
	self.rrule_bymonthday = 0;
	self.rrule_count = 0;
	self.rrule_freq = nil;
	self.rrule_interval = 1;
	self.rrule_until = nil;
	self.rrule_byday= nil;

	NSLog(@"\n%@", self.recurrence);
	NSArray* recu_lines = [self.recurrence componentsSeparatedByString:@"\n"];
	
	for(int i=0; i<[recu_lines count]; i++){
		NSString* line = recu_lines[i];
		NSArray* elems = [line componentsSeparatedByString:@";"];
		
		//DTSTART;TZID=Asia/Tokyo:20130509T100000
		if([line hasPrefix:@"DTSTART"] == YES){
			if([elems count] != 2){
				[self show_error_alert:line];
				return NO;
			}
			
			//VALUE=DATE:20130502
			if([elems[1] hasPrefix:@"VALUE=DATE:"] == YES){
				NSArray* dtstart_elems = [line componentsSeparatedByString:@":"];
				
				NSDate* date = [self date_with_yyyyMMdd:dtstart_elems[1]];
				self.date = date;
				if(self.date == nil){
					[self show_error_alert:line];
					return NO;
				}
			}
			//TZID=Asia/Tokyo:20130509T110000
			else if([elems[1] hasPrefix:@"TZID="] == YES){
				NSArray* dtstart_elems = [line componentsSeparatedByString:@":"];
				
				NSDate* date = [self date_with_yyyyMMddThhmmss:dtstart_elems[1]];
				self.date = date;
				if(self.date == nil){
					[self show_error_alert:line];
					return NO;
				}
			}
			else{
				[self show_error_alert:line];
				return NO;
			}
		}
		//DTEND;TZID=Asia/Tokyo:20130509T110000
		else if([line hasPrefix:@"DTEND"] == YES){
			//何もしない
		}
		//RRULE:FREQ=WEEKLY;UNTIL=20130718T010000Z;INTERVAL=2;BYDAY=WE,TH
		else if([line hasPrefix:@"RRULE:FREQ="] == YES){
			//RRULE:FREQ=WEEKLY
			NSString* freq = [elems[0] substringFromIndex:11];
			self.rrule_freq = freq;
			
			for(int j=1; j<[elems count]; j++){
				NSString* elem = elems[j];
				
				//UNTIL=20130517
				if([elem hasPrefix:@"UNTIL="] == YES){
					NSString* date_string = [elem substringFromIndex:6];
					
					//20130517
					if([date_string hasSuffix:@"Z"] == NO){
						NSDate* date = [self date_with_yyyyMMdd:date_string];
						self.rrule_until = date;
						
						if(self.rrule_until == nil){
							[self show_error_alert:line];
							return NO;
						}
					}
					//20130718T010000Z
					else{
						date_string = [date_string substringToIndex:[date_string length] - 1];
						
						NSDate* date = [self date_with_yyyyMMddThhmmss:date_string];
						self.rrule_until = date;
						if(self.rrule_until == nil){
							[self show_error_alert:line];
							return NO;
						}
					}
				}
				//INTERVAL=2
				else if([elem hasPrefix:@"INTERVAL="] == YES){
					NSString* val = [elem substringFromIndex:9];
					
					self.rrule_interval = [val intValue];
				}
				//COUNT=35
				else if([elem hasPrefix:@"COUNT="] == YES){
					NSString* val = [elem substringFromIndex:6];
					
					self.rrule_count = [val intValue];
				}
				//BYMONTHDAY=2
				else if([elem hasPrefix:@"BYMONTHDAY="] == YES){
					NSString* val = [elem substringFromIndex:11];
					
					self.rrule_bymonthday = val;
				}
				//BYDAY=TU,TH
				else if([elem hasPrefix:@"BYDAY="] == YES){
					NSString* val = [elem substringFromIndex:6];
					
					self.rrule_byday = val;
				}
				else{
					[self show_error_alert:line];
					return NO;
				}
			}
			
		}
		//BEGIN:VTIMEZONE
		else if([line hasPrefix:@"BEGIN:VTIMEZONE"] == YES){
			//BEGIN:VTIMEZONEは無視する
			for(int j=i+1; j<[recu_lines count]; j++){
				NSString* tmp_line = recu_lines[j];
				
				if([tmp_line hasPrefix:@"END:VTIMEZONE"] == YES){
					i = j;
					break;
				}
			}
		}
		//空行
		else if([line isEqualToString:@""] == YES){
			//何もしない
		}
		else{
			[self show_error_alert:line];
			return NO;
		}
	}
	
	return YES;
}

- (NSDate*) date_with_yyyyMMdd:(NSString*)string{
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyyMMdd"];
	
	return [dateFormatter dateFromString:string];
}

- (NSDate*) date_with_yyyyMMddThhmmss:(NSString*)string{
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyyMMdd'T'hhmmss"];
	
	return [dateFormatter dateFromString:string];
}

- (void) show_error_alert:(NSString*)error_rule{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"この繰り返しルールには対応していません。" message:error_rule delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (NSArray*) recurrence_date_list_with_start:(NSDate*)start_date end:(NSDate*)end_date{
	if(self.rrule_freq == nil){
		[self parse_recurrence:nil];
	}
	
	NSMutableArray* date_list = [[NSMutableArray alloc] init];

	int count = 0;
	
	NSDate* until_date = self.rrule_until;
	if(until_date == nil){
		until_date = end_date;
	}
	else{
		if([CommonAPI compare_date:end_date date2:until_date] == NSOrderedAscending){
			until_date = end_date;
		}
	}
	
	if([self.rrule_freq isEqualToString:@"DAILY"] == YES){
		//考慮:until, interval, count
		
		int day_offset = 0;
		
		//日単位でループ
		while(YES){
			//countに達したら終わり
			int rrule_count = self.rrule_count;
			if(self.rrule_count > 0){
				if(count >= rrule_count){
					break;
				}
			}
			
			//offset分dayを増やす
			NSDate* date = [self.date dateByAddingTimeInterval:60*60*24 * day_offset];
			
			//untilに達したら終わり
			if([CommonAPI compare_date:until_date date2:date] == NSOrderedAscending){
				break;
			}
			
			//start_date以降なら追加する
			if([CommonAPI compare_date:start_date date2:date] != NSOrderedDescending){
				[date_list addObject:date];
			}
			//start_dateより前なら追加しない(countだけ増やす)
			else{
				
			}
			
			count ++;
			day_offset += self.rrule_interval;
		}
	}
	else if([self.rrule_freq isEqualToString:@"WEEKLY"] == YES){
		//考慮:until, interval, count, byday(TU,TH)
		
		int week_offset = 0;
		
		NSArray* byday_on_list = [self byday_on_list];
		
		//週単位でループ
		while(YES){
			//週初めの日(GoogleCalはなぜか月曜が週の始まりで決め打ち)
			int weekday = [CommonAPI weekday:self.date];
			NSDate* week_start_date = [self.date dateByAddingTimeInterval:60*60*24*7 * week_offset - (60*60*24 * (weekday - 2))];
			NSDate* week_end_date = [week_start_date dateByAddingTimeInterval:60*60*24*6];
			
			//week_end_dateがstart_dateより前ならこの週はスキップ
			if([CommonAPI compare_date:week_end_date date2:start_date] == NSOrderedAscending){
				week_offset += self.rrule_interval;
				continue;
			}
			
			//日単位でループ
			for(int i=0; i<7; i++){
				//countに達したら終わり
				int rrule_count = self.rrule_count;
				if(self.rrule_count > 0){
					if(count >= rrule_count){
						break;
					}
				}
				
				NSDate* date = [week_start_date dateByAddingTimeInterval:60*60*24 * i];
				weekday = [CommonAPI weekday:date];
				
				//self.dateより前ならスキップ
				if([CommonAPI compare_date:date date2:self.date] == NSOrderedAscending){
					continue;
				}
				
				//対象の曜日ではない場合はスキップ
				if([byday_on_list[weekday] isEqual: @NO]){
					continue;
				}
				
				//untilに達したら終わり
				if([CommonAPI compare_date:until_date date2:date] == NSOrderedAscending){
					break;
				}
				
				//start_date以降なら追加する
				if([CommonAPI compare_date:start_date date2:date] != NSOrderedDescending){
					[date_list addObject:date];
				}
				//start_dateより前なら追加しない(countだけ増やす)
				else{
					
				}
				
				count ++;
			}
			
			//untilに達したら終わり
			if([CommonAPI compare_date:until_date date2:week_start_date] == NSOrderedAscending){
				break;
			}

			week_offset += self.rrule_interval;
		}
	}
	else if([self.rrule_freq isEqualToString:@"MONTHLY"] == YES){
		//考慮:until, interval, count, byday(1TU, TU,TH), bymonthday
		
		int month_offset = 0;
		
		NSArray* byday_on_list = [self byday_on_list];
		
		//月単位でループ
		while(YES){
			NSDate* month_start_date = [self.date dateByAddingTimeInterval:-60*60*24* ([CommonAPI day:self.date] - 1)];
			NSDate* month_end_date;
			
			NSCalendar *cal = [NSCalendar currentCalendar];
			int month_days = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:month_start_date].length;
			
			//offset分monthを増やす
			NSDateComponents *comps = [[NSDateComponents alloc] init];
			[comps setMonth:month_offset];
			month_start_date = [cal dateByAddingComponents:comps toDate:month_start_date options:0];
			month_end_date = [month_start_date dateByAddingTimeInterval:60*60*24* (month_days - 1)];
			
			//month_end_dateがstart_dateより前ならこの月はスキップ
			if([CommonAPI compare_date:month_end_date date2:start_date] == NSOrderedAscending){
				month_offset += self.rrule_interval;
				continue;
			}
			
			//対象日の一覧を作成
			NSMutableArray* target_day_list = [[NSMutableArray alloc] init];
			//bymonthdayなしの場合
			if(self.rrule_bymonthday == nil){
				for(int i = 1; i<=month_days; i++){
					NSDate* date = [month_start_date dateByAddingTimeInterval:60*60*24 * (i - 1)];
					[target_day_list addObject:date];
				}
			}
			else{
				[target_day_list setArray:[self bymonth_day_list:month_start_date]];
			}
			
			//対象日でループ
			for(NSDate* date in target_day_list){
				//countに達したら終わり
				int rrule_count = self.rrule_count;
				if(self.rrule_count > 0){
					if(count >= rrule_count){
						break;
					}
				}
				
				int weekday = [CommonAPI weekday:date];
				//今月何回目の曜日か
				int weekday_index = ceil([CommonAPI day:date] / 7.0);
				
				//self.dateより前ならスキップ
				if([CommonAPI compare_date:date date2:self.date] == NSOrderedAscending){
					continue;
				}
				
				//曜日指定がある場合
				if(byday_on_list != nil){
					//対象の曜日ではない場合はスキップ
					if([byday_on_list[weekday] isEqual: @NO]){
						continue;
					}
					
					RRULE_BYDAY* byday = byday_on_list[weekday];
					
					//週番号の指定がある場合
					if([byday.ordwk_set count] > 0){
						//対象の週番号ではない場合はスキップ
						if([byday.ordwk_set containsObject:@(weekday_index)] == NO){
							continue;
						}
					}
				}
				
				//untilに達したら終わり
				if([CommonAPI compare_date:until_date date2:date] == NSOrderedAscending){
					break;
				}
				
				//start_date以降なら追加する
				if([CommonAPI compare_date:start_date date2:date] != NSOrderedDescending){
					[date_list addObject:date];
				}
				//start_dateより前なら追加しない(countだけ増やす)
				else{
					
				}
				
				count ++;
			}
			
			//untilに達したら終わり
			if([CommonAPI compare_date:until_date date2:month_start_date] == NSOrderedAscending){
				break;
			}
			
			month_offset += self.rrule_interval;
		}
	}
	else if([self.rrule_freq isEqualToString:@"YEARLY"] == YES){
		//考慮:until, interval, count
		
		//うるう年の2/29?
		BOOL is_0229 = NO;
		if([CommonAPI month:self.date] == 2 && [CommonAPI day:self.date] == 29){
			is_0229 = YES;
		}
		
		int year_offset = 0;
		
		//年単位でループ
		while(YES){
			//countに達したら終わり
			int rrule_count = self.rrule_count;
			if(self.rrule_count > 0){
				if(count >= rrule_count){
					break;
				}
			}
			
			//offset分yearを増やす
			NSCalendar *cal = [NSCalendar currentCalendar];
			NSDateComponents *comps = [[NSDateComponents alloc] init];
			[comps setYear:year_offset];
			NSDate* date = [cal dateByAddingComponents:comps toDate:self.date options:0];
			
			//untilに達したら終わり
			if([CommonAPI compare_date:until_date date2:date] == NSOrderedAscending){
				break;
			}
			
			if(is_0229 == YES){
				//うるう年でなければスキップ
				if([self is_uruudoshi:date] == NO){
					year_offset += self.rrule_interval;
					continue;
				}
			}
			
			//start_date以降なら追加する
			if([CommonAPI compare_date:start_date date2:date] != NSOrderedDescending){
				[date_list addObject:date];
			}
			//start_dateより前なら追加しない(countだけ増やす)
			else{
				
			}
			
			count ++;
			year_offset += self.rrule_interval;
		}
		
	}
	else{
		assert(NO);
	}
	
	
	
	return date_list;
}

- (BOOL) is_uruudoshi:(NSDate*)date{
	int year = [CommonAPI year:date];
	int n = 28 + (1 / (year % 4 + 1)) * (1 - 1 / (year % 100 + 1)) + (1 / (year % 400 + 1));
	
	if(n == 29){
		return YES;
	}
	else{
		return NO;
	}
}

- (NSArray*) byday_on_list{
	if(self.rrule_byday == nil){
		return nil;
	}
	
	NSMutableArray* byday_on_list = [NSMutableArray arrayWithArray:@[@NO, @NO, @NO, @NO, @NO, @NO, @NO, @NO]];
	
	NSArray* weekdays = [self.rrule_byday componentsSeparatedByString:@","];
	
	for(int j=0; j<[weekdays count]; j++){
		NSString* weekday_string = weekdays[j];
		NSString* ordwk = nil;
		NSString* weekday = nil;
		
		//TU
		if([weekday_string length] == 2){
			weekday = weekday_string;
		}
		//1TU
		else if([weekday_string length] > 2){
			weekday = [weekday_string substringFromIndex:[weekday_string length] - 2];
			ordwk = [weekday_string substringToIndex:[weekday_string length] - 2];
		}
		else{
			[self show_error_alert:weekday_string];
			return NO;
		}
		
		int weekday_no;
		if([weekday isEqualToString:@"SU"] == YES){
			weekday_no = 1;
		}
		else if([weekday isEqualToString:@"MO"] == YES){
			weekday_no = 2;
		}
		else if([weekday isEqualToString:@"TU"] == YES){
			weekday_no = 3;
		}
		else if([weekday isEqualToString:@"WE"] == YES){
			weekday_no = 4;
		}
		else if([weekday isEqualToString:@"TH"] == YES){
			weekday_no = 5;
		}
		else if([weekday isEqualToString:@"FR"] == YES){
			weekday_no = 6;
		}
		else if([weekday isEqualToString:@"SA"] == YES){
			weekday_no = 7;
		}
		else{
			[self show_error_alert:weekday_string];
			return NO;
		}
		
		RRULE_BYDAY* byday;
		
		if([byday_on_list[weekday_no] isEqual:@NO] == YES){
			byday = [[RRULE_BYDAY alloc] init];
			byday.weekday_no = weekday_no;
			byday.ordwk_set = [[NSMutableSet alloc] init];
			
			byday_on_list[weekday_no] = byday;
		}
		else{
			byday = byday_on_list[weekday_no];
		}
		
		if(ordwk != nil){
			int ordwk_no = [ordwk intValue];
			[byday.ordwk_set addObject:@(ordwk_no)];
		}
	}

	return byday_on_list;
}

- (NSArray*) bymonth_day_list:(NSDate*)base_date{
	if(self.rrule_bymonthday == nil){
		return nil;
	}
	
	NSMutableArray* bymonth_day_list = [[NSMutableArray alloc] init];
	
	NSArray* list = [self.rrule_bymonthday componentsSeparatedByString:@","];
	for(int i=0; i<[list count]; i++){
		int day = [list[i] intValue];
		
		NSDate* date = [CommonAPI get_date_year:[CommonAPI year:base_date] month:[CommonAPI month:base_date] day:day];
		[bymonth_day_list addObject:date];
	}
	
	return bymonth_day_list;
}

- (NSArray*) event_list_with_start:(NSDate*)start_date end:(NSDate*)end_date{
	NSMutableArray* event_list = [[NSMutableArray alloc] init];
	NSArray* date_list = [self recurrence_date_list_with_start:start_date end:end_date];
	
	for(NSDate* date in date_list){
		Event* event = [[Event alloc] init];
		event.date = date;
		event.db_event = self;
		
		[event_list addObject:event];
	}
	
	//例外の適用
	for(DBEvent_Exception* exception in self.exceptions){
		//オリジナルを消す
		for(int i=0; i<[event_list count]; i++){
			Event* event = event_list[i];
			
			if([CommonAPI compare_date:event.date date2:exception.org_date] == NSOrderedSame){
				[event_list removeObjectAtIndex:i];
				break;
			}
		}
		
		if([exception.event_status isEqualToString:@"canceled"] == YES){
			
		}
		else{
			[event_list addObject:[exception event]];
		}
	}
	
	return event_list;
}

//値取得
- (History_Data*) get_data{
	History_Data* data = [[History_Data alloc] init];
	
	data.category = self.category;
	data.val = self.val;
	data.memo = self.memo;
	data.person = self.person;
	
	if([self.rrule_freq isEqualToString:@"DAILY"] == YES){
		
	}
	else if([self.rrule_freq isEqualToString:@"WEEKLY"] == YES){
		
	}
	else if([self.rrule_freq isEqualToString:@"MONTHLY"] == YES){
		
	}
	else if([self.rrule_freq isEqualToString:@"YEARLY"] == YES){
		
	}
	else{
		assert(NO);
	}
#warning tbd
	data.period.type = REPEAT_DAY;
	data.period.start_date = self.date;
	data.period.end_date = nil;
	
	for(int i=0; i<7; i++){
		data.period.weekday_list[i] = @NO;
	}
	
	return data;
}

//終了日を変更する
- (void) set_until_date:(NSDate*)date{
	//現在untilが設定されている場合
	if(self.rrule_until != nil){
		//untilを変更する
		self.rrule_until = date;
	}
	//現在countが設定されている場合
	else if(self.rrule_count > 0){
		//countをその日までの数に減らす
		NSArray* event_list = [self recurrence_date_list_with_start:self.date end:date];
		
		self.rrule_count = [event_list count];
	}
	//終了未定の場合
	else{
		//untilを追加する
		self.rrule_until = date;
	}
	
	//recurrence文字列を更新
	self.recurrence = [self get_recurrence_string_from_rrule_val];
}

//現在のrruleの値を元にrecurrence_stringを作成
- (NSString*) get_recurrence_string_from_rrule_val{
	NSString* ret;
	
	NSDateFormatter* date_formatter = [[NSDateFormatter alloc] init];
	[date_formatter setDateFormat:@"yyyyMMdd"];
	
	ret = [NSString stringWithFormat:@"DTSTART;VALUE=DATE:%@\n", [date_formatter stringFromDate:self.date]];
	ret = [NSString stringWithFormat:@"%@DTEND;VALUE=DATE:%@\n", ret, [date_formatter stringFromDate:[NSDate dateWithTimeInterval:3600*24 sinceDate:self.date]]];
	
	ret = [NSString stringWithFormat:@"%@RRULE:FREQ=%@", ret, self.rrule_freq];
	if(self.rrule_until != nil){
		ret = [NSString stringWithFormat:@"%@;UNTIL=%@", ret, [date_formatter stringFromDate:self.rrule_until]];
	}
	if(self.rrule_count > 0){
		ret = [NSString stringWithFormat:@"%@;COUNT=%d", ret, self.rrule_count];
	}
	if(self.rrule_interval > 0){
		ret = [NSString stringWithFormat:@"%@;INTERVAL=%d", ret, self.rrule_interval];
	}
	if(self.rrule_bymonthday != nil){
		ret = [NSString stringWithFormat:@"%@;BYMONTHDAY=%@", ret, self.rrule_bymonthday];
	}
	if(self.rrule_byday != nil){
		ret = [NSString stringWithFormat:@"%@;BYDAY=%@", ret, self.rrule_byday];
	}
	ret = [NSString stringWithFormat:@"%@\n", ret];
	
	ret = [NSString stringWithFormat:@"%@BEGIN:VTIMEZONE\n", ret];
	ret = [NSString stringWithFormat:@"%@TZID:Asia/Tokyo\n", ret];
	ret = [NSString stringWithFormat:@"%@X-LIC-LOCATION:Asia/Tokyo\n", ret];
	ret = [NSString stringWithFormat:@"%@BEGIN:STANDARD\n", ret];
	ret = [NSString stringWithFormat:@"%@TZOFFSETFROM:+0900\n", ret];
	ret = [NSString stringWithFormat:@"%@TZOFFSETTO:+0900\n", ret];
	ret = [NSString stringWithFormat:@"%@TZNAME:JST\n", ret];
	ret = [NSString stringWithFormat:@"%@DTSTART:19700101T000000\n", ret];
	ret = [NSString stringWithFormat:@"%@END:STANDARD\n", ret];
	ret = [NSString stringWithFormat:@"%@END:VTIMEZONE\n", ret];
	
	return ret;
}

- (void) set_data:(History_Data*)data{
	[super set_data:data];
	
	self.recurrence = [data recurrence_string];
	[self parse_recurrence:nil];
}

@end

