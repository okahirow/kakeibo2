//
//  CommonAPI.m
//  kakeibo
//
//  Created by hiro on 11/05/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommonAPI.h"


@implementation CommonAPI

+ (NSString*) money_str_no_unit:(int)val{
	NSString* ret = @"";
	BOOL is_minus = false;
	if(val < 0){
		is_minus = true;
		val = -val;
	}
	
	while(TRUE){
		int amari = val % 1000;
		val = val / 1000;
		
		if(val == 0){
			ret = [NSString stringWithFormat:@"%d%@", amari, ret];
			break;
		}
		else{
			ret = [NSString stringWithFormat:@",%03d%@", amari, ret];
		}
	}
	
	if(is_minus == true){
		ret = [NSString stringWithFormat:@"-%@", ret];
	}
	else{
		ret = [NSString stringWithFormat:@"%@", ret];
	}
	
	return ret;

}

+ (NSString*) money_str:(int)val{
	NSString* ret = @"";
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	ret = [NSString stringWithFormat:@"%@%@", [settings stringForKey:@"MONEY_UNIT"], [self money_str_no_unit:val]];
	
	return ret;
}

+ (BOOL) is_valid_string:(NSString*)string{
	NSRange searchResult = [string rangeOfString:@"\""];
	if(searchResult.location != NSNotFound){
		return false;
	}
	
	searchResult = [string rangeOfString:@","];
	if(searchResult.location != NSNotFound){
		return false;
	}
	
	return true;
}

+(NSString*) get_day_string:(NSDate*)date{
	if(date == nil){
		return @"nil";
	}
	
	NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *comp = [cal components:unitFlags fromDate:date];
	
	return [NSString stringWithFormat:@"%04d/%02d/%02d", [comp year], [comp month], [comp day]];
}

+(NSString*) get_day_string_with_week:(NSDate*)date{
	NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit;
	NSDateComponents *comp = [cal components:unitFlags fromDate:date];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
    NSString *weekdaySymbol = [[formatter shortWeekdaySymbols] objectAtIndex:[comp weekday] - 1];
	
	return [NSString stringWithFormat:@"%04d/%02d/%02d(%@)", [comp year], [comp month], [comp day], weekdaySymbol];
}

+(NSString*) get_date_string:(NSDate*)date{
	if(date == nil){
		return @"nil";
	}
	
	NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
	NSDateComponents *comp = [cal components:unitFlags fromDate:date];
	
	return [NSString stringWithFormat:@"%04d/%02d/%02d %02d:%02d", [comp year], [comp month], [comp day], [comp hour], [comp minute]];
}

+(NSString*) weekday_string:(int)weekday{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];

    return [[formatter shortWeekdaySymbols] objectAtIndex:weekday - 1];
}

+(NSString*) recurrence_date_string:(NSDate*)date{
	NSString* time_zone_name = [[NSTimeZone systemTimeZone] name];
	
	NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *comp = [cal components:unitFlags fromDate:date];
	
	return [NSString stringWithFormat:@"%@:%04d%02d%02d", time_zone_name, [comp year], [comp month], [comp day]];
}

+(NSString*) YYYYMMDD:(NSDate*)date{
	NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *comp = [cal components:unitFlags fromDate:date];
	
	return [NSString stringWithFormat:@"%04d%02d%02d", [comp year], [comp month], [comp day]];
}

+(NSComparisonResult)compare_date:(NSDate*)date1 date2:(NSDate*)date2{
	NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *comp1 = [cal components:unitFlags fromDate:date1];
	NSDateComponents *comp2 = [cal components:unitFlags fromDate:date2];
	
	int my_date = [comp1 year] * 10000 + [comp1 month] * 100 + [comp1 day];
	int target_date = [comp2 year] * 10000 + [comp2 month] * 100 + [comp2 day];
	
	if(my_date < target_date){
		return NSOrderedAscending;
	}
	else if(my_date == target_date){
		return NSOrderedSame;
	}
	else{
		return NSOrderedDescending;
	}
}

+(int)year:(NSDate*)date{
	NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *comp = [cal components:unitFlags fromDate:date];
	
	return [comp year];
}

+(int)month:(NSDate*)date{
	NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *comp = [cal components:unitFlags fromDate:date];
	
	return [comp month];
}

+(int)day:(NSDate*)date{
	NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *comp = [cal components:unitFlags fromDate:date];
	
	return [comp day];
}

+(int)weekday:(NSDate*)date{
	NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit;
	NSDateComponents *comp = [cal components:unitFlags fromDate:date];
	
	return [comp weekday];
}

+(NSDate*)get_date_year:(int)year month:(int)month day:(int)day{
	NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:year];
	[comps setMonth:month];
	[comps setDay:day];
	
	return [cal dateFromComponents:comps];
}

@end
