//
//  GraphView.h
//  PSPTimer
//
//  Created by hiro on 11/02/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphVLabelView.h"


@interface GraphView : UIView {
	NSArray* horizontal_point_label_;
	NSArray* line_data_;
	NSArray* line_color_;
	int v_unit_;
	int period_type_;
	
	BOOL is_line_graph_;
	
	IBOutlet GraphVLabelView* vlabel_view_;
}

@property (strong) NSArray* horizontal_point_label_;
@property (strong) NSArray* line_data_;
@property (strong) NSArray* line_color_;
@property (assign) BOOL is_line_graph_;

- (void)drawBase:(CGContextRef)ctx;
- (void)drawLine:(CGContextRef)ctx;
- (void)drawBar:(CGContextRef)ctx;
- (void)set_hol_point_labels:(NSArray*)hol_point_labels;
- (void)set_draw_data:(NSArray*)line_data line_color:(NSArray*)line_color;
- (void)set_is_line_graph:(BOOL)is_line;

- (float)get_vertical_unit;

#define PERIOD_TYPE_DAY 0
#define PERIOD_TYPE_WEEK 1
#define PERIOD_TYPE_MONTH 2

@end
