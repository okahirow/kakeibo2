//
//  CustomAna_Data.h
//  kakeibo2
//
//  Created by hiro on 2013/03/13.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MyColor.h"


@class DBCustomAna;

@interface DBCustomAna_Data : NSManagedObject

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * formula;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int32_t reserved1;
@property (nonatomic) int32_t reserved2;
@property (nonatomic, retain) NSString * reserved3;
@property (nonatomic, retain) NSString * reserved4;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * unit;
@property (nonatomic, retain) DBCustomAna *custom_ana;


//値取得
- (MyColor*) get_color;

//値指定
- (void) set_color:(MyColor*)new_color;


@end
