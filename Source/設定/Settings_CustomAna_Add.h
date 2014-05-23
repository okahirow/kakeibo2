//
//  Settings_CustomAna_Add.h
//  kakeibo
//
//  Created by hiro on 11/04/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUIViewController.h"
#import "MyModel.h"


@interface Settings_CustomAna_Add : MyUIViewController <UITextFieldDelegate, UITextViewDelegate> {
	IBOutlet UITextField* text_field_;
	IBOutlet UITextView* text_view_;
	IBOutlet UILabel* sample_label_;
	IBOutlet UISegmentedControl* segment_;
}

- (IBAction) insert_button_tap;
- (IBAction) save_button_tap;
- (IBAction) cancel_button_tap;
- (BOOL) text_edit:(UITextField *)textField;
- (IBAction) text_edit_end:(UITextField *)textField;
- (void) update_add_button;

- (void) Settings_CustomAna_Add:(NSString*) name;

@end
