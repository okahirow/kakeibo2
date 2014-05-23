//
//  Settings_MutiSelectDate.h
//  kakeibo
//
//  Created by hiro on 12/06/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Settings_MutiSelectDate : UIViewController{
	IBOutlet UIDatePicker* date_picker;
}

- (IBAction) save_button_tap;

@end
