//
//  History_HistoryList.h
//  kakeibo
//
//  Created by hiro on 12/06/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History_EditHistory.h"

@interface History_HistoryList : UITableViewController<EditHistory_protocol>

@property (assign) int year;
@property (assign) int month;
@property (assign) int day;
@property (strong) NSArray* history_list;

- (id) init:(int)year_ month:(int)month_ day:(int)day_;
- (void) load_data;

@end
