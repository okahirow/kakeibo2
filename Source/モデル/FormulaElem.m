//
//  FormulaElem.m
//  kakeibo
//
//  Created by hiro on 11/04/18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FormulaElem.h"


@implementation FormulaElem
@synthesize type_, category_, val_;

- (id) init{
	type_ = nil;
	category_ = nil;
	val_ = 0.0f;
	
	return self;
}


@end
