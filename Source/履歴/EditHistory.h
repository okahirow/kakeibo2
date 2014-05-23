//
//  EditHistory.h
//  kakeibo2
//
//  Created by hiro on 2013/05/12.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "InputHistory.h"
#import "Event.h"
#import "History_Data.h"
#import "CommonAPI.h"
#import "CalcKeyboard.h"
#import "DateKeyboard.h"
#import "PeriodTypeSelect.h"
#import "MyModel.h"

@interface EditHistory : UITableViewController<DataKeyboardDelegate, UIActionSheetDelegate>;

- (void) setup_with_event:(Event*)event;

@end
