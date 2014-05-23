//
//  InputHistory.m
//  kakeibo2
//
//  Created by hiro on 2013/04/15.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "InputHistory.h"
#import "History_Data.h"
#import "CommonAPI.h"
#import "CalcKeyboard.h"
#import "DateKeyboard.h"
#import "PeriodTypeSelect.h"
#import "MyModel.h"

@interface InputHistory ()

@property(strong) CalcKeyboard* calc_keyboard;
@property(strong) DateKeyboard* date_keyboard;

@property(weak) IBOutlet UILabel* label_category_name;
@property(weak) IBOutlet UILabel* label_repeat;
@property(weak) IBOutlet UILabel* label_date_title;
@property(weak) IBOutlet UITextField* text_date;
@property(weak) IBOutlet UITextField* text_val;
@property(weak) IBOutlet UITextField* text_memo;
@property(weak) IBOutlet UITextField* text_person;

@property(weak) Category_Data* category_data;
@property(strong) History_Data* history_data;

- (IBAction) tap_save:(id)sender;

@end

@implementation InputHistory

- (void) setup_with_category_data:(Category_Data*)data{
	self.category_data = data;
	
	self.history_data = [[History_Data alloc] init];
	self.history_data.category = self.category_data.name;
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	self.history_data.person = [settings stringForKey:@"DEFAULT_PERSON"];
	self.history_data.memo = @"";
	self.history_data.val = 0;
	self.history_data.period.type = ONE_DAY;
	self.history_data.period.start_date = [NSDate date];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if(self.category_data != nil){
		if(self.category_data.is_income){
			self.title = @"収入の入力";
		}
		else{
			self.title = @"支出の入力";
		}
		
		self.label_category_name.text = self.history_data.category;
		
		[self update_period_view];
		
		if(self.history_data.val == 0){
			self.text_val.text = @"";
		}
		else{
			self.text_val.text = [NSString stringWithFormat:@"%d", self.history_data.val];
		}
		
		if([self.history_data.memo isEqualToString:@""] == YES){
			self.text_memo.text = @"";
		}
		else{
			self.text_memo.text = self.history_data.memo;
		}
		
		if([self.history_data.person isEqualToString:@""] == YES){
			self.text_person.text = @"";
		}
		else{
			self.text_person.text = self.history_data.person;
		}
	}
	
	self.calc_keyboard = [[self storyboard] instantiateViewControllerWithIdentifier:@"CalcKeyboard"];
	self.calc_keyboard.text_field = self.text_val;
	self.text_val.inputView = self.calc_keyboard.view;
	
	self.date_keyboard = [[self storyboard] instantiateViewControllerWithIdentifier:@"DateKeyboard"];
	[self.date_keyboard init_text_field:self.text_date date:self.history_data.period.start_date delegate:self];
	self.text_date.inputView = self.date_keyboard.view;
	
	[self.text_val becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//セルの高さ
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.row == 1 && self.history_data.period.type != ONE_DAY){
		return 60;
	}
	else{
		return 44;
	}
}

//セル選択
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	//日付
	if(indexPath.row == 1){
		
	}
}

//遷移時
-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"select_period"]) {
		PeriodTypeSelect* target = (PeriodTypeSelect*)[segue destinationViewController];
		
		Period_Data* data = [self.history_data.period copy];
		
		[target init_period_data:data delegate:self];
		
		[segue.destinationViewController setHidesBottomBarWhenPushed:YES];
	}
}


//日付変更
- (void) date_changed:(DateKeyboard*)keyboard date:(NSDate*)date{
	self.history_data.period.start_date = date;
}

//キーボードの完了ボタン
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	
	return YES;
}

//保存
- (IBAction) tap_save:(id)sender{
	if(self.text_val.text.length == 0){
		UIAlertView* alert = [[UIAlertView alloc ] initWithTitle:@"金額が入力されていません。" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	self.history_data.val = [self.text_val.text intValue];
	self.history_data.memo = self.text_memo.text;
	self.history_data.person = self.text_person.text;
	
	//新規追加
	[g_model_ add_history3:self.history_data];
	
	[self.navigationController popViewControllerAnimated:YES];
}

//期間選択
- (void) period_setting_selected:(Period_Data*)data{
	self.history_data.period = data;
	[self update_period_view];
}

//期間表示更新
- (void) update_period_view{
	if(self.history_data.period.type == ONE_DAY){
		self.label_repeat.hidden = YES;
		self.text_date.hidden = NO;
		self.text_date.text = [CommonAPI get_day_string_with_week:self.history_data.period.start_date];
	}
	else{
		self.label_repeat.hidden = NO;
		self.text_date.hidden = YES;
		
		NSString* text = [CommonAPI get_day_string_with_week:self.history_data.period.start_date];
		text = [NSString stringWithFormat:@"%@ から\n", text];
		
		if(self.history_data.period.end_date != nil){
			text = [NSString stringWithFormat:@"%@%@ まで\n", text, [CommonAPI get_day_string_with_week:self.history_data.period.end_date]];
		}
		
		if(self.history_data.period.type == REPEAT_DAY){
			text = [NSString stringWithFormat:@"%@毎日", text];
		}
		else if(self.history_data.period.type == REPEAT_WEEK){
			text = [NSString stringWithFormat:@"%@毎週 ", text];
			
			for(int i=0; i<7; i++){
				BOOL is_on = [self.history_data.period.weekday_list[i] boolValue];
				
				if(is_on == YES){
					text = [NSString stringWithFormat:@"%@%@", text, [CommonAPI weekday_string:i + 1]];
				}
			}
		}
		else if(self.history_data.period.type == REPEAT_MONTH){
			text = [NSString stringWithFormat:@"%@毎月", text];
		}
		else if(self.history_data.period.type == REPEAT_YEAR){
			text = [NSString stringWithFormat:@"%@毎年", text];
		}
		
		self.label_repeat.text = text;
	}
	
	[self.tableView reloadData];
}


@end
