//
//  Settings_CustomAna.h
//  kakeibo
//
//  Created by hiro on 11/03/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"MyUITableViewController.h"


@interface Settings_CustomAna : MyUITableViewController {
	NSMutableArray* custom_ana_list_;
}

@property (strong) NSMutableArray* custom_ana_list_;

- (void) tap_add;
- (void) tap_edit;

@end
