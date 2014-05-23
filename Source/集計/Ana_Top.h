//
//  Ana_Top.h
//  kakeibo
//
//  Created by hiro on 11/04/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphVLabelView.h"
#import "GraphView.h"
#import "GraphView_Circle.h"
#import "CalenderDay_View.h"
#import "MyUIViewController.h"

@interface Ana_Top : MyUIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, Calender_protocol> {
	IBOutlet UITableView* table_view_;
	IBOutlet UISegmentedControl* segment_;
	
	NSInteger sel_segment_;
	NSInteger year_cur_;
	NSInteger month_cur_;
	NSInteger day_cur_;
	
	NSArray* history_list_;
	NSArray* custom_ana_list_;
	NSArray* ana_category_list_;
	int all_cat_total_;
	
	//グラフ用
	NSMutableArray* is_graph_on_;
	NSArray* color_list_;
	NSMutableArray* color_line_;

	IBOutlet GraphView* graph_view_;
	IBOutlet UIScrollView* scroll_view_;
	IBOutlet GraphVLabelView* graph_v_label_view_;
	IBOutlet UIView* graph_sub_view_;
	IBOutlet GraphView_Circle* graph_view_circle_;
	
	UIButton* graph_type_button_;
	
	UIImage* img_graph_line_;
	UIImage* img_graph_bar_;
	
	UIButton* period_button_;
	
	NSInteger cur_period_; //0=year, 1=month, 2=day
	
	BOOL is_ana_multi_;
}

@property (assign) NSInteger sel_segment_;
@property (assign) NSInteger year_cur_;
@property (assign) NSInteger month_cur_;
@property (assign) NSInteger day_cur_;
@property (strong) NSArray* history_list_;
@property (strong) NSArray* custom_ana_list_;
@property (strong) NSArray* ana_category_list_;
@property (strong) UIButton* graph_type_button_;
@property (strong) UIImage* img_graph_line_;
@property (strong) UIImage* img_graph_bar_;
@property (strong) UIButton* period_button_;

- (IBAction) segmentDidChange:(id)sender;

- (void) get_ana_data;
- (void) update_title;

- (void) prev_month_button_tap;
- (void) next_month_button_tap;
- (void) period_button_tap;
- (void) reset_month;
- (void) reset_segment;
- (void) reset_ana_data;

- (void) update_show_view;

//グラフ用
@property (strong) NSMutableArray* is_graph_on_;
@property (strong) NSArray* color_list_;
@property (strong) NSMutableArray* cat_color_list_;

- (void) change_is_show_cat:(NSInteger) data_index;
- (void) update_graph;
- (void) init_graph_data;
- (NSArray*) get_color_list;
- (NSMutableArray*) get_holizontal_label_list;
- (void) tap_graph_type_button;

- (int) get_day_num_in_month:(NSInteger)year month:(NSInteger)month;


@end
