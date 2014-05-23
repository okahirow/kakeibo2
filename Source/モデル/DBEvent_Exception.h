//
//  DBEvent_Exception.h
//  kakeibo2
//
//  Created by hiro on 2013/05/02.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DBEvent.h"

@class DBEvent_Recurrence;

@interface DBEvent_Exception : DBEvent

@property (nonatomic, retain) NSDate * org_date;
@property (nonatomic, retain) DBEvent_Recurrence *org_event;

@end
