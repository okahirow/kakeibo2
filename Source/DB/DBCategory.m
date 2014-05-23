//
//  Category.m
//  kakeibo2
//
//  Created by hiro on 2013/03/13.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "DBCategory.h"
#import "DBCategory_Data.h"
#import "MyModel.h"

@implementation DBCategory

@dynamic cat_id;
@dynamic diff_type;
@dynamic index;
@dynamic cur;
@dynamic org;


//編集
- (void) edit_cur_data:(Category_Data*)data{
	//収支が変わっている場合
	if(data.is_income != self.cur.is_income){
		//収入->支出の場合
		if(self.cur.is_income == YES){
			//収入一覧のindex付け替え
			NSArray* show_category_list = [g_model_ get_show_income_category_list];
			
			for(int i = self.index + 1; i < [show_category_list count]; i++){
				DBCategory* category = show_category_list[i];
				category.index = category.index - 1;
			}
			
			//支出一覧の最後尾のindexにする
			self.index = [[g_model_ get_show_outcome_category_list] count];
		}
		//支出->収入の場合
		else{
			//支出一覧のindex付け替え
			NSArray* show_category_list = [g_model_ get_show_outcome_category_list];
			
			for(int i = self.index + 1; i < [show_category_list count]; i++){
				DBCategory* category = show_category_list[i];
				category.index = category.index - 1;
			}
			
			//収入一覧の最後尾のindexにする
			self.index = [[g_model_ get_show_income_category_list] count];
		}
	}

	[self.cur set_data:data];
	
	//本IDの場合
	if(self.cat_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}


- (void) edit_name:(NSString*)new_val{
	self.cur.name = new_val;
	
	//本IDの場合
	if(self.cat_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}

- (void) edit_type:(NSString*)new_val{
	//self.cur.type = new_val;
	
	//本IDの場合
	if(self.cat_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}

- (void) edit_color:(MyColor*)new_val{
	[self.cur set_color:new_val];
	
	//本IDの場合
	if(self.cat_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}


- (void) edit_budget_day:(NSInteger)new_val{
	self.cur.budget_day = new_val;
	
	//本IDの場合
	if(self.cat_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}

- (void) edit_budget_month:(NSInteger)new_val{
	self.cur.budget_month = new_val;
	
	//本IDの場合
	if(self.cat_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}

- (void) edit_budget_year:(NSInteger)new_val{
	self.cur.budget_year = new_val;
	
	//本IDの場合
	if(self.cat_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}

//削除
- (void) del_category{
	[g_model_ del_category:self];
}

- (void) del_category_actuary{
	[g_model_ del_category_actuary:self];
}


//その他
- (BOOL) is_separator{
	return self.cur.is_sepalator;
}


@end
