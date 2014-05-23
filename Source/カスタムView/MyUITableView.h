//
//  MyUITableView.h
//  PSPTimer
//
//  Created by hiro on 10/11/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyUITableView : UITableView {
	CGPoint touch_begin_;
	UIViewController* controller_;
}

@property (strong) UIViewController* controller_;

@end
