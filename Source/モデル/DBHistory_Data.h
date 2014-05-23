//
//  DBHistory_Data.h
//  kakeibo2
//
//  Created by hiro on 2013/04/21.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "History_Data.h"

@class DBHistory;

@interface DBHistory_Data : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic) int16_t year;
@property (nonatomic) int16_t month;
@property (nonatomic) int16_t day;
@property (nonatomic) int32_t val;
@property (nonatomic, retain) NSString * memo;
@property (nonatomic, retain) NSString * person;

@property (nonatomic) int16_t repeat_type;
@property (nonatomic) BOOL repeat_end_enable;
@property (nonatomic) int16_t repeat_end_year;
@property (nonatomic) int16_t repeat_end_month;
@property (nonatomic) int16_t repeat_end_day;
@property (nonatomic) int16_t repeat_weekday_flag;

@property (nonatomic) int32_t reserved1;
@property (nonatomic) int32_t reserved2;
@property (nonatomic, retain) NSString * reserved3;
@property (nonatomic, retain) NSString * reserved4;

@property (nonatomic, retain) DBHistory *history;

//値取得
- (History_Data*) get_data;

//値指定
- (void) set_data:(History_Data*)data;

@end
