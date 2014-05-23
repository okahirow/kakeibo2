//
//  MyDBCustomAna.m
//  kakeibo
//
//  Created by hiro on 11/04/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyDBCustomAna.h"


@implementation MyDBCustomAna
@synthesize id_, name_, formula_, index_, is_show_, unit_;


//カスタム集計のID比較
- (NSComparisonResult)compare:(MyDBCustomAna*)data{
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
