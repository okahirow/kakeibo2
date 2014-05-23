//
//  CustomAna_Data.m
//  kakeibo2
//
//  Created by hiro on 2013/03/13.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "DBCustomAna_Data.h"
#import "DBCustomAna.h"


@implementation DBCustomAna_Data

@dynamic color;
@dynamic formula;
@dynamic name;
@dynamic reserved1;
@dynamic reserved2;
@dynamic reserved3;
@dynamic reserved4;
@dynamic type;
@dynamic unit;
@dynamic custom_ana;


//値取得
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

//値指定
- (void) set_color:(MyColor*)new_color{
	NSString* color_str = [NSString stringWithFormat:@"0x%2X%2X%2X", (unsigned int)(new_color.r*255), (unsigned int)(new_color.g*255), (unsigned int)(new_color.b*255)];
	self.color = color_str;
}


@end
