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


@interface Add_SeparatorAdd : MyUIViewController <UITextFieldDelegate> {
	IBOutlet UITextField* text_field_;
}

- (IBAction) save_button_tap;
- (IBAction) cancel_button_tap;
- (IBAction) text_edit_end:(UITextField *)textField;

@end
