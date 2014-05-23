//
//  Event.h
//  kakeibo2
//
//  Created by hiro on 2013/05/08.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBEvent;

@interface Event : NSObject

@property (strong) NSDate* date;
@property (strong) DBEvent* db_event;

@end
