//
//  Category_Data.m
//  kakeibo2
//
//  Created by hiro on 2013/03/13.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "DBCategory_Data.h"
#import "DBCategory.h"
#import "CommonAPI.h"


@implementation DBCategory_Data

@dynamic budget_day;
@dynamic budget_month;
@dynamic budget_year;
@dynamic color;
@dynamic name;
@dynamic reseved1;
@dynamic reseved2;
@dynamic reseved3;
@dynamic reseved4;
@dynamic is_income;
@dynamic is_sepalator;
@dynamic category;


//値取得
- (BOOL) is_set_color{
	MyColor* color = [self get_color];
	
	if(color.r == 1.0 && color.g == 1.0 && color.b == 1.0 && color.a == 1.0){
		return NO;
	}
	else{
		return YES;
	}
}

- (MyColor*) get_color{
	MyColor* color = [[MyColor alloc] init];
	
	if([self.color length] != 8){
		return color;
	}
	if([self.color hasPrefix:@"0x"] == false){
		return color;
	}
	unsigned int r, g, b;
	
	[[NSScanner scannerWithString:[self.color substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&r];
	[[NSScanner scannerWithString:[self.color substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&g];
	[[NSScanner scannerWithString:[self.color substringWithRange:NSMakeRange(6, 2)]] scanHexInt:&b];
	
	color.r = r / 255.0f;
	color.g = g / 255.0f;
	color.b = b / 255.0f;
	
	return color;
}

- (Category_Data*) get_data{
	Category_Data* data = [[Category_Data alloc] init];
	
	data.name = self.name;
	data.is_income = self.is_income;
	data.is_sepalator = self.is_sepalator;
	data.color = [self get_color];
	data.budget_year = self.budget_year;
	data.budget_month = self.budget_month;
	data.budget_day = self.budget_day;
	
	return data;
}

//値指定
- (void) set_color:(MyColor*)new_color{
	NSString* color_str = [NSString stringWithFormat:@"0x%2X%2X%2X", (unsigned int)(new_color.r*255), (unsigned int)(new_color.g*255), (unsigned int)(new_color.b*255)];
	self.color = color_str;
}

- (void) set_data:(Category_Data*)data{
	self.name = data.name;
	self.is_income = data.is_income;
	self.is_sepalator = data.is_sepalator;
	[self set_color:data.color];
	self.budget_year = data.budget_year;
	self.budget_month = data.budget_month;
	self.budget_day = data.budget_day;
}


@end
