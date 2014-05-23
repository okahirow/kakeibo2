//
//  History.m
//  kakeibo2
//
//  Created by hiro on 2013/03/13.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "DBHistory.h"
#import "MyModel.h"

@implementation DBHistory

@dynamic diff_type;
@dynamic his_id;
@dynamic cur;
@dynamic org;


//編集
- (void) edit_date:(NSInteger)year month:(NSInteger)month day:(NSInteger)day{
	self.cur.year = year;
	self.cur.month = month;
	self.cur.day = day;
	
	//本IDの場合
	if(self.his_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}


- (void) edit_category:(NSString*)new_cat{
	self.cur.category = new_cat;
	
	//本IDの場合
	if(self.his_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}


- (void) edit_val:(NSInteger)new_val{
	self.cur.val = new_val;
	
	//本IDの場合
	if(self.his_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}


- (void) edit_memo:(NSString*)new_memo{
	self.cur.memo = new_memo;
	
	//本IDの場合
	if(self.his_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}

- (void) edit_person:(NSString*)new_person{
	self.cur.person = new_person;
	
	//本IDの場合
	if(self.his_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}


//削除
- (void) del_history{
	[g_model_ del_history:self];
}


- (void) del_history_acctuary{
	[g_model_ del_history_actuary:self];
}


//ソート
- (NSComparisonResult)compare_date_ascend:(DBHistory*)target {
	int my_date = self.cur.year * 10000 + self.cur.month * 100 + self.cur.day;
	int target_date = target.cur.year * 10000 + target.cur.month * 100 + target.cur.day;
	
	if(my_date < target_date){
		return NSOrderedAscending;
	}
	else if(my_date == target_date){
		return NSOrderedSame;
	}
	else{
		return NSOrderedDescending;
	}
}

- (NSComparisonResult)compare_date_descend:(DBHistory*)target {
	int my_date = self.cur.year * 10000 + self.cur.month * 100 + self.cur.day;
	int target_date = target.cur.year * 10000 + target.cur.month * 100 + target.cur.day;
	
	if(my_date < target_date){
		return NSOrderedDescending;
	}
	else if(my_date == target_date){
		return NSOrderedSame;
	}
	else{
		return NSOrderedAscending;
	}
}

@end
