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


@interface Add_SeparatorDetail : MyUIViewController<UIActionSheetDelegate> {
	IBOutlet UITextField* text_field_;
	IBOutlet UIButton* del_button_;
	
	DBCategory* category_;
}

@property (strong) DBCategory* category_;

- (id) initWithCategory:(DBCategory*)category;

- (IBAction) save_button_tap;
- (IBAction) cancel_button_tap;
- (IBAction) del_button_tap;
- (IBAction) text_edit_end:(UITextField *)textField;

@end
