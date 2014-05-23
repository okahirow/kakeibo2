//
//  Start_Login.h
//  kakeibo
//
//  Created by hiro on 12/06/06.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Start_Login : UIViewController <UITextViewDelegate>{
	IBOutlet UITextField* text_field;
}

- (IBAction) login;

@end
