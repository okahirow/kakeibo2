//
//  DBHistory_Data.m
//  kakeibo2
//
//  Created by hiro on 2013/04/21.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "DBHistory_Data.h"
#import "DBHistory.h"
#import "History_Data.h"
#import "CommonAPI.h"

@implementation DBHistory_Data

@dynamic category;
@dynamic year;
@dynamic month;
@dynamic day;
@dynamic val;
@dynamic memo;
@dynamic person;

@dynamic repeat_type;
@dynamic repeat_end_enable;
@dynamic repeat_end_year;
@dynamic repeat_end_month;
@dynamic repeat_end_day;
@dynamic repeat_weekday_flag;

@dynamic reserved1;
@dynamic reserved2;
@dynamic reserved3;
@dynamic reserved4;

@dynamic history;

//値取得
- (History_Data*) get_data{
	History_Data* data = [[History_Data alloc] init];
	
	data.category = self.category;
	data.val = self.val;
	data.memo = self.memo;
	data.person = self.person;
	data.period.type = self.repeat_type;
	
	data.period.start_date = [CommonAPI get_date_year:self.year month:self.month day:self.day];
	
	if(self.repeat_end_enable == YES){
		data.period.end_date = [CommonAPI get_date_year:self.repeat_end_year month:self.repeat_end_month day:self.repeat_end_day];
	}
	else{
		data.period.end_date = nil;
	}
	
	for(int i=0; i<7; i++){
		int flag = self.repeat_weekday_flag & (1 << i);
		
		if(flag == 0){
			data.period.weekday_list[i] = @NO;
		}
		else{
			data.period.weekday_list[i] = @YES;
		}
	}
	
	
	return data;
}

//値指定
- (void) set_data:(History_Data*)data{
	self.category = data.category;
	self.year = [CommonAPI year:data.period.start_date];
	self.month = [CommonAPI month:data.period.start_date];
	self.day = [CommonAPI day:data.period.start_date];
	self.val = data.val;
	self.memo = data.memo;
	self.person = data.person;
	
	self.repeat_type = data.period.type;
	if(data.period.end_date == nil){
		self.repeat_end_enable = NO;
	}
	else{
		self.repeat_end_enable = YES;
		self.repeat_end_year = [CommonAPI year:data.period.end_date];
		self.repeat_end_month = [CommonAPI month:data.period.end_date];
		self.repeat_end_day = [CommonAPI day:data.period.end_date];
	}
	self.repeat_weekday_flag = 0;
	for(int i=0; i<7; i++){
		if([data.period.weekday_list[i] boolValue] == YES){
			self.repeat_weekday_flag = self.repeat_weekday_flag | (1 << i);
		}
	}	
}


@end
