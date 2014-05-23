//
//  History_DayList.h
//  kakeibo
//
//  Created by hiro on 12/06/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface History_DayList : UITableViewController{
	int year;
	int month;
	int last_day;
}

- (id) init:(int)year_ month:(int)month_;


@end
