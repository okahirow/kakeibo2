//
//  CommonAPI.h
//  kakeibo
//
//  Created by hiro on 11/05/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CommonAPI : NSObject {

}

+ (NSString*) money_str:(int)val;
+ (NSString*) money_str_no_unit:(int)val;
+ (BOOL) is_valid_string:(NSString*)string;

+(NSString*) get_day_string:(NSDate*)date;
+(NSString*) get_day_string_with_week:(NSDate*)date;
+(NSString*) weekday_string:(int)weekday;
+(NSString*) recurrence_date_string:(NSDate*)date;
+(NSString*) YYYYMMDD:(NSDate*)date;
+(NSString*) get_date_string:(NSDate*)date;

+(NSComparisonResult)compare_date:(NSDate*)date1 date2:(NSDate*)date2;


+(int)year:(NSDate*)date;
+(int)month:(NSDate*)date;
+(int)day:(NSDate*)date;
+(int)weekday:(NSDate*)date;

+(NSDate*)get_date_year:(int)year month:(int)month day:(int)day;

@end
