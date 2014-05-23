//
//  Sync_Conflict.h
//  PSPTimer
//
//  Created by hiro on 10/11/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUITableViewController.h"

@interface Sync_Conflict : MyUITableViewController <UIActionSheetDelegate> {
	NSArray* conflict_category_list_;
	NSArray* conflict_history_list_;
	NSArray* conflict_custom_list_;
	
	UIImage* img_radio_button_on_;
	UIImage* img_radio_button_off_;

}

@property (strong) NSArray* conflict_category_list_;
@property (strong) NSArray* conflict_history_list_;
@property (strong) NSArray* conflict_custom_list_;
@property (strong) UIImage* img_radio_button_on_;
@property (strong) UIImage* img_radio_button_off_;

- (id) initWithConflict:(NSArray*)conflict_category_list history:(NSArray*)conflict_history_list custom:(NSArray*)conflict_custom_list;
- (void) cancel_button_tap;
- (void) done_button_tap;

@end
