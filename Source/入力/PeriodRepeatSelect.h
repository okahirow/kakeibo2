//
//  PeriodRepeatSelect.h
//  kakeibo2
//
//  Created by hiro on 2013/04/18.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Period_Data.h"
#import "DateKeyboard.h"

@interface PeriodRepeatSelect : UITableViewController<DataKeyboardDelegate>

- (void) init_period_data:(Period_Data*)data delegate:(id)delegate;

@end
