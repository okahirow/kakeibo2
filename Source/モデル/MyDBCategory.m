//
//  MyDBCategory.m
//  kakeibo
//
//  Created by hiro on 11/04/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyDBCategory.h"


@implementation MyDBCategory
@synthesize id_, name_, index_;


//カテゴリーのID比較
- (NSComparisonResult)compare:(MyDBCategory*)data{
	if(data.id_ > self.id_){
		return NSOrderedAscending;
	}
	else if(data.id_ > self.id_){
		return NSOrderedSame;
	}
	else{
		return NSOrderedDescending;
	}
}

@end