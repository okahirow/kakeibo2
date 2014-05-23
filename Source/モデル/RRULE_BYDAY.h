//
//  DBRRULE_BYDAY.h
//  kakeibo2
//
//  Created by hiro on 2013/05/03.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RRULE_BYDAY : NSObject

@property (nonatomic) int16_t weekday_no;
@property (nonatomic, strong) NSMutableSet* ordwk_set;

@end
