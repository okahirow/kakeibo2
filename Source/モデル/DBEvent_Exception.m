//
//  DBEvent_Exception.m
//  kakeibo2
//
//  Created by hiro on 2013/05/02.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "DBEvent_Exception.h"
#import "DBEvent_Recurrence.h"


@implementation DBEvent_Exception

@dynamic org_date;
@dynamic org_event;

- (Event*) event{
	Event* event = [[Event alloc] init];
	event.date = self.date;
	event.db_event = self;
	
	return event;
}

//値取得
- (History_Data*) get_data{
	History_Data* data = [[History_Data alloc] init];
	
	data.category = self.category;
	data.val = self.val;
	data.memo = self.memo;
	data.person = self.person;
	
	data.period.type = ONE_DAY;
	data.period.start_date = self.date;
	data.period.end_date = nil;
	
	for(int i=0; i<7; i++){
		data.period.weekday_list[i] = @NO;
	}
	
	return data;
}

- (void) set_data:(History_Data*)data{
	[super set_data:data];
}


@end
