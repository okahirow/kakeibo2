//
//  MyColor.m
//  PSPTimer
//
//  Created by hiro on 11/02/22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyColor.h"


@implementation MyColor

@synthesize r, g, b, a;

- (id) init{
	self.r = 1.0;
	self.g = 1.0;
	self.b = 1.0;
	self.a = 1.0;
	
	return self;
}

-(id)initWithR:(float)R G:(float)G B:(float)B A:(float)A{
	self.r = R;
	self.g = G;
	self.b = B;
	self.a = A;
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MyColor *clone = [[[self class] allocWithZone:zone] init];
	clone.r = self.r;
	clone.g = self.g;
	clone.b = self.b;
	clone.a = self.a;
	
    return  clone;
}

-(id)initWithColorNo:(int)index{
	switch(index){
		case 0:
			self.r = 41 / 255.0f;
			self.g = 166 / 255.0f;
			self.b = 227 / 255.0f;
			self.a = 1.0f;
			break;
		case 1:
			self.r = 39 / 255.0f;
			self.g = 204 / 255.0f;
			self.b = 37 / 255.0f;
			self.a = 1.0f;
			break;
		case 2:
			self.r = 217 / 255.0f;
			self.g = 83 / 255.0f;
			self.b = 52 / 255.0f;
			self.a = 1.0f;
			break;
		case 3:
			self.r = 227 / 255.0f;
			self.g = 187 / 255.0f;
			self.b = 29 / 255.0f;
			self.a = 1.0f;
			break;
		case 4:
			self.r = 163 / 255.0f;
			self.g = 43 / 255.0f;
			self.b = 237 / 255.0f;
			self.a = 1.0f;
			break;
		case 5:
			self.r = 156 / 255.0f;
			self.g = 217 / 255.0f;
			self.b = 35 / 255.0f;
			self.a = 1.0f;
			break;
		case 6:
			self.r = 227 / 255.0f;
			self.g = 36 / 255.0f;
			self.b = 184 / 255.0f;
			self.a = 1.0f;
			break;
		case 7:
			self.r = 217 / 255.0f;
			self.g = 114 / 255.0f;
			self.b = 37 / 255.0f;
			self.a = 1.0f;
			break;
		case 8:
			self.r = 43 / 255.0f;
			self.g = 57 / 255.0f;
			self.b = 204 / 255.0f;
			self.a = 1.0f;
			break;
		case 9:
			self.r = 36 / 255.0f;
			self.g = 227 / 255.0f;
			self.b = 174 / 255.0f;
			self.a = 1.0f;
			break;
		default:
			self.r = 0 / 255.0f;
			self.g = 0 / 255.0f;
			self.b = 0 / 255.0f;
			self.a = 1.0f;
			break;
	}
	
	return self;
}

-(UIColor*)ui_color{
	return [UIColor colorWithRed:self.r green:self.g blue:self.b alpha:self.a];
}


@end
