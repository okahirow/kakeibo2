//
//  Category_Data.m
//  kakeibo2
//
//  Created by hiro on 2013/03/25.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "Category_Data.h"

@implementation Category_Data

- (id) init{
	if((self = [super init])){
		self.name = @"";
		self.is_income = NO;
		self.is_sepalator = NO;
		self.color = [[MyColor alloc] initWithR:1 G:1 B:1 A:1];
		self.budget_year = 0;
		self.budget_month = 0;
		self.budget_day = 0;
	}
	
	return self;
}

@end
