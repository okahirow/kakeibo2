//
//  MyCategory.h
//  kakeibo2
//
//  Created by hiro on 2013/03/13.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DBCategory_Data.h"
#import "MyColor.h"


@interface DBCategory : NSManagedObject

@property (nonatomic) int32_t cat_id;
@property (nonatomic, retain) NSString * diff_type;
@property (nonatomic) int16_t index;
@property (nonatomic, retain) DBCategory_Data *cur;
@property (nonatomic, retain) DBCategory_Data *org;


//編集
- (void) edit_cur_data:(Category_Data*)data;

- (void) edit_name:(NSString*)new_val;
- (void) edit_type:(NSString*)new_val;
- (void) edit_color:(MyColor*)new_val;

- (void) edit_budget_day:(NSInteger)new_val;
- (void) edit_budget_month:(NSInteger)new_val;
- (void) edit_budget_year:(NSInteger)new_val;

//削除
- (void) del_category;
- (void) del_category_actuary;

//その他
- (BOOL) is_separator;

@end
