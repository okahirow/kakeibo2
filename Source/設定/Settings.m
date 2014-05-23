//
//  Settings.m
//  PSPTimer
//
//  Created by hiro on 10/11/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"
#import "MyModel.h"
#import "Settings_CustomAna.h"
#import "Settings_MonthEndDay.h"
#import "Setting_CrashLog.h"
#import "CommonAPI.h"
#import "Settings_MultiStartDay.h"
#import "MyUIActionSheet.h"

@implementation Settings


#pragma mark -
#pragma mark Initialization


/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"STR-010", nil);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if(section == 0){
		return 1;
	}
	else if(section == 1){
		return 8;
	}
	else if(section == 2){
		return 1;
	}
	else if(section == 3){
		return 2;
	}
	else{
		return 1;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
	if(indexPath.section == 0){
		NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
		
		UISwitch *switchObj = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 20.0)];
		switchObj.on = [settings boolForKey:@"IS_NARROW_CELL"];
		[switchObj addTarget:self action:@selector(narrow_cell_on_settingSwitchChanged:) forControlEvents:UIControlEventValueChanged];
		cell.accessoryView = switchObj;
		
		cell.textLabel.text = NSLocalizedString(@"STR-195", nil);
		cell.detailTextLabel.text = @"";
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		[cell.textLabel setMinimumScaleFactor:10];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	else if(indexPath.section == 1){
		if(indexPath.row == 0){
			cell.textLabel.text = NSLocalizedString(@"STR-011", nil);
			cell.detailTextLabel.text = NSLocalizedString(@"STR-012", nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else if(indexPath.row == 1){
			NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
			
			UISwitch *switchObj = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 20.0)];
			switchObj.on = [settings boolForKey:@"IS_ANA_MULTI"];
			[switchObj addTarget:self action:@selector(ana_multi_on_settingSwitchChanged:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = switchObj;
			
			cell.textLabel.text = NSLocalizedString(@"STR-178", nil);
			cell.detailTextLabel.text = NSLocalizedString(@"STR-179", nil);
			cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
			[cell.detailTextLabel setMinimumScaleFactor:10];
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else if(indexPath.row == 2){
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
			
			cell.textLabel.text = @"累積金額の開始日";
			
			NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
			NSDate* date = [settings objectForKey:@"ANA_MULTI_START_DATE"];
			
			if(date == nil){
				cell.detailTextLabel.text = @"指定なし";
			}
			else{
				NSDateFormatter* form = [[NSDateFormatter alloc] init];
				[form setDateStyle:NSDateFormatterMediumStyle];
				[form setTimeStyle:NSDateFormatterNoStyle];
				
				cell.detailTextLabel.text = [form stringFromDate:date];
			}
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else if(indexPath.row == 3){
			NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
			
			cell.textLabel.text = NSLocalizedString(@"STR-180", nil);
			cell.textLabel.adjustsFontSizeToFitWidth = YES;
			[cell.textLabel setMinimumScaleFactor:10];
			
			cell.detailTextLabel.text = NSLocalizedString(@"STR-183", nil);
			cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
			[cell.detailTextLabel setMinimumScaleFactor:10];
			
			//UISegmentedControl *segmentObj = [[UISegmentedControl alloc] initWithFrame:CGRectMake(1.0, 1.0, 60.0, 20.0)];
			UISegmentedControl *segmentObj = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"STR-181", nil), NSLocalizedString(@"STR-182", nil)]];
			segmentObj.frame = CGRectMake(1.0, 1.0, 120.0, 30.0);
			//[segmentObj setSegmentedControlStyle:UISegmentedControlStyleBar];
			
			if([settings boolForKey:@"IS_SORT_ASCEND"] == TRUE){
				segmentObj.selectedSegmentIndex = 0;
			}
			else{
				segmentObj.selectedSegmentIndex = 1;
			}
			
			[segmentObj setTitle:NSLocalizedString(@"STR-181", nil) forSegmentAtIndex:0];
			[segmentObj setTitle:NSLocalizedString(@"STR-182", nil) forSegmentAtIndex:1];
			
			cell.accessoryView = segmentObj;
			[segmentObj addTarget:self action:@selector(sort_type_settingSegmentChanged:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = segmentObj;			
			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else if(indexPath.row == 4){
			NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
			
			cell.textLabel.text = NSLocalizedString(@"STR-185", nil);
			
			UITextField *text_field = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 70.0, 22.0)];
			text_field.text = [settings stringForKey:@"MONEY_UNIT"];
			text_field.placeholder = NSLocalizedString(@"STR-032", nil);
			text_field.textAlignment = NSTextAlignmentLeft;
			text_field.autocapitalizationType = UITextAutocapitalizationTypeNone;
			text_field.keyboardType = UIKeyboardTypeEmailAddress;
			text_field.returnKeyType = UIReturnKeyDone;
			text_field.textAlignment = NSTextAlignmentRight;
			
			//[text_field addTarget:self action:@selector(money_unit_edit:) forControlEvents:UIControlEventEditingChanged];
			[text_field addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventEditingDidEndOnExit];
			//[text_field addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventEditingDidEnd];
			
			cell.accessoryView = text_field;
			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			cell.detailTextLabel.text = NSLocalizedString(@"STR-186", nil);
		}
		else if(indexPath.row == 5){
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
			
			cell.textLabel.text = NSLocalizedString(@"STR-196", nil);
			
			NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
			int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
			if(month_end_day > 0){
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%d%@", month_end_day, NSLocalizedString(@"STR-197", nil)];
			}
			else{
				cell.detailTextLabel.text = NSLocalizedString(@"STR-198", nil);
			}
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else if(indexPath.row == 6){
			NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
			
			UISwitch *switchObj = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 20.0)];
			switchObj.on = [settings boolForKey:@"IS_HIDE_0"];
			[switchObj addTarget:self action:@selector(hide_0_on_settingSwitchChanged:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = switchObj;
			
			cell.textLabel.text = NSLocalizedString(@"STR-212", nil);
			cell.textLabel.adjustsFontSizeToFitWidth = YES;
			[cell.textLabel setMinimumScaleFactor:10];
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else{
			NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
			
			cell.textLabel.text = @"デフォルト集計期間";
			cell.textLabel.adjustsFontSizeToFitWidth = YES;
			[cell.textLabel setMinimumScaleFactor:10];
						
			UISegmentedControl *segmentObj = [[UISegmentedControl alloc] initWithItems:@[@"年", @"月", @"日"]];
			segmentObj.frame = CGRectMake(1.0, 1.0, 120.0, 30.0);
					
			segmentObj.selectedSegmentIndex = [settings integerForKey:@"DEFAULT_PERIOD"];
						
			cell.accessoryView = segmentObj;
			[segmentObj addTarget:self action:@selector(default_period_settingSegmentChanged:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = segmentObj;			
			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}
	else if(indexPath.section == 2){
		NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
		
		cell.textLabel.text = @"起動時パスワード";
		cell.detailTextLabel.text = @"";
		
		UITextField *text_field = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 120.0, 22.0)];
		text_field.text = [settings stringForKey:@"START_PASS"];
		text_field.placeholder = @"パスワードなし";
		text_field.textAlignment = NSTextAlignmentLeft;
		text_field.autocapitalizationType = UITextAutocapitalizationTypeNone;
		text_field.keyboardType = UIKeyboardTypeASCIICapable;
		text_field.returnKeyType = UIReturnKeyDone;
		text_field.secureTextEntry = YES;
		[text_field addTarget:self action:@selector(pass_edit_end:) forControlEvents:UIControlEventEditingDidEndOnExit];
		[text_field addTarget:self action:@selector(pass_edit_end:) forControlEvents:UIControlEventEditingDidEnd];
				
		cell.accessoryView = text_field;
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	else if(indexPath.section == 3){
		if(indexPath.row == 0){
			cell.textLabel.text = NSLocalizedString(@"STR-013", nil);
			cell.detailTextLabel.text = @"";
		}
		else{
			cell.textLabel.text = NSLocalizedString(@"STR-014", nil);
			cell.detailTextLabel.text = @"";
		}
		cell.accessoryView = nil;
	}
	else{
		if(indexPath.row == 0){
			cell.textLabel.text = NSLocalizedString(@"STR-131", nil);
			cell.detailTextLabel.text = NSLocalizedString(@"STR-132", nil);
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		else{
			cell.textLabel.text = NSLocalizedString(@"STR-205", nil);
			cell.detailTextLabel.text = NSLocalizedString(@"STR-206", nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		cell.accessoryView = nil;		
	}
    
    return cell;
}


//セクション名
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 0){
		return NSLocalizedString(@"STR-194", nil);
	}
	else if(section == 1){
		return NSLocalizedString(@"STR-015", nil);
	}
	else if(section == 2){
		return @"起動";
	}
	else if(section == 3){
		return NSLocalizedString(@"STR-016", nil);
	}
	else{
		return NSLocalizedString(@"STR-130", nil);
	}
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void) reset_navigation_history{
	NSArray* nav_controllers = self.tabBarController.viewControllers;
	
	UINavigationController* tab1_nav = nav_controllers[0];
	UINavigationController* tab2_nav = nav_controllers[1];
	UINavigationController* tab3_nav = nav_controllers[2];
	
	[tab1_nav popToRootViewControllerAnimated:FALSE];
	[tab2_nav popToRootViewControllerAnimated:FALSE];
	[tab3_nav popToRootViewControllerAnimated:FALSE];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if([actionSheet.title isEqualToString:NSLocalizedString(@"STR-017", nil)] == TRUE){
		//実行
		if(buttonIndex == 0){
			[g_model_ del_all_history_actuary];
			[self reset_navigation_history];
			
			return;
		}
		//キャンセル
		else{
			return;
		}
	}
	//全削除
	else if([actionSheet.title isEqualToString:NSLocalizedString(@"STR-018", nil)] == TRUE){
		//実行
		if(buttonIndex == 0){
			[g_model_ del_all_category_actuary];
			[g_model_ del_all_custom_ana_actuary];
			[g_model_ del_all_history_actuary];
			[self reset_navigation_history];
			
			return;
		}
		//キャンセル
		else{
			return;
		}
	}
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0){

	}
	else if(indexPath.section == 1){
		if(indexPath.row == 0){
			UIViewController* next_view = [[Settings_CustomAna alloc] init];
			[self.navigationController pushViewController:next_view animated:YES];
		}
		else if(indexPath.row == 2){
			UIViewController* next_view = [[Settings_MultiStartDay alloc] init];
			[self.navigationController pushViewController:next_view animated:YES];
		}
		else if(indexPath.row == 5){
			UIViewController* next_view = [[Settings_MonthEndDay alloc] init];
			[self.navigationController pushViewController:next_view animated:YES];
		}
	}
	else if(indexPath.section == 2){
		
	}
	else if(indexPath.section == 3){
		if(indexPath.row == 0){
			UIActionSheet* sheet = [[MyUIActionSheet alloc] init];
			sheet.delegate = self;
			sheet.title = NSLocalizedString(@"STR-017", nil);
			[sheet addButtonWithTitle:NSLocalizedString(@"STR-008", nil)];
			[sheet addButtonWithTitle:NSLocalizedString(@"STR-003", nil)];
			sheet.cancelButtonIndex = 1;
			sheet.destructiveButtonIndex = 0;
			[sheet showInView:self.tabBarController.view];	
		}
		else{
			UIActionSheet* sheet = [[MyUIActionSheet alloc] init];
			sheet.delegate = self;
			sheet.title = NSLocalizedString(@"STR-018", nil);
			[sheet addButtonWithTitle:NSLocalizedString(@"STR-008", nil)];
			 [sheet addButtonWithTitle:NSLocalizedString(@"STR-003", nil)];
			sheet.destructiveButtonIndex = 0;
			sheet.cancelButtonIndex = 1;
			[sheet showInView:self.tabBarController.view];	
		}		
	}
	else{
		if(indexPath.row == 0){
			NSArray* to_list = @[@"oka.hirow.apple@gmail.com"];
			
			//メール送信可能かどうかのチェック
			if (![MFMailComposeViewController canSendMail]) {
				UIAlertView* alart = [[UIAlertView alloc] init];
				alart.message = NSLocalizedString(@"STR-133", nil);
				[alart addButtonWithTitle:NSLocalizedString(@"STR-006", nil)];
				[alart show];
				return;
			}
			
			//メールコントローラの生成
			MFMailComposeViewController* pickerCtl= [[MFMailComposeViewController alloc] init];
			pickerCtl.mailComposeDelegate=self;
			
			//メールのテキストの指定
			NSString *versionString;
			versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"];
			
			NSString* msg_title;
			if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"jp.oka.hirow.app.kakeibo.free"]){
				msg_title = [NSString stringWithFormat:@"[%@ %@ %@] %@", NSLocalizedString(@"STR-136", nil), @"Free", versionString, NSLocalizedString(@"STR-134", nil)];
			}
			else{
				msg_title = [NSString stringWithFormat:@"[%@ %@] %@", NSLocalizedString(@"STR-136", nil), versionString, NSLocalizedString(@"STR-134", nil)];
			}
			
			[pickerCtl setSubject:msg_title];
			[pickerCtl setToRecipients:to_list];
			[pickerCtl setMessageBody:@"" isHTML:NO];
			
			//メールコントローラのビューを開く
			[self presentViewController:pickerCtl animated:YES completion:nil];
		}
		else if(indexPath.row == 1){
			UIViewController* next_view = [[Setting_CrashLog alloc] init];
			[self.navigationController pushViewController:next_view animated:YES];
		}
	}
}


//メール送信完了時に呼ばれる
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (error!=nil){
		UIAlertView* alart = [[UIAlertView alloc] init];
		alart.message = NSLocalizedString(@"STR-133", nil);
		[alart addButtonWithTitle:NSLocalizedString(@"STR-006", nil)];
		[alart show];
	}
	
    //オープン中のビューコントローラを閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)narrow_cell_on_settingSwitchChanged:(id)sender{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	
	if([sender isOn] == TRUE){
		[settings setBool:TRUE forKey:@"IS_NARROW_CELL"];
	}
	else{
		[settings setBool:FALSE forKey:@"IS_NARROW_CELL"];
	}
	
	[self.tableView reloadData];
}

- (IBAction)ana_multi_on_settingSwitchChanged:(id)sender{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	
	if([sender isOn] == TRUE){
		[settings setBool:TRUE forKey:@"IS_ANA_MULTI"];
	}
	else{
		[settings setBool:FALSE forKey:@"IS_ANA_MULTI"];
	}
	
	[self.tableView reloadData];
}

- (IBAction)sort_type_settingSegmentChanged:(id)sender{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	
	if([(UISegmentedControl*)sender selectedSegmentIndex] == 0){
		[settings setBool:TRUE forKey:@"IS_SORT_ASCEND"];
	}
	else{
		[settings setBool:FALSE forKey:@"IS_SORT_ASCEND"];
	}
	
	[self.tableView reloadData];
}

- (IBAction)default_period_settingSegmentChanged:(id)sender{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	
	[settings setInteger:[(UISegmentedControl*)sender selectedSegmentIndex] forKey:@"DEFAULT_PERIOD"];
	
	[self.tableView reloadData];
}

- (IBAction)hide_0_on_settingSwitchChanged:(id)sender{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	
	if([sender isOn] == TRUE){
		[settings setBool:TRUE forKey:@"IS_HIDE_0"];
	}
	else{
		[settings setBool:FALSE forKey:@"IS_HIDE_0"];
	}
	
	[self.tableView reloadData];
}


- (BOOL) money_unit_edit:(UITextField *)textField{	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	[settings setValue:textField.text forKey:@"MONEY_UNIT"];
	
	[textField resignFirstResponder];
	
	return TRUE;
}

//テキストの編集が終わったとき
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	
	//不正な文字が含まれる場合
	if([CommonAPI is_valid_string:textField.text] == false){
		UIAlertView* alart = [[UIAlertView alloc] initWithTitle:nil 
														 message:NSLocalizedString(@"STR-207", nil) 
														delegate:nil 
											   cancelButtonTitle:nil 
											   otherButtonTitles:NSLocalizedString(@"STR-081", nil), nil];
		
		[alart show];
		
		textField.text = [settings valueForKey:@"MONEY_UNIT"];
		
		return FALSE;
	}
	
	
	[settings setValue:textField.text forKey:@"MONEY_UNIT"];
		
	//[textField resignFirstResponder];
	
	return TRUE;
}

//パスワードの編集完了
- (BOOL) pass_edit_end:(UITextField *)textField{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	[settings setValue:textField.text forKey:@"START_PASS"];
	
	[textField resignFirstResponder];
	
	return TRUE;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}




@end

