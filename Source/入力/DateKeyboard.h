//
//  DateKeyboard.h
//  kakeibo2
//
//  Created by hiro on 2013/04/16.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateKeyboard : UIViewController

- (void) init_text_field:(UITextField*)text_field date:(NSDate*)date delegate:(id)delegate;
- (void) set_date:(NSDate*)date;

@end

@protocol DataKeyboardDelegate
@required
- (void) date_changed:(DateKeyboard*)keyboard date:(NSDate*)date;
@end