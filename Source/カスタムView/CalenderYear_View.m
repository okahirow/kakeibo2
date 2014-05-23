//
//  CalenderYear_View.m
//  kakeibo
//
//  Created by hiro on 12/06/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CalenderYear_View.h"

#define YEAR_TOP_Y 75
#define LEFT_MARGIN 20
#define YEAR_HEIGHT 45
#define YEAR_WIDTH 140

@implementation CalenderYear_View

- (void) set_info:(NSDate*)start_date_ delegate:(id)delegate_{
	date_select_delegate = delegate_;
	
	NSDateComponents* components = [[NSCalendar currentCalendar] components: NSYearCalendarUnit | NSMonthCalendarUnit fromDate:start_date_];
	year_cur = ([components year] / 10) * 10;
	
	UIImage* img_normal = [UIImage imageNamed:@"calender_button_normal.png"];
	UIImage* img_pressed = [UIImage imageNamed:@"calender_button_pressed.png"];
	
	date_button_list = [[NSMutableArray alloc] init];
	for(int i=0; i<5; i++){
		for(int j=0; j<2; j++){
			UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
			[button setBackgroundImage:img_normal forState:UIControlStateNormal];
			[button setBackgroundImage:img_pressed forState:UIControlStateHighlighted];
			
			[button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
			[button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
			button.frame = CGRectMake(LEFT_MARGIN + 1 + YEAR_WIDTH * j, 1 + YEAR_TOP_Y + (YEAR_HEIGHT * i), YEAR_WIDTH - 2, YEAR_HEIGHT - 2);
			[button addTarget:self action:@selector(tap_date:) forControlEvents:UIControlEventTouchUpInside];
			[top_view addSubview:button];
			
			[date_button_list addObject:button];
		}
	}
	
	[self update_date_button];
}

- (void)awakeFromNib {
    [[NSBundle mainBundle] loadNibNamed:@"CalenderYear_View" owner:self options:nil];
    [self addSubview:top_view];
	
	date_select_delegate = nil;
	year_cur = 0;
	date_button_list = nil;
}

- (void) draw_line:(CGContextRef)ctx{
	//線
	CGContextSetLineWidth(ctx, 1);
	CGContextSetRGBStrokeColor(ctx, 0.4, 0.4, 0.4, 1);
	
	//横線
	for(int i=0; i<6; i++){
		CGContextMoveToPoint(ctx, LEFT_MARGIN, YEAR_TOP_Y + (YEAR_HEIGHT * i));
		CGContextAddLineToPoint(ctx, LEFT_MARGIN + (YEAR_WIDTH * 2), YEAR_TOP_Y + (YEAR_HEIGHT * i));
		CGContextStrokePath(ctx);
	}
	
	//縦線
	for(int i=0; i<3; i++){
		CGContextMoveToPoint(ctx, LEFT_MARGIN + (YEAR_WIDTH * i), YEAR_TOP_Y);
		CGContextAddLineToPoint(ctx, LEFT_MARGIN + (YEAR_WIDTH * i), YEAR_TOP_Y + (YEAR_HEIGHT * 5));
		CGContextStrokePath(ctx);
	}
}

- (void) update_date_button{
	//タイトル
	title_label.text = [NSString stringWithFormat:@"%4d年", year_cur];
	
	//ボタンラベル
	int YEAR_no;
	for(int i=0; i<10; i++){
		YEAR_no = i + year_cur;
		UIButton* button = date_button_list[i];
		
		[button setTitle:[NSString stringWithFormat:@"%d年", YEAR_no] forState:UIControlStateNormal];
		button.tag = YEAR_no;
	}
}

- (IBAction) tap_next:(id)sender{
	year_cur += 10;
		
	[self update_date_button];
}

- (IBAction) tap_prev:(id)sender{
	year_cur -= 10;
		
	[self update_date_button];
}

- (IBAction) tap_date:(UIButton*)sender{
	if(date_select_delegate != nil){
		[date_select_delegate date_selected:0 year:sender.tag month:-1 day:-1];
	}
}

@end
