//
//  Settings_CustomAna_Edit.h
//  kakeibo
//
//  Created by hiro on 11/04/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUIViewController.h"
#import "MyModel.h"
#import "Settings_CustomAna_Add.h"


@interface Settings_CustomAna_Edit : Settings_CustomAna_Add <UIActionSheetDelegate> {
	DBCustomAna* custom_ana_;
	IBOutlet UISwitch* switch_;
	IBOutlet UIButton* del_button_;
}

@property (strong) DBCustomAna* custom_ana_;

- (id) initWithCustomAna:(DBCustomAna*) ana;

- (IBAction) del_button_tap;
- (IBAction) SwitchChanged:(UISwitch*)sender;

@end
