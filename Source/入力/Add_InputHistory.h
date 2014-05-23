//
//  Add_InputHistory.h
//  kakeibo
//
//  Created by hiro on 11/04/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUITableView.h"
#import "MyUIViewController.h"

@interface Add_InputHistory : MyUIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	NSString* category_name_;
	NSDate* date_;
	NSString* memo_;
	
	UITextField* val_text_field_;
	UITextField* memo_text_field_;
	
	IBOutlet MyUITableView* table_view_;
	IBOutlet UIDatePicker* date_picker_;
}

@property (copy) NSString* category_name_;
@property (copy) NSDate* date_;
@property (copy) NSString* memo_;
@property (strong) UITextField* val_text_field_;
@property (strong) UITextField* memo_text_field_;

- (id) initWithCategoryName:(NSString*)category_name;
- (IBAction) add_button_tap;
- (BOOL) val_edit_end:(UITextField *)textField;
- (BOOL) val_edit_start:(UITextField *)textField;
- (BOOL) memo_edit_end:(UITextField *)textField;
- (BOOL) memo_edit_start:(UITextField *)textField;
- (void) update_add_button;
- (void) show_date_picker:(BOOL)is_show anim:(BOOL)is_anim;
- (IBAction) pickerDidChange:(UIDatePicker*)date_picker;
- (IBAction) cancel_button_tap;

@end
