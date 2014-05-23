//
//  History.h
//  kakeibo2
//
//  Created by hiro on 2013/03/13.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DBHistory_Data.h"


@interface DBHistory : NSManagedObject

@property (nonatomic, retain) NSString * diff_type;
@property (nonatomic) int32_t his_id;
@property (nonatomic, retain) DBHistory_Data *cur;
@property (nonatomic, retain) DBHistory_Data *org;

//編集(外部向け)
- (void) edit_date:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
- (void) edit_category:(NSString*)new_cat;
- (void) edit_val:(NSInteger)new_val;
- (void) edit_memo:(NSString*)new_memo;
- (void) edit_person:(NSString*)new_person;

//削除
- (void) del_history;
- (void) del_history_acctuary;

//ソート
- (NSComparisonResult)compare_date_ascend:(DBHistory*)target;
- (NSComparisonResult)compare_date_descend:(DBHistory*)target;

@end
