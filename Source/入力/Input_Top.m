//
//  Add_Top.m
//  kakeibo2
//
//  Created by hiro on 2013/03/26.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "Input_Top.h"
#import "DBCategory.h"
#import "MyModel.h"
#import "AddCategory.h"
#import "Category_Data.h"
#import "Section_Data.h"
#import "SepalatorCell.h"
#import "CategoryCell.h"
#import "InputHistory.h"

@implementation Input_Top{
	NSMutableArray* outcome_list;
	NSMutableArray* income_list;
	NSMutableArray* cur_list;
	NSMutableArray* cur_section_list;
	
	NSDate* data_timestamp;
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
	// Do any additional setup after loading the view.
	
	outcome_list = [NSMutableArray arrayWithArray:[g_model_ get_show_outcome_category_list]];
	income_list = [NSMutableArray arrayWithArray:[g_model_ get_show_income_category_list]];
	data_timestamp = [NSDate date];
	
	if(self.segment_is_income.selectedSegmentIndex == 0){
		cur_list = outcome_list;
	}
	else{
		cur_list = income_list;
	}
	cur_section_list = [self get_cur_section_list];
	
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	[self update_model_data];
}

- (void) update_model_data{
	if([g_model_ is_old_data:data_timestamp] == YES){
		outcome_list = [NSMutableArray arrayWithArray:[g_model_ get_show_outcome_category_list]];
		income_list = [NSMutableArray arrayWithArray:[g_model_ get_show_income_category_list]];
		data_timestamp = [NSDate date];
		
		if(self.segment_is_income.selectedSegmentIndex == 0){
			cur_list = outcome_list;
		}
		else{
			cur_list = income_list;
		}
		cur_section_list = [self get_cur_section_list];
		
		[self.tableView reloadData];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray*)get_cur_section_list{
	NSMutableArray* section_list = [[NSMutableArray alloc] init];
	
	Section_Data* cur_section;
	
	for(int i=0; i<[cur_list count]; i++){
		DBCategory* category = cur_list[i];
		if(i == 0 && category.is_separator == NO){
			cur_section = [[Section_Data alloc] init];
			[section_list addObject:cur_section];
			
			cur_section.sepalator = nil;
			[cur_section.category_list addObject:category];
		}
		else if(category.is_separator == YES){
			cur_section = [[Section_Data alloc] init];
			[section_list addObject:cur_section];
			
			cur_section.sepalator = category;
		}
		else{
			[cur_section.category_list addObject:category];
		}
	}
	
	return section_list;
}

//セルの高さ
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if(self.tableView.isEditing == NO){
		return 68;
	}
	else{
		if(indexPath.section == 1){
			return 44;
		}
		else{
			DBCategory* category = cur_list[indexPath.row];
			if(category.cur.is_sepalator == NO){
				return 68;
			}
			else{
				return 47;
			}
		}
	}
}

//セクションの数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(self.tableView.isEditing == NO){
		return [cur_section_list count];
	}
	else{
		return 2;
	}
}

//セルの数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if(self.tableView.isEditing == NO){
		Section_Data* section_data = cur_section_list[section];
		return [section_data.category_list count];
	}
	else{
		if(section == 1){
			return 1;
		}
		else{
			return [cur_list count];
		}
	}
}

//セクション名
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
	if(self.tableView.isEditing == NO){
		Section_Data* section_data = cur_section_list[section];
		if(section_data.sepalator == nil){
			return nil;
		}
		else{
			return section_data.sepalator.cur.name;
		}
	}
	else{
		return nil;
	}
}

//セクションヘッダのカスタマイズ
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return nil;
}

//フッタのテキスト
- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	if(self.tableView.isEditing == NO){
		return nil;
	}
	else{
		if(section == 1){
			return @"項目の間に挿入すると、そこで項目がグルーピングされます。\n\nセパレータをタップすると名前を変更できます。";
		}
		else{
			return nil;
		}
	}
}

//並べ替えできるようにする
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 1){
		return NO;
	}
	else{
		return YES;
	}
}

//並べ替えの位置制限
- (NSIndexPath*)tableView:(UITableView*)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath*)sourceIndexPath toProposedIndexPath:(NSIndexPath*)proposedDestinationIndexPath{
	if(proposedDestinationIndexPath.section == 1){
		return [NSIndexPath indexPathForRow:[cur_list count] inSection:0];
	}
	else{
		return proposedDestinationIndexPath;
	}
}

//並べ替え
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSUInteger fromRow = fromIndexPath.row;
	NSUInteger toRow = toIndexPath.row;
	
	//モデル内の並び替え
	[g_model_ swap_category2:(self.segment_is_income.selectedSegmentIndex == 1) from_index:fromRow to_index:toRow];
	
	[self update_model_data];
}

//編集時のスタイル
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section == 1){
		return UITableViewCellEditingStyleInsert;
	}
	else{
		return UITableViewCellEditingStyleDelete;
	}
}

//セル作成
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* cell;
	
	if(self.tableView.isEditing == NO){
		Section_Data* section_data = cur_section_list[indexPath.section];
		DBCategory* category = section_data.category_list[indexPath.row];
		
		CategoryCell* cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell_Category"];
		
		cell2.label_name.text = category.cur.name;
		cell2.label_detail.text = [NSString stringWithFormat:@"%d,%@,%d,%d,%d,%@,%d,%d,%d", category.cat_id, category.diff_type, category.index, category.cur.is_income,  category.cur.is_sepalator, category.cur.color, category.cur.budget_year, category.cur.budget_month, category.cur.budget_day];
		
		if([category.cur is_set_color] == YES){
			cell2.view_color.hidden = NO;
			cell2.view_color.backgroundColor = [[category.cur get_color] ui_color];
		}
		else{
			cell2.view_color.hidden = YES;
		}
		
		cell = cell2;
		
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	else{
		if(indexPath.section == 1){
			cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_AddSepalator"];
		}
		else{
			DBCategory* category = cur_list[indexPath.row];
			
			if(category.cur.is_sepalator == NO){
				CategoryCell* cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell_Category"];
				
				cell2.label_name.text = category.cur.name;
				cell2.label_detail.text = [NSString stringWithFormat:@"%d,%@,%d,%d,%d,%@,%d,%d,%d", category.cat_id, category.diff_type, category.index, category.cur.is_income,  category.cur.is_sepalator, category.cur.color, category.cur.budget_year, category.cur.budget_month, category.cur.budget_day];
				
				if([category.cur is_set_color] == YES){
					cell2.view_color.hidden = NO;
					cell2.view_color.backgroundColor = [[category.cur get_color] ui_color];
				}
				else{
					cell2.view_color.hidden = YES;
				}
				
				cell = cell2;
			}
			else{
				SepalatorCell* cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell_Sepalator"];
				cell2.text_field.text = category.cur.name;
				cell2.text_field.tag = indexPath.row;
				
				cell = cell2;
			}
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}
	
	return cell;
}

//セルの色
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if(self.tableView.isEditing == NO){
		cell.backgroundColor = [UIColor whiteColor];
	}
	else{
		if(indexPath.section == 1){
			cell.backgroundColor = [UIColor whiteColor];
		}
		else{
			DBCategory* category = cur_list[indexPath.row];
			
			if(category.cur.is_sepalator == NO){
				cell.backgroundColor = [UIColor whiteColor];
			}
			else{
				cell.backgroundColor = [UIColor clearColor];
			}
		}
	}
}

//編集ボタンが押された場合
- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
	[super setEditing:editing animated:animated];
	
	[self.tableView reloadData];
}

//遷移時
-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"add_category_outcome"]) {
		AddCategory* target = (AddCategory*)[segue destinationViewController];
		
		Category_Data* data = [[Category_Data alloc] init];
		data.is_income = NO;
		data.is_sepalator = NO;
		[target init_for_add_mode:data];
		
		[segue.destinationViewController setHidesBottomBarWhenPushed:YES];
	}
	else if([segue.identifier isEqualToString:@"add_category_income"]){
		AddCategory* target = (AddCategory*)[segue destinationViewController];
		
		Category_Data* data = [[Category_Data alloc] init];
		data.is_income = YES;
		data.is_sepalator = NO;
		[target init_for_add_mode:data];
		
		[segue.destinationViewController setHidesBottomBarWhenPushed:YES];
	}
}

//カテゴリ追加
-(IBAction)tap_add:(id)sender{
	//支出
	if(self.segment_is_income.selectedSegmentIndex == 0){
		[self performSegueWithIdentifier:@"add_category_outcome" sender:self];
	}
	//収入
	else if(self.segment_is_income.selectedSegmentIndex == 1){
		[self performSegueWithIdentifier:@"add_category_income" sender:self];
	}
}

//収支の切り替え
-(IBAction)segment_changed:(UISegmentedControl*)sender{
	if(self.segment_is_income.selectedSegmentIndex == 0){
		cur_list = outcome_list;
	}
	else{
		cur_list = income_list;
	}
	cur_section_list = [self get_cur_section_list];
	
	[self.tableView reloadData];
}

//セル選択
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(self.tableView.isEditing == NO){
		Section_Data* section_data = cur_section_list[indexPath.section];
		DBCategory* category = section_data.category_list[indexPath.row];
		
		InputHistory* controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"InputHistory"];
		[controller setup_with_category_data:[category.cur get_data]];
		
		[self.navigationController pushViewController:controller animated:YES];
	}
	else{
		//セパレータ追加
		if(indexPath.section == 1){
			Category_Data* new_data = [[Category_Data alloc] init];
			
			//支出
			if(self.segment_is_income.selectedSegmentIndex == 0){
				new_data.is_income = NO;
				new_data.is_sepalator = YES;
			}
			//収入
			else{
				new_data.is_income = YES;
				new_data.is_sepalator = YES;
			}
			new_data.name = @"セパレータ";
			
			[g_model_ add_category2:new_data];
			[self update_model_data];
			
			//名前の編集状態にする
			SepalatorCell* cell = (SepalatorCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[cur_list count] - 1 inSection:0]];
			[cell.text_field becomeFirstResponder];
			
		}
	}
}

//キーボードの完了ボタン
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	
	return YES;
}

//テキスト編集完了
- (void) textFieldDidEndEditing:(UITextField *)textField{
	DBCategory* category = cur_list[textField.tag];
	Category_Data* new_data = [category.cur get_data];
	
	new_data.name = textField.text;
	[category edit_cur_data:new_data];
	
	[textField resignFirstResponder];
}

//テキストが変わった
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	
	return YES;
}

//セルの削除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete){
		DBCategory* category = cur_list[indexPath.row];
		[g_model_ del_category2:category];
		
		[self update_model_data];
    }
	else if(editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

//詳細表示
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	DBCategory* category = cur_list[indexPath.row];
	
	AddCategory* controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"AddCategory"];
	[controller init_for_edit_mode:category];
	
	[self.navigationController pushViewController:controller animated:YES];
}


@end
