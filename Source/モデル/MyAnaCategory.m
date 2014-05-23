//
//  MyAnaCategory.m
//  kakeibo
//
//  Created by hiro on 11/04/13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyAnaCategory.h"
#import "DBHistory.h"
#import "MyModel.h"

@implementation MyAnaCategory
@synthesize category_, type_, history_list_, total_, day_total_list_, year_, month_, day_, total_multi_;

- (id) init{
	if((self = [super init])){
		self.category_ = nil;
		self.history_list_ = nil;
		self.day_total_list_ = nil;
	}
	
	return self;
}


//当月の日数を取得
- (int) get_day_num_in_month:(NSInteger)year month:(NSInteger)month{	
	//月末の日を取得
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:year];
	[comps setMonth:month];
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDate *date = [cal dateFromComponents:comps];
	
	// inUnit:で指定した単位（月）の中で、rangeOfUnit:で指定した単位（日）が取り得る範囲
	NSRange range = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
	NSInteger max = range.length;
	
	return max;
}

- (int) get_day_num_in_month{
	return [self get_day_num_in_month:self.year_ month:self.month_];
}

- (void) update_day_total_list{
	NSMutableArray* tmp_list = [[NSMutableArray alloc] init];
	
	if(self.history_list_ == nil){
		return;
	}
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
	if(month_end_day == 0){
		int day_num = [self get_day_num_in_month];
		
		//history_listは日付の降順で並んでいる前提
		int history_index = [self.history_list_ count] - 1;
		
		for(int day=1; day <= day_num; day ++){
			int day_total = 0;
			
			while(true){
				if(history_index < 0){
					break;
				}
				
				DBHistory* history = (self.history_list_)[history_index];
				
				if(history.cur.day == day){
					day_total += history.cur.val;
					history_index --;
				}
				else{
					break;
				}
			}
			
			[tmp_list addObject:@(day_total)];
		}
	}
	else{
		int prev_month_day_num;
		if(self.month_ == 1){
			prev_month_day_num = [self get_day_num_in_month:self.year_ - 1 month:12];
		}
		else{
			prev_month_day_num = [self get_day_num_in_month:self.year_ month:self.month_ - 1];
		}
		int month_day_num = [self get_day_num_in_month:self.year_ month:self.month_];
		
		//history_listは日付の降順で並んでいる前提
		int history_index = [self.history_list_ count] - 1;
		
		//先月
		for(int day=month_end_day+1; day<=prev_month_day_num; day++){
			int day_total = 0;
			
			while(true){
				if(history_index < 0){
					break;
				}
				
				DBHistory* history = (self.history_list_)[history_index];
				
				if(history.cur.day == day){
					day_total += history.cur.val;
					history_index --;
				}
				else{
					break;
				}
			}
			
			[tmp_list addObject:@(day_total)];
		}
		
		//今月
		for(int day=1; day<=month_end_day && day<=month_day_num; day++){
			int day_total = 0;
			
			while(true){
				if(history_index < 0){
					break;
				}
				
				DBHistory* history = (self.history_list_)[history_index];
				
				if(history.cur.day == day){
					day_total += history.cur.val;
					history_index --;
				}
				else{
					break;
				}
			}
			
			[tmp_list addObject:@(day_total)];
		}
	}
	
	self.day_total_list_ = tmp_list;
}

- (void) update_1_day_total_list{
	NSMutableArray* tmp_list = [[NSMutableArray alloc] init];
	
	if(self.history_list_ == nil){
		return;
	}
	
	//history_listは日付の降順で並んでいる前提
	int history_index = [self.history_list_ count] - 1;
	
	int day_total = 0;
	
	while(true){
		if(history_index < 0){
			break;
		}
		
		DBHistory* history = (self.history_list_)[history_index];
		
		if(history.cur.day == day_){
			day_total += history.cur.val;
			history_index --;
		}
		else{
			break;
		}
	}
	
	[tmp_list addObject:@(day_total)];
	
	self.day_total_list_ = tmp_list;
}

- (void) update_month_total_list{
	NSMutableArray* tmp_list = [[NSMutableArray alloc] init];
	
	if(self.history_list_ == nil){
		return;
	}

	//history_listは日付の降順で並んでいる前提
	int history_index = [self.history_list_ count] - 1;
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
	if(month_end_day == 0){
		for(int month=1; month <= 12; month ++){		
			int month_total = 0;
			
			while(true){
				if(history_index < 0){
					break;
				}
				
				DBHistory* history = (self.history_list_)[history_index];
				
				if(history.cur.month == month){
					month_total += history.cur.val;
					history_index --;
				}
				else{
					break;
				}
			}
			
			[tmp_list addObject:@(month_total)];
		}
	}
	else{
		for(int month=1; month <= 12; month ++){
			int prev_month;
			int prev_month_year;
			if(month == 1){
				prev_month_year = self.year_ - 1;
				prev_month = 12;
			}
			else{
				prev_month_year = self.year_;
				prev_month = month - 1;
			}
			
			int prev_month_day_num = [self get_day_num_in_month:prev_month_year month:prev_month];
			int month_day_num = [self get_day_num_in_month:self.year_ month:month];
			
			int month_total = 0;
			//先月
			for(int day=month_end_day+1; day<=prev_month_day_num; day++){				
				while(true){
					if(history_index < 0){
						break;
					}
					
					DBHistory* history = (self.history_list_)[history_index];
					
					if(history.cur.day == day && history.cur.month == prev_month && history.cur.year == prev_month_year){
						month_total += history.cur.val;
						history_index --;
					}
					else{
						break;
					}
				}				
			}
			
			//今月
			for(int day=1; day<=month_end_day && day<=month_day_num; day++){				
				while(true){
					if(history_index < 0){
						break;
					}
					
					DBHistory* history = (self.history_list_)[history_index];
					
					if(history.cur.day == day && history.cur.month == month && history.cur.year == self.year_){
						month_total += history.cur.val;
						history_index --;
					}
					else{
						break;
					}
				}
			}
			
			[tmp_list addObject:@(month_total)];
		}
	}
	
	self.day_total_list_ = tmp_list;
}


//これまでの積算金額を計算
- (void) update_total_multi_:(int)period{
	self.total_multi_ = 0;
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	NSDate* start_date = [settings objectForKey:@"ANA_MULTI_START_DATE"];
	int start_year;
	int start_month;
	int start_day;
	if(start_date != nil){
		NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
		NSDateComponents *components = [cal components:unitFlags fromDate:start_date];
		start_year = [components year];
		start_month = [components month];
		start_day = [components day];
	}
	
	NSPredicate *pred;
	//年
	if(period == 0){
		NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
		int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
		if(month_end_day == 0){
			if(start_date == nil){
				pred = [NSPredicate predicateWithFormat:@"year_cur <= %d and category_cur == %@ and diff_type != %@", 
						self.year_, self.category_, @"del"];
			}
			else{
				pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) >= %d and year_cur <= %d and category_cur == %@ and diff_type != %@", 
						((start_year * 10000) + (start_month * 100) + start_day), self.year_, self.category_, @"del"];
			}			
		}
		else{
			if(start_date == nil){
				pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@", 
						((self.year_ * 10000) + (12 * 100) + month_end_day), self.category_, @"del"];
			}
			else{
				pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) >= %d and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@", 
						((start_year * 10000) + (start_month * 100) + start_day), ((self.year_ * 10000) + (12 * 100) + month_end_day), self.category_, @"del"];
			}			
		}
	}
	//月
	else if(period == 1){
		NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
		int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
		if(month_end_day == 0){
			if(start_date == nil){
				pred = [NSPredicate predicateWithFormat:@"((year_cur * 100) + month_cur) <= %d and category_cur == %@ and diff_type != %@", 
						((self.year_ * 100) + self.month_), self.category_, @"del"];
			}
			else{
				pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) >= %d and ((year_cur * 100) + month_cur) <= %d and category_cur == %@ and diff_type != %@", 
						((start_year * 10000) + (start_month * 100) + start_day), ((self.year_ * 100) + self.month_), self.category_, @"del"];
			}			
		}
		else{
			if(start_date == nil){
				pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@", 
						((self.year_ * 10000) + (self.month_ * 100) + month_end_day), self.category_, @"del"];
			}
			else{
				pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) >= %d and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@", 
						((start_year * 10000) + (start_month * 100) + start_day), ((self.year_ * 10000) + (self.month_ * 100) + month_end_day), self.category_, @"del"];
			}			
		}
	}
	//日
	else{
		if(start_date == nil){
			pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@", 
					((self.year_ * 10000) + (self.month_ * 100) + self.day_), self.category_, @"del"];
		}
		else{
			pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) >= %d and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@", 
					((start_year * 10000) + (start_month * 100) + start_day), ((self.year_ * 10000) + (self.month_ * 100) + self.day_), self.category_, @"del"];
		}
	}
	
	NSArray* history_list_multi = [g_model_ get_history_list_with_pred:pred];
	
	for(int i=0; i<[history_list_multi count]; i++){
		DBHistory* history = history_list_multi[i];
		
		self.total_multi_ += history.cur.val;
	}	
}

- (BOOL) is_separator{
	return [self.type_ hasPrefix:NSLocalizedString(@"STR-215", nil)];
}






@end
