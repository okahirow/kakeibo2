//
//  PeriodTypeSelect.m
//  kakeibo2
//
//  Created by hiro on 2013/04/18.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "PeriodTypeSelect.h"
#import "PeriodRepeatSelect.h"
#import "CommonAPI.h"

@interface PeriodTypeSelect ()

@property(strong) Period_Data* period_data;
@property(weak) id<SelectPeriodDataDelegate> delegate;

@end

@implementation PeriodTypeSelect


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) init_period_data:(Period_Data*)data delegate:(id)delegate{
	self.period_data = data;
	self.delegate = delegate;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section == 0){
		self.period_data.type = ONE_DAY;
		[self.delegate period_setting_selected:self.period_data];
		
		[self.navigationController popViewControllerAnimated:YES];
	}
	else{
		if(indexPath.row == 0){
			self.period_data.type = REPEAT_DAY;
		}
		else if(indexPath.row == 1){
			self.period_data.type = REPEAT_WEEK;
			int weekday = [CommonAPI weekday:self.period_data.start_date];
			for(int i=0; i<7; i++){
				if(i == weekday - 1){
					self.period_data.weekday_list[i] = @YES;
				}
				else{
					self.period_data.weekday_list[i] = @NO;
				}
			}
			
		}
		else if(indexPath.row == 2){
			self.period_data.type = REPEAT_MONTH;
		}
		else{
			self.period_data.type = REPEAT_YEAR;
		}
		
		PeriodRepeatSelect* controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"PeriodRepeatSelect"];
		[controller init_period_data:self.period_data delegate:self.delegate];
	
		[self.navigationController pushViewController:controller animated:YES];
	}
}

@end
