//
//  ColorSelect.h
//  kakeibo2
//
//  Created by hiro on 2013/03/19.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyColor;

@protocol ColorSelectDelegate
@required
- (void) color_selected:(MyColor*)color;
@end


@interface ColorSelect : UITableViewController

@property id<ColorSelectDelegate> color_select_delegate;
@property MyColor* cur_color;

@property IBOutlet UISlider* slider_r;
@property IBOutlet UISlider* slider_g;
@property IBOutlet UISlider* slider_b;

@property IBOutlet UILabel* label_r;
@property IBOutlet UILabel* label_g;
@property IBOutlet UILabel* label_b;

@property IBOutlet UILabel* label_color;

- (IBAction) color_tap:(UIButton*)sender;
- (IBAction) slider_move:(UISlider*)sender;
- (IBAction) done_tap:(id)sender;

@end
