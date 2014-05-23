//
//  Ana_SelectCategory.h
//  PSPTimer
//
//  Created by hiro on 11/04/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUITableViewController.h"

@interface Ana_SelectCategory : MyUITableViewController {
	NSArray* category_list_;
}

@property (strong) NSArray* category_list_;

@end
