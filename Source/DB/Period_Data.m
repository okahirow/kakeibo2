//
//  Period_Data.m
//  kakeibo2
//
//  Created by hiro on 2013/04/18.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "Period_Data.h"

@implementation Period_Data

- (id) init{
	if((self = [super init])){
		self.type = ONE_DAY;
		self.start_date = [NSDate date];
		self.end_date = nil;
		self.weekday_list = [@[@NO, @NO, @NO, @NO, @NO, @NO, @NO] mutableCopy];
	}
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Period_Data *clone = [[[self class] allocWithZone:zone] init];
	clone.type = self.type;
	clone.start_date = [self.start_date copy];
	clone.end_date = [self.end_date copy];
	clone.weekday_list = [self.weekday_list mutableCopy];
	
    return  clone;
}

@end
