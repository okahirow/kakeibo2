//
//  MyCircleData.m
//  kakeibo
//
//  Created by hiro on 12/06/02.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyCircleData.h"

@implementation MyCircleData

@synthesize rate_, color_;

- (id) init{
	if((self = [super init])){
		self.rate_ = 0.0;
		self.color_ = nil;
	}
	
	return self;
}


@end
