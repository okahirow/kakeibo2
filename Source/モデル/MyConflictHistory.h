//
//  MyConflictHistory.h
//  kakeibo
//
//  Created by hiro on 11/04/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBHistory.h"
#import "MyDBHistory.h"

@interface MyConflictHistory : NSObject

@property (strong) DBHistory* local_;
@property (strong) MyDBHistory* db_;
@property (assign) Boolean is_apply_local_;

@end
