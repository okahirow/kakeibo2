//
//  CustomAna.m
//  kakeibo2
//
//  Created by hiro on 2013/03/13.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "DBCustomAna.h"
#import "MyModel.h"
#import "FormulaElem.h"


@implementation DBCustomAna

@dynamic ana_id;
@dynamic diff_type;
@dynamic index;
@dynamic is_show;
@dynamic cur;
@dynamic org;

@synthesize is_total_error, total, total_multi;


- (id) init{
	if((self = [super init])){
		self.total = 0;
		self.total_multi = 0;
		self.is_total_error = FALSE;
	}
	
	return self;
}


//編集
- (void) edit_name:(NSString*)new_name{
	self.cur.name = new_name;
	
	//本IDの場合
	if(self.ana_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}

- (void) edit_formula:(NSString*)new_formula{
	self.cur.formula = new_formula;
	
	//本IDの場合
	if(self.ana_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}

- (void) edit_unit:(NSString*)new_unit{
	self.cur.unit = new_unit;
	
	//本IDの場合
	if(self.ana_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}


- (void) edit_type:(NSString*)new_type{
	self.cur.type = new_type;
	
	//本IDの場合
	if(self.ana_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}

- (void) edit_color:(MyColor*)new_color{
	[self.cur set_color:new_color];
	
	//本IDの場合
	if(self.ana_id > 0){
		self.diff_type = @"edit";
	}
	
	[g_model_ save_model];
}


//削除
- (void) del_custom_ana{
	[g_model_ del_custom_ana:self];
}

- (void) del_custom_ana_actuary{
	[g_model_ del_custom_ana_actuary:self];
}


//チェック
+ (BOOL) is_valid_formula:(NSString*)formula;{
	NSArray* elems = [DBCustomAna get_gyaku_porand_elems:formula];
	
	if(elems == nil){
		return FALSE;
	}
	else{
		return TRUE;
	}
}


//計算
- (void) calc_formula:(int)year month:(int)month day:(int)day period:(int)period is_multi:(BOOL)is_multi{
	NSArray* elems = [DBCustomAna get_gyaku_porand_elems:self.cur.formula];
	
	NSMutableArray* val_stack = [[NSMutableArray alloc] init];
	
	if(elems == nil){
		//エラー
		is_total_error = TRUE;
		return;
	}
	
	for(int i=0; i<[elems count]; i++){
		FormulaElem* elem = elems[i];
		
		//数値の場合
		if([elem.type_ isEqualToString:@"val"]){
			[val_stack addObject:@(elem.val_)];
		}
		//カテゴリーの場合
		else if([elem.type_ isEqualToString:@"category"]){
			NSPredicate *pred;
			
			//単月
			if(is_multi == false){
				//すべての場合
				if([elem.category_ isEqualToString:NSLocalizedString(@"STR-128", nil)]){
					//年
					if(period == 0){
						NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
						int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
						if(month_end_day == 0){
							pred = [NSPredicate predicateWithFormat:@"year_cur == %d and diff_type != %@", year, @"del"];
						}
						else{
							pred = [NSPredicate predicateWithFormat:@"%d < ((year_cur * 10000) + (month_cur * 100) + day_cur) and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and diff_type != %@",
									(((year - 1) * 10000) + (12 * 100) + month_end_day), ((year * 10000) + (12 * 100) + month_end_day), @"del"];
						}
					}
					//月
					else if(period == 1){
						NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
						int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
						if(month_end_day == 0){
							pred = [NSPredicate predicateWithFormat:@"year_cur == %d and month_cur == %d and diff_type != %@", year, month, @"del"];
						}
						else{
							if(month > 1){
								pred = [NSPredicate predicateWithFormat:@"%d < ((year_cur * 10000) + (month_cur * 100) + day_cur) and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and diff_type != %@",
										((year * 10000) + ((month - 1) * 100) + month_end_day), ((year * 10000) + (month * 100) + month_end_day), @"del"];
							}
							else{
								pred = [NSPredicate predicateWithFormat:@"%d < ((year_cur * 10000) + (month_cur * 100) + day_cur) and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and diff_type != %@",
										(((year - 1) * 10000) + (12 * 100) + month_end_day), ((year * 10000) + (month * 100) + month_end_day), @"del"];
							}
						}
					}
					//日
					else{
						pred = [NSPredicate predicateWithFormat:@"year_cur == %d and month_cur == %d and day_cur == %d and diff_type != %@", year, month, day, @"del"];
					}
				}
				else{
					//年
					if(period == 0){
						NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
						int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
						if(month_end_day == 0){
							pred = [NSPredicate predicateWithFormat:@"year_cur == %d and category_cur == %@ and diff_type != %@", year, elem.category_, @"del"];
						}
						else{
							pred = [NSPredicate predicateWithFormat:@"%d < (year_cur * 10000 + month_cur * 100 + day_cur) and (year_cur * 10000 + month_cur * 100 + day_cur) <= %d and category_cur == %@ and diff_type != %@",
									((year - 1) * 10000 + 12 * 100 + month_end_day), (year * 10000 + 12 * 100 + month_end_day), elem.category_, @"del"];
						}
					}
					//月
					else if(period == 1){
						NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
						int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
						if(month_end_day == 0){
							pred = [NSPredicate predicateWithFormat:@"year_cur == %d and month_cur == %d and category_cur == %@ and diff_type != %@", year, month, elem.category_, @"del"];
						}
						else{
							if(month > 1){
								pred = [NSPredicate predicateWithFormat:@"%d < (year_cur * 10000 + month_cur * 100 + day_cur) and (year_cur * 10000 + month_cur * 100 + day_cur) <= %d and category_cur == %@ and diff_type != %@",
										(year * 10000 + (month - 1) * 100 + month_end_day), (year * 10000 + month * 100 + month_end_day), elem.category_, @"del"];
							}
							else{
								pred = [NSPredicate predicateWithFormat:@"%d < (year_cur * 10000 + month_cur * 100 + day_cur) and (year_cur * 10000 + month_cur * 100 + day_cur) <= %d and category_cur == %@ and diff_type != %@",
										((year - 1) * 10000 + 12 * 100 + month_end_day), (year * 10000 + month * 100 + month_end_day), elem.category_, @"del"];
							}
						}
					}
					//日
					else{
						pred = [NSPredicate predicateWithFormat:@"year_cur == %d and month_cur == %d and day_cur == %d and category_cur == %@ and diff_type != %@", year, month, day, elem.category_, @"del"];
					}
				}
			}
			//積算
			else{
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
				
				//すべての場合
				if([elem.category_ isEqualToString:NSLocalizedString(@"STR-128", nil)]){
					//年
					if(period == 0){
						NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
						int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
						if(month_end_day == 0){
							if(start_date == nil){
								pred = [NSPredicate predicateWithFormat:@"year_cur <= %d and diff_type != %@", year, @"del"];
							}
							else{
								pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) >= %d and year_cur <= %d and diff_type != %@", ((start_year * 10000) + (start_month * 100) + start_day), year, @"del"];
							}
						}
						else{
							if(start_date == nil){
								pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and diff_type != %@",
										(year * 10000 + 12 * 100 + month_end_day), @"del"];
							}
							else{
								pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) >= %d and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and diff_type != %@",
										((start_year * 10000) + (start_month * 100) + start_day), ((year * 10000) + (12 * 100) + month_end_day), @"del"];
							}
						}
					}
					//月
					else if(period == 1){
						NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
						int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
						if(month_end_day == 0){
							if(start_date == nil){
								pred = [NSPredicate predicateWithFormat:@"((year_cur * 100) + month_cur) <= %d and diff_type != %@", (year * 100 + month), @"del"];
							}
							else{
								pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) >= %d and ((year_cur * 100) + month_cur) <= %d and diff_type != %@", ((start_year * 10000) + (start_month * 100) + start_day), (year * 100 + month), @"del"];
							}
						}
						else{
							if(start_date == nil){
								pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and diff_type != %@", ((year * 10000) + (month * 100) + month_end_day), @"del"];
							}
							else{
								pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) >= %d and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and diff_type != %@", ((start_year * 10000) + (start_month * 100) + start_day), ((year * 10000) + (month * 100) + month_end_day), @"del"];
							}
						}
					}
					//日
					else{
						if(start_date == nil){
							pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and diff_type != %@", ((year * 10000) + (month * 100) + day), @"del"];
						}
						else{
							pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) >= %d and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and diff_type != %@", ((start_year * 10000) + (start_month * 100) + start_day), ((year * 10000) + (month * 100) + day), @"del"];
						}
					}
				}
				else{
					//年
					if(period == 0){
						NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
						int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
						if(month_end_day == 0){
							if(start_date == nil){
								pred = [NSPredicate predicateWithFormat:@"year_cur <= %d and category_cur == %@ and diff_type != %@", year, elem.category_, @"del"];
							}
							else{
								pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) >= %d and year_cur <= %d and category_cur == %@ and diff_type != %@", ((start_year * 10000) + (start_month * 100) + start_day), year, elem.category_, @"del"];
							}
						}
						else{
							if(start_date == nil){
								pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@",
										((year * 10000) + (12 * 100) + month_end_day), elem.category_, @"del"];
							}
							else{
								pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) >= %d and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@",
										((start_year * 10000) + (start_month * 100) + start_day), ((year * 10000) + (12 * 100) + month_end_day), elem.category_, @"del"];
							}
						}
					}
					//月
					else if(period == 1){
						NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
						int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
						if(month_end_day == 0){
							if(start_date == nil){
								pred = [NSPredicate predicateWithFormat:@"((year_cur * 100) + month_cur) <= %d and category_cur == %@ and diff_type != %@", ((year * 100) + month), elem.category_, @"del"];
							}
							else{
								pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) >= %d and ((year_cur * 100) + month_cur) <= %d and category_cur == %@ and diff_type != %@",
										((start_year * 10000) + (start_month * 100) + start_day), ((year * 100) + month), elem.category_, @"del"];
							}
						}
						else{
							if(start_date == nil){
								pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@",
										((year * 10000) + (month * 100) + month_end_day), elem.category_, @"del"];
							}
							else{
								pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) >= %d and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@",
										((start_year * 10000) + (start_month * 100) + start_day), ((year * 10000) + (month * 100) + month_end_day), elem.category_, @"del"];
							}
						}
					}
					//日
					else{
						if(start_date == nil){
							pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@", ((year * 10000) + (month * 100) + day), elem.category_, @"del"];
						}
						else{
							pred = [NSPredicate predicateWithFormat:@"((year_cur * 10000) + (month_cur * 100) + day_cur) >= %d and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@", ((start_year * 10000) + (start_month * 100) + start_day), ((year * 10000) + (month * 100) + day), elem.category_, @"del"];
						}
					}
				}
			}
			
			NSArray* history_list = [g_model_ get_history_list_with_pred:pred];
			
			int total_val = 0;
			for(int i=0; i<[history_list count]; i++){
				DBHistory* history = history_list[i];
				
				total_val += history.cur.val;
			}
			
			[val_stack addObject:[NSNumber numberWithFloat:total_val]];
		}
		//演算子の場合
		else{
			if([val_stack count] < 2){
				//エラー
				is_total_error = TRUE;
				return;
			}
			
			NSNumber* number = [val_stack lastObject];
			[val_stack removeLastObject];
			float val2 = [number floatValue];
			
			number = [val_stack lastObject];
			[val_stack removeLastObject];
			float val1 = [number floatValue];
			
			float ret_val;
			
			if([elem.type_ isEqualToString:@"+"]){
				ret_val = val1 + val2;
			}
			else if([elem.type_ isEqualToString:@"-"]){
				ret_val = val1 - val2;
			}
			else if([elem.type_ isEqualToString:@"*"]){
				ret_val = val1 * val2;
			}
			else if([elem.type_ isEqualToString:@"/"]){
				if(val2 == 0.0f){
					ret_val = 0.0f;
				}
				else{
					ret_val = val1 / val2;
				}
			}
			else{
				//エラー
				is_total_error = TRUE;
				return;
			}
			
			[val_stack addObject:@(ret_val)];
		}
	}
	
	if([val_stack count] > 1){
		//エラー
		is_total_error = TRUE;
		return;
	}
	
	NSNumber* number = [val_stack lastObject];
	
	if(is_multi == false){
		total = [number intValue];
	}
	else{
		total_multi = [number intValue];
	}
	
	is_total_error = FALSE;
}


//式を要素に分解
+ (NSArray*) get_formula_elems:(NSString*)formula{
	NSString* formula2 = [NSString stringWithFormat:@"(%@)",formula];
	
	NSMutableArray* elems = [[NSMutableArray alloc] init];
	//NSLog(@"formula:%@", formula2);
	
	NSMutableString* elem = [NSMutableString stringWithString:@""];
	
	for(int i=0; i<[formula2 length]; i++){
		NSString* ch = [formula2 substringWithRange:NSMakeRange(i,1)];
		//NSLog(@"ch:%@", ch);
		
		//数値の場合
		if([ch isEqualToString:@"0"] || [ch isEqualToString:@"1"] || [ch isEqualToString:@"2"] ||
		   [ch isEqualToString:@"3"] || [ch isEqualToString:@"4"] || [ch isEqualToString:@"5"] ||
		   [ch isEqualToString:@"6"] || [ch isEqualToString:@"7"] || [ch isEqualToString:@"8"] ||
		   [ch isEqualToString:@"9"] || [ch isEqualToString:@"."])
		{
			elem = [NSString stringWithFormat:@"%@%@", elem, ch];
		}
		// + - * / ( ) + × ÷ ＊の場合
		else if([ch isEqualToString:@"+"] || [ch isEqualToString:@"-"] || [ch isEqualToString:@"*"] || [ch isEqualToString:@"×"] || [ch isEqualToString:@"＊"] || [ch isEqualToString:@"÷"] ||
				[ch isEqualToString:@"/"] || [ch isEqualToString:@"("] || [ch isEqualToString:@")"])
		{
			//前の要素(数値)を吐き出す
			if([elem length] > 0){
				FormulaElem* e = [[FormulaElem alloc] init];
				e.type_ = @"val";
				e.val_ = [elem floatValue];
				
				[elems addObject:e];
				elem = [NSMutableString stringWithString:@""];
			}
			
			FormulaElem* e = [[FormulaElem alloc] init];
			if([ch isEqualToString:@"×"] || [ch isEqualToString:@"＊"]){
				ch = @"*";
			}
			if([ch isEqualToString:@"÷"]){
				ch = @"/";
			}
			e.type_ = ch;
			
			[elems addObject:e];
		}
		//スペースの場合
		else if([ch isEqualToString:@" "]){
			//前の要素(数値)を吐き出す
			if([elem length] > 0){
				FormulaElem* e = [[FormulaElem alloc] init];
				e.type_ = @"val";
				e.val_ = [elem floatValue];
				
				[elems addObject:e];
				elem = [NSMutableString stringWithString:@""];
			}
		}
		//[の場合
		else if([ch isEqualToString:@"["]){
			//前の要素(数値)が残っていたらエラー
			if([elem length] > 0){
				//エラー
				return nil;
			}
			
			//次の]の位置を検索
			NSRange search_range = NSMakeRange(i + 1, [formula2 length] - (i + 1));
			NSRange range = [formula2 rangeOfString:@"]" options:NSLiteralSearch range:search_range];
			
			//見つからない場合はエラー
			if(range.location == NSNotFound){
				//エラー
				return nil;
			}
			
			//カテゴリー名を追加
			FormulaElem* e = [[FormulaElem alloc] init];
			e.type_ = @"category";
			e.category_ = [formula2 substringWithRange:NSMakeRange(i + 1, range.location - i - 1)];
			
			[elems addObject:e];
			i = range.location;
		}
		//それ以外の要素
		else{
			//エラー
			return nil;
		}
	}
	
	//前の要素(数値)を吐き出す
	if([elem length] > 0){
		FormulaElem* e = [[FormulaElem alloc] init];
		e.type_ = @"val";
		e.val_ = [elem floatValue];
		
		[elems addObject:e];
		elem = [NSMutableString stringWithString:@""];
	}
	
	return elems;
}


//式を逆ポーランド記法の要素に変換
+ (NSArray*) get_gyaku_porand_elems:(NSString*)formula{
	NSArray* formula_elems = [self get_formula_elems:formula];
	
	//エラー
	if(formula_elems == nil){
		return nil;
	}
	
	NSMutableArray* elems = [[NSMutableArray alloc] init];
	NSMutableArray* enzan_stack = [[NSMutableArray alloc] init];
	
	for(int i=0; i<[formula_elems count]; i++){
		FormulaElem* elem = formula_elems[i];
		
		//数値またはカテゴリーの場合
		if([elem.type_ isEqualToString:@"val"] || [elem.type_ isEqualToString:@"category"]){
			[elems addObject:elem];
		}
		// + - の場合
		else if([elem.type_ isEqualToString:@"+"] || [elem.type_ isEqualToString:@"-"]){
			while([enzan_stack count] > 0){
				FormulaElem* top = [enzan_stack lastObject];
				if([top.type_ isEqualToString:@"("]){
					break;
				}
				
				[elems addObject:top];
				[enzan_stack removeLastObject];
			}
			
			[enzan_stack addObject:elem];
		}
		// * / の場合
		else if([elem.type_ isEqualToString:@"*"] || [elem.type_ isEqualToString:@"/"]){
			FormulaElem* top = [enzan_stack lastObject];
			if([enzan_stack count] > 0 && ([top.type_ isEqualToString:@"*"] || [top.type_ isEqualToString:@"/"])){
				[elems addObject:top];
				[enzan_stack removeLastObject];
			}
			
			[enzan_stack addObject:elem];
		}
		// ( の場合
		else if([elem.type_ isEqualToString:@"("]){
			[enzan_stack addObject:elem];
		}
		// ) の場合
		else if([elem.type_ isEqualToString:@")"]){
			while([enzan_stack count] > 0){
				FormulaElem* top = [enzan_stack lastObject];
				if([top.type_ isEqualToString:@"("]){
					[enzan_stack removeLastObject];
					break;
				}
				
				[elems addObject:top];
				[enzan_stack removeLastObject];
			}
		}
		else{
			//エラー
			return nil;
		}
	}
	
	//スタックに残っていたらエラー
	if([enzan_stack count] > 0){
		//エラー
		return nil;
	}
	
	for(int i=0; i<[elems count]; i++){
		//FormulaElem* e = [elems objectAtIndex:i];
		//NSLog(@"%@, %@, %f",e.type_, e.category_, e.val_);
	}
	
	return elems;
}


- (BOOL) is_separator{
	return [self.cur.type isEqualToString:NSLocalizedString(@"STR-215", nil)];
}



@end
