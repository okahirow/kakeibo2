//
//  GoogleCalender.h
//  kakeibo2
//
//  Created by hiro on 2013/04/24.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataCalendar.h"
#import "History_Data.h"

@protocol GoogleCalenderDelegate
@required
- (void) did_get_history_list:(NSArray*)history_list;
@end


@interface GoogleCalender : NSObject

+ (GoogleCalender*) shared_obj;

- (void) sync_db;

- (void) update_db;
- (void) add_history:(History_Data*)data;
- (void) del_history:(GDataEntryCalendarEvent*)event;
- (void) edit_history:(GDataEntryCalendarEvent*)event;

@end
