//
//  CalenderDay_View.h
//  kakeibo
//
//  Created by hiro on 12/06/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Calender_protocol
- (IBAction) date_selected:(int)unit_ year:(int)year_ month:(int)month_ day:(int)day_;
@end

@interface CalenderDay_View : UIView{
	IBOutlet UIView* top_view;
	
	IBOutlet UIButton* next_button;
	IBOutlet UIButton* prev_button;
	IBOutlet UILabel* title_label;
	
	id date_select_delegate;
	
	int year_cur;
	int month_cur;
	
	NSMutableArray* date_button_list;
}

- (void) set_info:(NSDate*)start_date_ delegate:(id)delegate_;

- (void) update_date_button;

- (IBAction) tap_next:(id)sender;
- (IBAction) tap_prev:(id)sender;
- (IBAction) tap_date:(id)sender;

- (void) draw_base:(CGContextRef)ctx;
- (void) draw_line:(CGContextRef)ctx;


@end
