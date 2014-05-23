//
//  Settings.h
//  PSPTimer
//
//  Created by hiro on 10/11/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUITableViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface Settings : MyUITableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>{

}

- (IBAction)narrow_cell_on_settingSwitchChanged:(id)sender;
- (IBAction)ana_multi_on_settingSwitchChanged:(id)sender;
- (IBAction)sort_type_settingSegmentChanged:(id)sender;
- (IBAction)default_period_settingSegmentChanged:(id)sender;
- (IBAction)hide_0_on_settingSwitchChanged:(id)sender;

- (BOOL) money_unit_edit:(UITextField *)textField;
- (BOOL) pass_edit_end:(UITextField *)textField;
	
@end
