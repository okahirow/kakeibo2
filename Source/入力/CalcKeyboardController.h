//
//  CalcKeyboardController.h
//  kakeibo
//
//  Created by hiro on 12/01/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import "Calc_UITextField.h"

@interface CalcKeyboardController : UIViewController <UIInputViewAudioFeedback>

typedef enum {Input_val1, Select_ope, Input_val2, Show_ret} Calc_state;
typedef enum {Plus, Minus} Operation_type;

@property (nonatomic, strong) Calc_UITextField *text_field;
@property (nonatomic, assign) int val1;
@property (nonatomic, assign) int val2;
@property (nonatomic, assign) int ret;
@property (nonatomic, assign) Operation_type ope;
@property (nonatomic, assign) Calc_state state;
@property (nonatomic, strong) IBOutlet UIButton* plus_button;
@property (nonatomic, strong) IBOutlet UIButton* minus_button;
@property (nonatomic, strong) IBOutlet UIButton* equal_button;
@property (nonatomic, strong) IBOutlet UIButton* clear_button;
@property (nonatomic, strong) IBOutlet UIButton* del_button;
@property (nonatomic, strong) IBOutlet UIButton* save_button;


- (IBAction) num_button_tap:(id) sender;
- (IBAction) plus_button_tap;
- (IBAction) minus_button_tap;
- (IBAction) equal_button_tap;
- (IBAction) clear_button_tap;
- (IBAction) del_button_tap;
- (IBAction) save_button_tap;
- (void) play_click_sound;


@end
