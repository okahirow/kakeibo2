//
//  Section_Data.m
//  kakeibo2
//
//  Created by hiro on 2013/04/10.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "Section_Data.h"

@implementation Section_Data

- (id) init{
	if((self = [super init])){
		self.category_list = [[NSMutableArray alloc] init];
	}
	
	return self;
}


@end
