//
//  History_Data.m
//  kakeibo2
//
//  Created by hiro on 2013/04/16.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "History_Data.h"
#import "CommonAPI.h"

@implementation History_Data

- (id) init{
	if((self = [super init])){
		self.category = @"";
		self.person = @"";
		self.memo = @"";
		self.period = [[Period_Data alloc] init];
		self.val = 0;
	}
	
	return self;
}

- (NSString*) recurrence_string{
	if(self.period.type == ONE_DAY){
		return nil;
	}
	
	NSString* time_zone_name = [[NSTimeZone systemTimeZone] name];
	
	NSString* ret = [NSString stringWithFormat:@"DTSTART;VALUE=DATE:%@\n", [CommonAPI YYYYMMDD:self.period.start_date]];
	
	if(self.period.type == REPEAT_DAY){
		ret = [NSString stringWithFormat:@"%@RRULE:FREQ=DAILY", ret];
	}
	else if(self.period.type == REPEAT_WEEK){
		ret = [NSString stringWithFormat:@"%@RRULE:FREQ=WEEKLY;BYDAY=", ret];
		
		NSArray* weekday_name_list = @[@"SU", @"MO", @"TU", @"WE", @"TH", @"FR", @"SA"];
		BOOL is_first = YES;
		for(int i=0; i<7; i++){
			if([self.period.weekday_list[i] boolValue] == YES){
				if(is_first == YES){
					is_first = NO;
				}
				else{
					ret = [NSString stringWithFormat:@"%@,", ret];
				}
				ret = [NSString stringWithFormat:@"%@%@", ret, weekday_name_list[i]];
			}
		}
	}
	else if(self.period.type == REPEAT_MONTH){
		ret = [NSString stringWithFormat:@"%@RRULE:FREQ=MONTHLY", ret];
	}
	else if(self.period.type == REPEAT_YEAR){
		ret = [NSString stringWithFormat:@"%@RRULE:FREQ=YEARLY", ret];
	}
	
	if(self.period.end_date != nil){
		ret = [NSString stringWithFormat:@"%@;UNTIL=%@", ret, [CommonAPI YYYYMMDD:self.period.end_date]];
	}
	
	return ret;
	
	//RRULE, EXRULE, RDATE and EXDATE
	//data.period.start_dateから終了日未定で毎日終日の予定
	//NSString* recurrence_string = [NSString stringWithFormat:@"DTSTART;TZID=%@\nDTEND;TZID=%@\nRRULE:FREQ=DAILY", [CommonAPI recurrence_date_string:data.period.start_date], [CommonAPI recurrence_date_string:data.period.start_date]];
	
	//data.period.start_dateから終了日未定で毎週月水金終日の予定
	//NSString* recurrence_string = [NSString stringWithFormat:@"DTSTART;TZID=%@\nDTEND;TZID=%@\nRRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR;", [CommonAPI recurrence_date_string:data.period.start_date], [CommonAPI recurrence_date_string:data.period.start_date]];
	
	//data.period.start_dateからdata.period.end_dateまで毎日終日の予定
	//NSString* recurrence_string = [NSString stringWithFormat:@"DTSTART;TZID=%@\nRRULE:FREQ=DAILY;UNTIL=20130521T220000Z", [CommonAPI recurrence_date_string:data.period.start_date]];
}


@end
