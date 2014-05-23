//
//  Ana_InputCategory.h
//  PSPTimer
//
//  Created by hiro on 10/11/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUIViewController.h"

@interface Ana_InputCategory : MyUIViewController<UITextFieldDelegate> {
	IBOutlet UITextField* textField_;
}

- (void) cancel_button_tap;

@end
