//
//  Period_Data.h
//  kakeibo2
//
//  Created by hiro on 2013/04/18.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {ONE_DAY, REPEAT_DAY, REPEAT_WEEK, REPEAT_MONTH, REPEAT_YEAR} Period_Type;

@interface Period_Data : NSObject<NSCopying>

@property(assign) Period_Type type;
@property(strong) NSDate* start_date;
@property(strong) NSDate* end_date;
@property(strong) NSMutableArray* weekday_list;

@end

@protocol SelectPeriodDataDelegate
@required
- (void) period_setting_selected:(Period_Data*)data;
@end
