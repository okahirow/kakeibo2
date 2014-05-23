//
//  History_Data.h
//  kakeibo2
//
//  Created by hiro on 2013/04/16.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Period_Data.h"

@interface History_Data : NSObject

@property (strong) NSString * category;
@property (strong) NSString * person;
@property (strong) NSString * memo;
@property (assign) int32_t val;
@property (strong) Period_Data* period;

- (NSString*) recurrence_string;

@end
