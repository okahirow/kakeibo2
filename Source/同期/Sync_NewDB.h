//
//  Sync_NewDB.h
//  kakeibo
//
//  Created by hiro on 11/04/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUIViewController.h"


@interface Sync_NewDB : MyUIViewController<UITextFieldDelegate> {
	IBOutlet UITextField* text_field_;
}

- (void) cancel_button_tap;

@end
