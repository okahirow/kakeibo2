//
//  Add_Top.h
//  kakeibo2
//
//  Created by hiro on 2013/03/26.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Input_Top : UITableViewController <UIActionSheetDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property IBOutlet UISegmentedControl* segment_is_income;

-(IBAction)tap_add:(id)sender;
-(IBAction)segment_changed:(UISegmentedControl*)sender;

@end
