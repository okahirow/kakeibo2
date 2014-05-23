//
//  MyUITableView.m
//  PSPTimer
//
//  Created by hiro on 10/11/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyUITableView.h"


@implementation MyUITableView

@synthesize controller_;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.controller_ = nil;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if ((self = [super initWithFrame:frame style:style])) {
        // Initialization code
		self.controller_ = nil;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//スワイプ右を検知
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
	touch_begin_ = [[touches anyObject] locationInView:self];
	
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{
	CGPoint point = [[touches anyObject] locationInView:self];
	
	NSInteger distance_horizontal = point.x - touch_begin_.x;
	NSInteger distance_vertical = point.y - touch_begin_.y;
	
	//右にスワイプした場合
	if(abs(distance_horizontal) > abs(distance_vertical) && distance_horizontal >= 50){
		//前の画面に戻る
		//[self.controller_.navigationController popViewControllerAnimated:YES];
		
		return;
	}
	
	[super touchesMoved:touches withEvent:event];
}



@end
