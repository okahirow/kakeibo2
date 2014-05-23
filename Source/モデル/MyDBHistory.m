//
//  MyDBHistory.m
//  kakeibo
//
//  Created by hiro on 11/04/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyDBHistory.h"


@implementation MyDBHistory
@synthesize id_, year_, month_, day_, category_, val_, memo_;


//日付比較
- (NSComparisonResult)compare:(MyDBHistory*)data{
	if((data.year_ * 10000 + data.month_ * 100 + data.day_) > (self.year_ * 10000 + self.month_ * 100 + self.day_)){
		return NSOrderedAscending;
	}
	else if((data.year_ * 10000 + data.month_ * 100 + data.day_) == (self.year_ * 10000 + self.month_ * 100 + self.day_)){
		return NSOrderedSame;
	}
	else{
		return NSOrderedDescending;
	}
}

-(NSString *) description {
    return [NSString stringWithFormat:@"<MyDBHistory: %p> {\n  his_id = %d;\n  category = %@;\n  year = %d;\n  month = %d;\n  day = %d;\n  val = %d;\n  memo = %@;\n}",
            self, self.id_, self.category_, self.year_, self.month_, self.day_, self.val_, self.memo_];
}
			
@end
