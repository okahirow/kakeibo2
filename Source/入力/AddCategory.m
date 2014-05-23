//
//  AddCategory_Income.m
//  kakeibo2
//
//  Created by hiro on 2013/03/19.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "AddCategory.h"
#import "MyColor.h"
#import "ColorSelect.h"
#import "Category_Data.h"
#import "CommonAPI.h"
#import "MyModel.h"

@implementation AddCategory{
	Category_Data* tmp_data;
	DBCategory* edit_category;
	BOOL is_add_mode;
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
	
	[self apply_data_to_view];
	
	if(is_add_mode == YES){
		[self.text_category_name becomeFirstResponder];
	}
}

- (void) init_for_add_mode:(Category_Data*)data{
	is_add_mode = YES;
	self.title = @"項目の追加";
	
	edit_category = nil;
	tmp_data = data;
}

- (void) init_for_edit_mode:(DBCategory*)category{
	is_add_mode = NO;
	self.title = @"項目の編集";
	
	edit_category = category;
	tmp_data = [category.cur get_data];
}

-(void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	
	[self hide_keyboard];
}

-(void)hide_keyboard{
	[self.text_category_name resignFirstResponder];
	[self.text_budget_year resignFirstResponder];
	[self.text_budget_month resignFirstResponder];
	[self.text_budget_day resignFirstResponder];
}

- (void)apply_data_to_view{
	if(tmp_data.is_income == YES){
		self.segment_is_income.selectedSegmentIndex = 1;
	}
	else{
		self.segment_is_income.selectedSegmentIndex = 0;
	}
	
	self.text_category_name.text = tmp_data.name;
	
	[self update_color_view];
	
	if(tmp_data.budget_year <= 0){
		self.text_budget_year.text = @"";
	}
	else{
		self.text_budget_year.text = [NSString stringWithFormat:@"%d", tmp_data.budget_year];
	}
	if(tmp_data.budget_month <= 0){
		self.text_budget_month.text = @"";
	}
	else{
		self.text_budget_month.text = [NSString stringWithFormat:@"%d", tmp_data.budget_month];
	}
	if(tmp_data.budget_day <= 0){
		self.text_budget_day.text = @"";
	}
	else{
		self.text_budget_day.text = [NSString stringWithFormat:@"%d", tmp_data.budget_day];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) color_selected:(MyColor*)color{
	tmp_data.color = color;
	
	[self update_color_view];
}

- (void) update_color_view{
	if(tmp_data.color.r == 1.0 && tmp_data.color.g == 1.0 && tmp_data.color.b == 1.0){
		self.label_color.text = @"指定なし";
		self.label_color.textColor = [UIColor colorWithRed:56 / 255.0f green:84 / 255.0f blue:135 / 255.0f alpha:1.0f];
	}
	else{
		self.label_color.text = @"■";
		self.label_color.textColor = [tmp_data.color ui_color];
	}
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"select_color"]) {
		ColorSelect* target = (ColorSelect*)[segue destinationViewController];
		
		target.color_select_delegate = self;
		target.cur_color = tmp_data.color;
	}
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	
	return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField{
	[textField resignFirstResponder];
}

-(IBAction)segment_change:(UISegmentedControl*)sender{
	if(sender == self.segment_is_income){
		if(self.segment_is_income.selectedSegmentIndex == 0){
			tmp_data.is_income = NO;
		}
		else{
			tmp_data.is_income = YES;
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

- (IBAction) tap_save:(id)sender{
	tmp_data.name = self.text_category_name.text;
	
	if(self.segment_is_income.selectedSegmentIndex == 0){
		tmp_data.is_income = NO;
	}
	else{
		tmp_data.is_income = YES;
	}
	
	if(self.text_budget_year.text.length == 0){
		tmp_data.budget_year = -1;
	}
	else{
		tmp_data.budget_year = [self.text_budget_year.text intValue];
	}
	
	if(self.text_budget_month.text.length == 0){
		tmp_data.budget_month = -1;
	}
	else{
		tmp_data.budget_month = [self.text_budget_month.text intValue];
	}
	
	if(self.text_budget_day.text.length == 0){
		tmp_data.budget_day = -1;
	}
	else{
		tmp_data.budget_day = [self.text_budget_day.text intValue];
	}
	
	if(tmp_data.name.length == 0){
		UIAlertView* alert = [[UIAlertView alloc ] initWithTitle:@"名前が入力されていません。" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	if([g_model_ is_exist_category2:tmp_data.name without:edit_category] == YES){
		UIAlertView* alert = [[UIAlertView alloc ] initWithTitle:@"すでに同じ名前のカテゴリが存在します。" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	//新規追加
	if(is_add_mode == YES){
		[g_model_ add_category2:tmp_data];
	}
	//編集
	else{
		[edit_category edit_cur_data:tmp_data];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

@end
