//
//  Add_CategoryDetail.h
//  kakeibo
//
//  Created by hiro on 11/04/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUIViewController.h"
#import "MyModel.h"


@interface Add_CategoryDetail : MyUIViewController<UIActionSheetDelegate> {
	IBOutlet UITextField* text_field_;
	IBOutlet UIButton* del_button_;
	
	DBCategory* category_;
}

@property (strong) DBCategory* category_;

- (id) initWithCategory:(DBCategory*)category;

- (IBAction) save_button_tap;
- (IBAction) cancel_button_tap;
- (IBAction) del_button_tap;
- (BOOL) text_edit:(UITextField *)textField;
- (IBAction) text_edit_end:(UITextField *)textField;
- (void) update_add_button;
- (IBAction) confirm_change_history;

@end
