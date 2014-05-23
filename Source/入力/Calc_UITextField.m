//
//  Calc_UITextField.m
//  kakeibo
//
//  Created by hiro on 12/01/06.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Calc_UITextField.h"
#import "CalcKeyboard.h"

@implementation Calc_UITextField

- (UIView *)inputView {
    CalcKeyboard *vc = [[self.window.rootViewController storyboard] instantiateViewControllerWithIdentifier:@"CalcKeyboard"];
	vc.text_field = self;
	
    return vc.view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
