//
//  Category_Data.h
//  kakeibo2
//
//  Created by hiro on 2013/03/13.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MyColor.h"
#import "Category_Data.h"

@class DBCategory;

@interface DBCategory_Data : NSManagedObject

@property (nonatomic) int32_t budget_day;
@property (nonatomic) int32_t budget_month;
@property (nonatomic) int32_t budget_year;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int32_t reseved1;
@property (nonatomic) int32_t reseved2;
@property (nonatomic, retain) NSString * reseved3;
@property (nonatomic, retain) NSString * reseved4;
@property (nonatomic) BOOL is_income;
@property (nonatomic) BOOL is_sepalator;
@property (nonatomic, retain) DBCategory *category;


//値取得
- (BOOL) is_set_color;
- (MyColor*) get_color;
- (Category_Data*) get_data;

//値指定
- (void) set_color:(MyColor*)new_color;
- (void) set_data:(Category_Data*)data;


@end
