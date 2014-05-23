//
//  Category_Data.h
//  kakeibo2
//
//  Created by hiro on 2013/03/25.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyColor.h"

@interface Category_Data : NSObject

@property (nonatomic, copy) NSString * name;
@property (nonatomic) BOOL is_income;
@property (nonatomic) BOOL is_sepalator;
@property (nonatomic, copy) MyColor * color;

@property (nonatomic) int32_t budget_year;
@property (nonatomic) int32_t budget_month;
@property (nonatomic) int32_t budget_day;

@property (nonatomic) int32_t reseved1;
@property (nonatomic) int32_t reseved2;
@property (nonatomic, copy) NSString * reseved3;
@property (nonatomic, copy) NSString * reseved4;

@end
