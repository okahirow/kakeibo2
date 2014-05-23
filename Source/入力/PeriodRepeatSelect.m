//
//  PeriodRepeatSelect.m
//  kakeibo2
//
//  Created by hiro on 2013/04/18.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "PeriodRepeatSelect.h"
#import "DateKeyboard.h"
#import "CommonAPI.h"
#import "WeekdayCell.h"

@interface PeriodRepeatSelect ()

@property(strong) Period_Data* period_data;
@property(weak) id<SelectPeriodDataDelegate> delegate;
@property(strong) DateKeyboard* date_keyboard1;
@property(strong) DateKeyboard* date_keyboard2;

@property(strong) NSArray* switch_weekday_list;

@property(weak) IBOutlet UILabel* label_guide;
@property(weak) IBOutlet UITextField* text_start;
@property(weak) IBOutlet UITextField* text_end;
@property(weak) IBOutlet UISwitch* switch_is_set_end;
@property(weak) IBOutlet UISwitch* switch_weekday1;
@property(weak) IBOutlet UISwitch* switch_weekday2;
@property(weak) IBOutlet UISwitch* switch_weekday3;
@property(weak) IBOutlet UISwitch* switch_weekday4;
@property(weak) IBOutlet UISwitch* switch_weekday5;
@property(weak) IBOutlet UISwitch* switch_weekday6;
@property(weak) IBOutlet UISwitch* switch_weekday7;

- (IBAction) tap_done:(id)sender;
- (IBAction) change_switch:(UISwitch*)sender;
- (IBAction) change_text:(id)sender;

@end

@implementation PeriodRepeatSelect

- (void) init_period_data:(Period_Data*)data delegate:(id)delegate{
	self.period_data = data;
	self.delegate = delegate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.switch_weekday_list = @[self.switch_weekday1, self.switch_weekday2, self.switch_weekday3, self.switch_weekday4, self.switch_weekday5, self.switch_weekday6, self.switch_weekday7];
	
	self.date_keyboard1 = [[self storyboard] instantiateViewControllerWithIdentifier:@"DateKeyboard"];
	[self.date_keyboard1 init_text_field:self.text_start date:self.period_data.start_date delegate:self];
	self.text_start.inputView = self.date_keyboard1.view;
	
	self.date_keyboard2 = [[self storyboard] instantiateViewControllerWithIdentifier:@"DateKeyboard"];
	[self.date_keyboard2 init_text_field:self.text_end date:self.period_data.end_date delegate:self];
	self.text_end.inputView = self.date_keyboard2.view;
	
	if(self.period_data.type == REPEAT_DAY){
		self.title = @"毎日";
	}
	else if(self.period_data.type == REPEAT_WEEK){
		self.title = @"毎週";
	}
	else if(self.period_data.type == REPEAT_MONTH){
		self.title = @"毎月";
	}
	else if(self.period_data.type == REPEAT_YEAR){
		self.title = @"毎年";		
	}
	
	if(self.period_data.end_date == nil){
		self.switch_is_set_end.on = NO;
		self.text_end.enabled = NO;
	}
	else{
		self.switch_is_set_end.on = YES;
		self.text_end.enabled = YES;
	}
	
	if(self.period_data.type == REPEAT_WEEK){
		for(int i=0; i<7; i++){
			UISwitch* switch_weekday = self.switch_weekday_list[i];
			switch_weekday.on = [self.period_data.weekday_list[i] boolValue];
		}
	}
	
	self.label_guide.text = [self get_guide_text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
	if(self.period_data.type == REPEAT_WEEK){
		return 3;
	}
	else{
		return 2;
	}
}

- (IBAction) change_switch:(UISwitch*)sender{
	//終了日
	if(sender.tag == 0){
		if(sender.on == NO){
			self.period_data.end_date = nil;
			self.text_end.enabled = NO;
		}
		else{
			self.period_data.end_date = [NSDate date];
			self.text_end.enabled = YES;
			[self.text_end becomeFirstResponder];
		}
		
		[self.date_keyboard2 set_date:self.period_data.end_date];
	}
	else{
		self.period_data.weekday_list[sender.tag - 1] = [NSNumber numberWithBool:sender.on];
	}
	
	self.label_guide.text = [self get_guide_text];
}

- (void) date_changed:(DateKeyboard*)keyboard date:(NSDate*)date{
	if(keyboard == self.date_keyboard1){
		self.period_data.start_date = date;
	}
	else{
		self.period_data.end_date = date;
	}
	
	self.label_guide.text = [self get_guide_text];
}

- (NSString*) get_guide_text{
	NSString* text = [CommonAPI get_day_string_with_week:self.period_data.start_date];
	text = [NSString stringWithFormat:@"%@ から", text];
	
	if(self.period_data.end_date != nil){
		text = [NSString stringWithFormat:@"%@ %@ まで", text, [CommonAPI get_day_string_with_week:self.period_data.end_date]];
	}
	
	if(self.period_data.type == REPEAT_DAY){
		text = [NSString stringWithFormat:@"%@\n毎日", text];
	}
	else if(self.period_data.type == REPEAT_WEEK){
		text = [NSString stringWithFormat:@"%@\n毎週", text];
		
		for(int i=0; i<7; i++){
			UISwitch* switch_weekday = self.switch_weekday_list[i];
			
			if(switch_weekday.on == YES){
				text = [NSString stringWithFormat:@"%@ %@", text, [CommonAPI weekday_string:i + 1]];
			}
		}
		
		text = [NSString stringWithFormat:@"%@ 曜日", text];
	}
	else if(self.period_data.type == REPEAT_MONTH){
		text = [NSString stringWithFormat:@"%@\n毎月", text];
	}
	else if(self.period_data.type == REPEAT_YEAR){
		text = [NSString stringWithFormat:@"%@\n毎年", text];
	}
	
	return text;
}

- (IBAction) tap_done:(id)sender{
	[self.delegate period_setting_selected:self.period_data];
	
	[self.navigationController popToViewController:(UINavigationController*)(self.delegate) animated:YES];
}


@end
