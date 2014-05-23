//
//  GraphView_Circle.h
//  PSPTimer
//
//  Created by hiro on 11/02/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GraphView_Circle : UIView {
	NSArray* cat_data_list;
}

@property (strong) NSArray* cat_data_list;

- (void)drawBase:(CGContextRef)ctx;
- (void)drawCircle:(CGContextRef)ctx;
- (void)set_draw_data:(NSArray*)cat_rate_list_ cat_color_list:(NSArray*)cat_color_list_;

@end
