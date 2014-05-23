//
//  MyConflictCustomAna.h
//  kakeibo
//
//  Created by hiro on 11/04/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBCustomAna.h"
#import "MyDBCustomAna.h"

@interface MyConflictCustomAna : NSObject

@property (strong) DBCustomAna* local_;
@property (strong) MyDBCustomAna* db_;
@property (assign) Boolean is_apply_local_;

@end
