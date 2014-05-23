//
//  AddCategory.h
//  kakeibo2
//
//  Created by hiro on 2013/03/19.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorSelect.h"
#import "Category_Data.h"
#import "DBCategory.h"

@interface AddCategory : UITableViewController<ColorSelectDelegate, UITextFieldDelegate>

@property IBOutlet UISegmentedControl* segment_is_income;

@property IBOutlet UILabel* label_color;

@property IBOutlet UITextField* text_category_name;
@property IBOutlet UITextField* text_budget_year;
@property IBOutlet UITextField* text_budget_month;
@property IBOutlet UITextField* text_budget_day;

- (IBAction) segment_change:(UISegmentedControl*)sender;
- (IBAction) tap_save:(id)sender;

- (void) init_for_add_mode:(Category_Data*)data;
- (void) init_for_edit_mode:(DBCategory*)category;

@end
