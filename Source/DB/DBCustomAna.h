//
//  CustomAna.h
//  kakeibo2
//
//  Created by hiro on 2013/03/13.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DBCustomAna_Data.h"
#import "MyColor.h"


@interface DBCustomAna : NSManagedObject

@property (nonatomic) int32_t ana_id;
@property (nonatomic, retain) NSString * diff_type;
@property (nonatomic) int16_t index;
@property (nonatomic) BOOL is_show;
@property (nonatomic, retain) DBCustomAna_Data *cur;
@property (nonatomic, retain) DBCustomAna_Data *org;

@property (nonatomic) NSInteger total;
@property (nonatomic) NSInteger total_multi;
@property (nonatomic) BOOL is_total_error;

//編集
- (void) edit_name:(NSString*)new_name;
- (void) edit_formula:(NSString*)new_formula;
- (void) edit_unit:(NSString*)new_unit;

- (void) edit_type:(NSString*)new_type;
- (void) edit_color:(MyColor*)new_color;

//削除
- (void) del_custom_ana;
- (void) del_custom_ana_actuary;

//チェック
+ (BOOL) is_valid_formula:(NSString*)formula;

//計算
+ (NSArray*) get_formula_elems:(NSString*)formula;
+ (NSArray*) get_gyaku_porand_elems:(NSString*)formula;
- (void) calc_formula:(int)year month:(int)month day:(int)day period:(int)period is_multi:(BOOL)is_multi;

//セパレータ
- (BOOL) is_separator;

@end
