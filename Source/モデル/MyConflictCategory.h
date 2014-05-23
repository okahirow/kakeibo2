//
//  MyConflictCategory.h
//  kakeibo
//
//  Created by hiro on 11/04/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBCategory.h"
#import "MyDBCategory.h"

@interface MyConflictCategory : NSObject

@property (strong) DBCategory* local_;
@property (strong) MyDBCategory* db_;
@property (assign) Boolean is_apply_local_;

@end
