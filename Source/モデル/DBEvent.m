//
//  DBEvent.m
//  kakeibo2
//
//  Created by hiro on 2013/05/02.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "DBEvent.h"


@implementation DBEvent

@dynamic date;
@dynamic category;
@dynamic event_status;
@dynamic html_link;
@dynamic memo;
@dynamic person;
@dynamic sync_status;
@dynamic val;
@dynamic eTag;
@dynamic identifier;
@dynamic last_update;

- (Event*) event{
	return nil;
}

- (void) set_data:(History_Data*)data{
	self.date = data.period.start_date;
	self.category = data.category;
	self.val = data.val;
	self.memo = data.memo;
	self.person = data.person;
	
	self.last_update = [NSDate date];
}

@end
