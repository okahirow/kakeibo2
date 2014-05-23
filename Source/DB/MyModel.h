//
//  MyModel.h
//  kakeibo
//
//  Created by hiro on 11/03/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "DBCategory.h"
#import "DBHistory.h"
#import "DBCustomAna.h"
#import "Category_Data.h"
#import <GData.h>
#import "DBEvent.h"
#import "DBEvent_Normal.h"
#import "DBEvent_Recurrence.h"
#import "DBEvent_Exception.h"


@interface MyModel : NSObject

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void) init_model;
-(void) save_model;
-(BOOL) is_old_data:(NSDate*)data_date;


//カテゴリー用
- (NSArray*) get_category_list_with_pred:(NSPredicate*)predicate;
- (NSArray*) get_show_income_category_list;
- (NSArray*) get_show_outcome_category_list;

- (void) add_category2:(Category_Data*)data;
- (void) add_category2_actuary:(Category_Data*)data cat_id:(NSInteger)cat_id index:(NSInteger)index;

- (void) del_category2:(DBCategory*)target;
- (void) swap_category2:(BOOL)is_income from_index:(NSInteger)from_index to_index:(NSInteger)to_index;

- (BOOL) is_exist_category2:(NSString*)name without:(DBCategory*)without;



- (NSInteger) get_all_category_num;
- (NSInteger) get_show_category_num;

- (void) add_default_category;

- (NSArray*) get_all_category_list;
- (NSArray*) get_show_category_list;
- (NSArray*) get_category_list_with_diff_type:(NSString*)diff_type;
- (DBCategory*) get_category_with_id:(NSInteger) cat_id;

- (void) add_category:(NSString*)name;
- (void) add_category_actuary:(NSString*)name cat_id:(NSInteger)cat_id index:(NSInteger)index;
- (void) swap_category:(NSInteger)from_index to_index:(NSInteger)to_index;
- (void) del_category:(DBCategory*)target;
- (void) del_category_actuary:(DBCategory*)target;

- (void) del_all_category_actuary;

- (bool) is_exist_category:(NSString*) name;

//イベント用
- (void) add_event:(GDataEntryCalendarEvent*)event;
- (NSArray*) get_all_event_list;
- (NSArray*) get_all_event_normal_list;
- (NSArray*) get_all_event_recurrence_list;
- (NSArray*) get_all_event_exception_list;
- (void) del_all_event_actuary;
- (DBEvent_Recurrence*) get_event_recurrence:(NSString*)identifier;
- (NSArray*) event_instance_list_with_start:(NSDate*)start_date end:(NSDate*)end_date;
- (DBEvent*) get_event_with_id:(NSString*)identifier;
- (void) del_event_actually:(DBEvent*)event;
- (void) del_normal_event:(DBEvent_Normal*)event;
- (void) del_exception_event:(DBEvent_Exception*)event;
- (void) del_recurrence_event_one_day:(DBEvent_Recurrence*)event date:(NSDate*)date;
- (void) del_recurrence_event_all:(DBEvent_Recurrence*)event;
- (void) del_recurrent_event_from_date:(DBEvent_Recurrence*)event date:(NSDate*)date;
- (void) update_event_actually:(GDataEntryCalendarEvent*)event;
- (NSArray*) get_local_added_event;
- (NSArray*) get_local_edited_event;
- (NSArray*) get_local_deleted_event;

- (void) edit_normal_event:(DBEvent_Normal*)event history_data:(History_Data*)new_data;
- (void) edit_exception_event:(DBEvent_Exception*)event history_data:(History_Data*)new_data;
- (void) edit_recurrence_event_all:(DBEvent_Recurrence*)event history_data:(History_Data*)new_data;
- (void) edit_recurrence_event_one_day:(DBEvent_Recurrence*)event history_data:(History_Data*)new_data org_date:(NSDate*)org_date;
- (void) edit_recurrence_event_from_date:(DBEvent_Recurrence*)event history_data:(History_Data*)new_data date:(NSDate*)date;


//履歴用
- (void) add_history2:(History_Data*)data;
- (void) add_history3:(History_Data*)data;

- (NSInteger) get_all_history_num;
- (NSInteger) get_show_history_num;

- (NSArray*) get_all_history_list;
- (NSArray*) get_show_history_list;
- (NSArray*) get_history_list_with_diff_type:(NSString*)diff_type;
- (DBHistory*) get_history_with_id:(NSInteger) his_id;
- (NSArray*) get_history_list_with_pred:(NSPredicate*)predicate;
- (NSArray*) get_history_list_with_pred_cat_order:(NSPredicate*)predicate;

- (void) add_history:(NSInteger)year month:(NSInteger)month day:(NSInteger)day category:(NSString*)category val:(NSInteger)val memo:(NSString*)memo;
- (void) add_history_actuary:(NSInteger)his_id year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day category:(NSString*)category val:(NSInteger)val memo:(NSString*)memo;
- (void) del_history:(DBHistory*)target;
- (void) del_history_actuary:(DBHistory*)target;

- (void) del_all_history_actuary;

//カスタム集計方法
- (NSInteger) get_all_custom_ana_num;
- (NSInteger) get_show_custom_ana_num;

- (NSArray*) get_all_custom_ana_list;
- (NSArray*) get_show_custom_ana_list;
- (NSArray*) get_use_custom_ana_list;
- (NSArray*) get_custom_ana_list_with_diff_type:(NSString*)diff_type;
- (DBCustomAna*) get_custom_ana_with_id:(NSInteger) ana_id;

- (void) add_custom_ana:(NSString*)name formula:(NSString*)formula unit:(NSString*)unit is_show:(BOOL)is_show;
- (void) add_custom_ana_actuary:(NSString*)name formula:(NSString*)formula unit:(NSString*)unit is_show:(BOOL)is_show ana_id:(NSInteger)ana_id index:(NSInteger)index;
- (void) swap_custom_ana:(NSInteger)from_index to_index:(NSInteger)to_index;
- (void) del_custom_ana:(DBCustomAna*)target;
- (void) del_custom_ana_actuary:(DBCustomAna*)target;

- (void) del_all_custom_ana_actuary;


@end


//グローバル変数で定義
MyModel* g_model_;