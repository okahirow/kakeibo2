//
//  EditHistory.m
//  kakeibo2
//
//  Created by hiro on 2013/05/12.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "EditHistory.h"

@interface EditHistory (){
	Event* _target_event;
	History_Data* _history_data;
	
	CalcKeyboard* _calc_keyboard;
	DateKeyboard* _date_keyboard;
}

@property(weak) IBOutlet UILabel* label_category_name;
@property(weak) IBOutlet UILabel* label_repeat;
@property(weak) IBOutlet UILabel* label_date_title;
@property(weak) IBOutlet UITextField* text_date;
@property(weak) IBOutlet UITextField* text_val;
@property(weak) IBOutlet UITextField* text_memo;
@property(weak) IBOutlet UITextField* text_person;

- (IBAction) tap_save:(id)sender;
- (IBAction) tap_delete:(id)sender;

@end

@implementation EditHistory

- (void) setup_with_event:(Event*)event{
	_target_event = event;
	_history_data = [event.db_event get_data];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.label_category_name.text = _history_data.category;
	
	[self update_period_view];
	
	if(_history_data.val == 0){
		self.text_val.text = @"";
	}
	else{
		self.text_val.text = [NSString stringWithFormat:@"%d", _history_data.val];
	}
	
	if([_history_data.memo isEqualToString:@""] == YES){
		self.text_memo.text = @"";
	}
	else{
		self.text_memo.text = _history_data.memo;
	}
	
	if([_history_data.person isEqualToString:@""] == YES){
		self.text_person.text = @"";
	}
	else{
		self.text_person.text = _history_data.person;
	}
	
	_calc_keyboard = [[self storyboard] instantiateViewControllerWithIdentifier:@"CalcKeyboard"];
	_calc_keyboard.text_field = self.text_val;
	self.text_val.inputView = _calc_keyboard.view;
	
	_date_keyboard = [[self storyboard] instantiateViewControllerWithIdentifier:@"DateKeyboard"];
	[_date_keyboard init_text_field:self.text_date date:_history_data.period.start_date delegate:self];
	self.text_date.inputView = _date_keyboard.view;
	
	[self.text_val resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//セルの高さ
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.row == 1 && _history_data.period.type != ONE_DAY){
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
		
		Period_Data* data = [_history_data.period copy];
		
		[target init_period_data:data delegate:self];
		
		[segue.destinationViewController setHidesBottomBarWhenPushed:YES];
	}
}

//日付変更
- (void) date_changed:(DateKeyboard*)keyboard date:(NSDate*)date{
	_history_data.period.start_date = date;
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
	
	_history_data.val = [self.text_val.text intValue];
	_history_data.memo = self.text_memo.text;
	_history_data.person = self.text_person.text;
	
	//元が単体イベントの場合
	if([_target_event.db_event class] == [DBEvent_Normal class]){
		[g_model_ edit_normal_event:(DBEvent_Normal*)_target_event.db_event history_data:_history_data];
		
		[self.navigationController popViewControllerAnimated:YES];
	}
	
	//元が繰り返しイベントの場合
	else if([_target_event.db_event class] == [DBEvent_Recurrence class]){
		//日付が同じ場合
		if([CommonAPI compare_date:_history_data.period.start_date date2:_target_event.date] == NSOrderedSame){
			UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"定期的な履歴の編集" delegate:self cancelButtonTitle:@"キャンセル" destructiveButtonTitle:@"すべて変更" otherButtonTitles:@"この日以降すべて変更", @"この日だけ変更", nil];
			sheet.tag = 4;
			[sheet showInView:self.view];
		}
		//日付が編集された場合
		else{
			UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"定期的な履歴の編集" delegate:self cancelButtonTitle:@"キャンセル" destructiveButtonTitle:nil otherButtonTitles:@"この日以降すべて変更", @"この日だけ変更", nil];
			sheet.tag = 5;
			[sheet showInView:self.view];
		}
	}
	
	//元が繰り返しの例外イベントの場合
	else if([_target_event.db_event class] == [DBEvent_Exception class]){
		[g_model_ edit_exception_event:(DBEvent_Exception*)_target_event.db_event history_data:_history_data];
		
		[self.navigationController popViewControllerAnimated:YES];
	}
	
	//エラー
	else{
		
	}
}

//期間選択
- (void) period_setting_selected:(Period_Data*)data{
	_history_data.period = data;
	[self update_period_view];
}

//期間表示更新
- (void) update_period_view{
	if(_history_data.period.type == ONE_DAY){
		self.label_repeat.hidden = YES;
		self.text_date.hidden = NO;
		self.text_date.text = [CommonAPI get_day_string_with_week:_history_data.period.start_date];
	}
	else{
		self.label_repeat.hidden = NO;
		self.text_date.hidden = YES;
		
		NSString* text = [CommonAPI get_day_string_with_week:_history_data.period.start_date];
		text = [NSString stringWithFormat:@"%@ から\n", text];
		
		if(_history_data.period.end_date != nil){
			text = [NSString stringWithFormat:@"%@%@ まで\n", text, [CommonAPI get_day_string_with_week:_history_data.period.end_date]];
		}
		
		if(_history_data.period.type == REPEAT_DAY){
			text = [NSString stringWithFormat:@"%@毎日", text];
		}
		else if(_history_data.period.type == REPEAT_WEEK){
			text = [NSString stringWithFormat:@"%@毎週 ", text];
			
			for(int i=0; i<7; i++){
				BOOL is_on = [_history_data.period.weekday_list[i] boolValue];
				
				if(is_on == YES){
					text = [NSString stringWithFormat:@"%@%@", text, [CommonAPI weekday_string:i + 1]];
				}
			}
		}
		else if(_history_data.period.type == REPEAT_MONTH){
			text = [NSString stringWithFormat:@"%@毎月", text];
		}
		else if(_history_data.period.type == REPEAT_YEAR){
			text = [NSString stringWithFormat:@"%@毎年", text];
		}
		
		self.label_repeat.text = text;
	}
	
	[self.tableView reloadData];
}

//履歴の削除
- (IBAction) tap_delete:(id)sender{
	//単体イベントの場合
	if([_target_event.db_event class] == [DBEvent_Normal class]){
		UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"履歴の削除" delegate:self cancelButtonTitle:@"キャンセル" destructiveButtonTitle:@"削除" otherButtonTitles:nil];
		sheet.tag = 1;
		[sheet showInView:self.view];
	}
	
	//繰り返しイベントの場合
	else if([_target_event.db_event class] == [DBEvent_Recurrence class]){
		UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"定期的な履歴の削除" delegate:self cancelButtonTitle:@"キャンセル" destructiveButtonTitle:@"すべて削除" otherButtonTitles:@"この日以降すべて削除", @"この日だけ削除", nil];
		sheet.tag = 2;
		[sheet showInView:self.view];
	}
	
	//繰り返しの例外イベントの場合
	else if([_target_event.db_event class] == [DBEvent_Exception class]){
		UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"履歴の削除" delegate:self cancelButtonTitle:@"キャンセル" destructiveButtonTitle:@"削除" otherButtonTitles:nil];
		sheet.tag = 3;
		[sheet showInView:self.view];
	}
	
	//エラー
	else{
		
	}
}

//削除・編集確認
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	//通常イベントの削除
	if(actionSheet.tag == 1){
		if(buttonIndex == 0){
			[g_model_ del_normal_event:(DBEvent_Normal*)_target_event.db_event];
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
	//繰り返しイベントの削除
	else if(actionSheet.tag == 2){
		//すべて削除
		if(buttonIndex == 0){
			[g_model_ del_recurrence_event_all:(DBEvent_Recurrence*)_target_event.db_event];
			[self.navigationController popViewControllerAnimated:YES];
		}
		//この日以降すべて削除
		else if(buttonIndex == 1){
			[g_model_ del_recurrent_event_from_date:(DBEvent_Recurrence*)_target_event.db_event date:_target_event.date];
			[self.navigationController popViewControllerAnimated:YES];
		}
		//この日だけ削除
		else{
			[g_model_ del_recurrence_event_one_day:(DBEvent_Recurrence*)_target_event.db_event date:_target_event.date];
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
	//繰り返しの例外イベントの削除
	else if(actionSheet.tag == 3){
		if(buttonIndex == 0){
			[g_model_ del_exception_event:(DBEvent_Exception*)_target_event.db_event];
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
	//繰り返しイベントの編集
	else if(actionSheet.tag == 4){
		//すべて変更
		if(buttonIndex == 0){
			[g_model_ edit_recurrence_event_all:(DBEvent_Recurrence*)_target_event.db_event history_data:_history_data];
			[self.navigationController popViewControllerAnimated:YES];
		}
		//この日以降すべて変更
		else if(buttonIndex == 1){
			[g_model_ edit_recurrence_event_from_date:(DBEvent_Recurrence*)_target_event.db_event history_data:_history_data date:_target_event.date];
			[self.navigationController popViewControllerAnimated:YES];
		}
		//この日だけ変更
		else{
			[g_model_ edit_recurrence_event_one_day:(DBEvent_Recurrence*)_target_event.db_event history_data:_history_data org_date:_target_event.date];
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
	//繰り返しイベントの編集
	else if(actionSheet.tag == 5){
		//この日以降すべて変更
		if(buttonIndex == 0){
			
			[self.navigationController popViewControllerAnimated:YES];
		}
		//この日だけ変更
		else{
			[g_model_ edit_recurrence_event_one_day:(DBEvent_Recurrence*)_target_event.db_event history_data:_history_data org_date:_target_event.date];
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}

@end
