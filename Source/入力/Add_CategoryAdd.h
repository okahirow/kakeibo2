//
//  Add_CategoryAdd.h
//  kakeibo
//
//  Created by hiro on 11/04/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUIViewController.h"
#import "MyModel.h"


@interface Add_CategoryAdd : MyUIViewController <UITextFieldDelegate> {
	IBOutlet UITextField* text_field_;
}

- (IBAction) save_button_tap;
- (IBAction) cancel_button_tap;
- (BOOL) text_edit:(UITextField *)textField;
- (IBAction) text_edit_end:(UITextField *)textField;
- (void) update_add_button;

@end
