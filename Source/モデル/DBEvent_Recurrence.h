//
//  DBEvent_Recurrence.h
//  kakeibo2
//
//  Created by hiro on 2013/05/03.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DBEvent.h"

@class DBEvent_Exception;

@interface DBEvent_Recurrence : DBEvent

@property (nonatomic, retain) NSString * recurrence;
@property (nonatomic, retain) NSString * rrule_freq;
@property (nonatomic, retain) NSDate *  rrule_until;
@property (nonatomic) int16_t rrule_interval;
@property (nonatomic) int16_t rrule_count;
@property (nonatomic, retain) NSString * rrule_bymonthday;
@property (nonatomic, retain) NSString * rrule_byday;

@property (nonatomic, retain) NSSet *exceptions;

- (BOOL) parse_recurrence:(NSManagedObjectContext*) context;
- (NSArray*) recurrence_date_list_with_start:(NSDate*)start_date end:(NSDate*)end_date;
- (NSArray*) event_list_with_start:(NSDate*)start_date end:(NSDate*)end_date;

- (void) set_until_date:(NSDate*)date;

@end

@interface DBEvent_Recurrence (CoreDataGeneratedAccessors)

- (void)addExceptionsObject:(DBEvent_Exception *)value;
- (void)removeExceptionsObject:(DBEvent_Exception *)value;
- (void)addExceptions:(NSSet *)values;
- (void)removeExceptions:(NSSet *)values;

@end
