//
//  InputHistory.h
//  kakeibo2
//
//  Created by hiro on 2013/04/15.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category_Data.h"
#import "DateKeyboard.h"


@interface InputHistory : UITableViewController<DataKeyboardDelegate>;

- (void) setup_with_category_data:(Category_Data*)data;

@end
