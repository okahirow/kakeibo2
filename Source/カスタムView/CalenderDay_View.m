//
//  CalenderDay_View.m
//  kakeibo
//
//  Created by hiro on 12/06/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CalenderDay_View.h"

#define WEEK_TOP_Y 60
#define LEFT_MARGIN 20
#define DAY_HEIGHT 40
#define DAY_WIDTH 40

@implementation CalenderDay_View

- (void) set_info:(NSDate*)start_date_ delegate:(id)delegate_{
	date_select_delegate = delegate_;
	
	NSDateComponents* components = [[NSCalendar currentCalendar] components: NSYearCalendarUnit | NSMonthCalendarUnit fromDate:start_date_];
	year_cur = [components year];
	month_cur = [components month];
	
	UIImage* img_normal = [UIImage imageNamed:@"calender_button_normal.png"];
	UIImage* img_pressed = [UIImage imageNamed:@"calender_button_pressed.png"];
	
	date_button_list = [[NSMutableArray alloc] init];
	for(int i=0; i<5; i++){
		for(int j=0; j<7; j++){
			UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
			[button setBackgroundImage:img_normal forState:UIControlStateNormal];
			[button setBackgroundImage:img_pressed forState:UIControlStateHighlighted];
			
			if(j == 0){
				[button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
			}
			else if(j == 6){
				[button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
			}
			else{
				[button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
			}
			[button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
			button.frame = CGRectMake(LEFT_MARGIN + 1 + DAY_WIDTH * j, 1 + WEEK_TOP_Y + DAY_HEIGHT + (DAY_HEIGHT * i), DAY_WIDTH - 2, DAY_HEIGHT - 2);
			[button addTarget:self action:@selector(tap_date:) forControlEvents:UIControlEventTouchUpInside];
			[top_view addSubview:button];
			
			[date_button_list addObject:button];
		}
	}
	
	[self update_date_button];
}

- (void)awakeFromNib {
    [[NSBundle mainBundle] loadNibNamed:@"CalenderDay_View" owner:self options:nil];
    [self addSubview:top_view];
	
	date_select_delegate = nil;
	year_cur = 0;
	month_cur = 0;
	date_button_list = nil;
}


- (void)drawRect:(CGRect)rect{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	[self draw_base:ctx];
	[self draw_line:ctx];
}

- (void) draw_base:(CGContextRef)ctx{
	CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 0.0);
	CGContextFillRect(ctx, CGRectMake(0,0,320,315));
	
	return;
	
	CGGradientRef gradient;
    CGColorSpaceRef colorSpace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 1.0,  // Start color
		0.82, 0.82, 0.82, 1.0 }; // End color
    colorSpace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
	
    CGPoint startPoint = CGPointMake(self.frame.size.width/2, 0.0);
    CGPoint endPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height);
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
}

- (void) draw_line:(CGContextRef)ctx{
	//線
	CGContextSetLineWidth(ctx, 1);
	CGContextSetRGBStrokeColor(ctx, 0.4, 0.4, 0.4, 1);
	
	//横線
	for(int i=0; i<7; i++){
		CGContextMoveToPoint(ctx, LEFT_MARGIN, WEEK_TOP_Y + (DAY_HEIGHT * i));
		CGContextAddLineToPoint(ctx, LEFT_MARGIN + (DAY_WIDTH * 7), WEEK_TOP_Y + (DAY_HEIGHT * i));
		CGContextStrokePath(ctx);
	}
	
	//縦線
	for(int i=0; i<8; i++){
		CGContextMoveToPoint(ctx, LEFT_MARGIN + (DAY_WIDTH * i), WEEK_TOP_Y);
		CGContextAddLineToPoint(ctx, LEFT_MARGIN + (DAY_WIDTH * i), WEEK_TOP_Y + (DAY_HEIGHT * 6));
		CGContextStrokePath(ctx);
	}
}

- (void) update_date_button{
	//タイトル
	title_label.text = [NSString stringWithFormat:@"%4d年%02d月", year_cur, month_cur];
	
	//月の初日と最終日の取得
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:year_cur];
	[comps setMonth:month_cur];
	[comps setDay:1];
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDate *date = [cal dateFromComponents:comps];
	NSRange range = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
	int last_day = range.length;
	
    NSDateComponents* comps2 = [cal components:NSWeekdayCalendarUnit fromDate:date];
	int start_week = [comps2 weekday];	//1:日曜
	
	//ボタンラベル
	int day_no;
	for(int i=0; i<7*5; i++){
		UIButton* button = date_button_list[i];
		
		day_no = i - start_week + 2;
		
		//有効な日の場合
		if(1 <= day_no && day_no <= last_day){
			[button setHidden:false];
			[button setTitle:[NSString stringWithFormat:@"%d", day_no] forState:UIControlStateNormal];
			button.tag = day_no;
		}
		else{
			[button setHidden:true];
		}
	}
}

- (IBAction) tap_next:(id)sender{
	month_cur ++;
	if(month_cur > 12){
		month_cur = 1;
		year_cur ++;
	}
	
	[self update_date_button];
}

- (IBAction) tap_prev:(id)sender{
	month_cur --;
	if(month_cur < 1){
		month_cur = 12;
		year_cur --;
	}
	
	[self update_date_button];
}

- (IBAction) tap_date:(UIButton*)sender{
	if(date_select_delegate != nil){
		[date_select_delegate date_selected:2 year:year_cur month:month_cur day:sender.tag];
	}
}


@end
