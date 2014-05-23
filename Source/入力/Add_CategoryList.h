//
//  Add_CategoryList.h
//  kakeibo
//
//  Created by hiro on 11/03/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"MyUITableViewController.h"


@interface Add_CategoryList : MyUITableViewController {
	NSMutableArray* category_list_;
}

@property (strong) NSMutableArray* category_list_;

- (void) tap_add;
- (void) tap_edit;

@end
