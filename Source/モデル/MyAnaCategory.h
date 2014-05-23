//
//  MyAnaCategory.h
//  kakeibo
//
//  Created by hiro on 11/04/13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyAnaCategory : NSObject

@property (copy) NSString* category_;
@property (copy) NSString* type_;
@property (assign) NSInteger year_;
@property (assign) NSInteger month_;
@property (assign) NSInteger day_;
@property (strong) NSArray* history_list_;
@property (assign) NSInteger total_;
@property (strong) NSArray* day_total_list_;
@property (assign) NSInteger total_multi_;

- (void) update_1_day_total_list;
- (void) update_day_total_list;
- (void) update_month_total_list;

- (void) update_total_multi_:(int)period;

- (BOOL) is_separator;

@end
