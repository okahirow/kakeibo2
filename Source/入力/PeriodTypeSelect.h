//
//  RepeatTypeSelect.h
//  kakeibo2
//
//  Created by hiro on 2013/04/18.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Period_Data.h"

@interface PeriodTypeSelect : UITableViewController

- (void) init_period_data:(Period_Data*)data delegate:(id)delegate;

@end
