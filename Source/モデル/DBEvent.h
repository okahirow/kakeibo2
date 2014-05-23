//
//  DBEvent.h
//  kakeibo2
//
//  Created by hiro on 2013/05/02.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Event.h"
#import "History_Data.h"

@interface DBEvent : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * event_status;
@property (nonatomic, retain) NSString * html_link;
@property (nonatomic, retain) NSString * memo;
@property (nonatomic, retain) NSString * person;
@property (nonatomic, retain) NSString * sync_status;
@property (nonatomic) int32_t val;
@property (nonatomic, retain) NSString * eTag;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSDate * last_update;

- (Event*) event;

//値取得
- (History_Data*) get_data;

//値指定
- (void) set_data:(History_Data*)data;

@end
