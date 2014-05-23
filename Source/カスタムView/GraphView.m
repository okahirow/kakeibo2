//
//  GraphView.m
//  PSPTimer
//
//  Created by hiro on 11/02/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "MyColor.h"


@implementation GraphView

@synthesize horizontal_point_label_, line_data_, line_color_, is_line_graph_;

#define HOL_POINT_SPAN_PIX 35
#define VER_POINT_SPAN_PIX 19
#define FONT_SIZE 12
#define MIN_FRAME_W 320
#define FRAME_H 160
#define V_POINT_NUM 5
#define POINT_R 3
#define RIGHT_SPACE 52
#define LEFT_SPACE 10
#define TOP_SPACE 47
#define PROT_SIZE 5
#define V_LINE_EDGE_SIZE 5
#define H_LINE_EDGE_SIZE 5
#define H_LABEL_OFFSET 4
#define V_LABEL_OFFSET -4
#define MIN_H_LINE_W (MIN_FRAME_W - RIGHT_SPACE - LEFT_SPACE + H_LINE_EDGE_SIZE)
#define MAX_BAR_NUM 5
#define BAR_SPACE 1.0f
#define BAR_DATE_SPACE 4.0f

- (id)initWithFrame:(CGRect)frame {   
    self = [super initWithFrame:frame];
    if (self) {		
		
    }
    return self;
}


//初期化
- (void)awakeFromNib{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	
	self.horizontal_point_label_ = nil;
	self.line_data_ = nil;
	self.line_color_ = nil;
	v_unit_ = 200;
	is_line_graph_ = [settings boolForKey:@"IS_GRAPH_LINE"];
	
	//[self setBackgroundColor:[[UIColor alloc] initWithRed:0.98f green:0.98f blue:0.98f alpha:1.0f]];
	//[self setBackgroundColor:[[UIColor alloc] initWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
}


//グラフの種類
- (void)set_is_line_graph:(BOOL)is_line{
	is_line_graph_ = is_line;
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	[settings setBool:is_line_graph_ forKey:@"IS_GRAPH_LINE"];
}


//水平目盛りのラベルセット
- (void)set_hol_point_labels:(NSArray*)hol_point_labels{
	self.horizontal_point_label_ = hol_point_labels;
	
	CGRect frame = [self frame];
	frame.size.width = LEFT_SPACE + H_LINE_EDGE_SIZE + [self.horizontal_point_label_ count] * HOL_POINT_SPAN_PIX + RIGHT_SPACE;
	if(frame.size.width < MIN_FRAME_W) frame.size.width = MIN_FRAME_W;
	frame.size.height = FRAME_H;
	[self setFrame:frame];
}


//描画データを設定
- (void)set_draw_data:(NSArray*)line_data line_color:(NSArray*)line_color{
	self.line_data_ = line_data;
	self.line_color_ = line_color;
	
	v_unit_ = [self get_vertical_unit];
}


// 画面描画
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	[self drawBase:ctx];
	if(is_line_graph_ == TRUE){
		[self drawLine:ctx];
	}
	else{
		[self drawBar:ctx];
	}
	
}


//データの最大値
- (float)get_max_val{
	int max = 1000;
	
	if(self.line_data_ == nil) return max;

	for(int i=0; i<[self.line_data_ count]; i++){
		NSArray* line = (self.line_data_)[i];
		if(line == (NSArray*)[NSNull null]) continue;
		
		for(int j=0; j<[line count]; j++){
			if([line[j] intValue] > max) max = [line[j] intValue];
		}
	}
	
	return max;
}


//垂直目盛りの値の間隔
- (float)get_vertical_unit{
	float max = [self get_max_val];
	
	if(max <=      1000)    return 200;
	else if(max <= 2500)    return 500;
	else if(max <= 5000)    return 1000;
	else if(max <= 10000)   return 2000;
	else if(max <= 25000)   return 5000;
	else if(max <= 50000)   return 10000;
	else if(max <= 100000)  return 20000;
	else if(max <= 250000)  return 50000;
	else if(max <= 500000)  return 100000;
	else if(max <= 1000000) return 200000;
	else                    return 500000;
}


//グラフ軸の描画
- (void)drawBase:(CGContextRef)ctx{
	int width = self.frame.size.width;
	
	//背景を塗る
	// CGGradientを生成する
    // 生成するためにCGColorSpaceと色データの配列が必要になるので
    // 適当に用意する
    CGGradientRef gradient;
    CGColorSpaceRef colorSpace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 1.0,  // Start color
		0.82, 0.82, 0.82, 1.0 }; // End color
    colorSpace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
	
    // 生成したCGGradientを描画する
    // 始点と終点を指定してやると、その間に直線的なグラデーションが描画される。
    // （横幅は無限大）
    CGPoint startPoint = CGPointMake(self.frame.size.width/2, 0.0);
    CGPoint endPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height);
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);

	
	// 線の色を決める
	//CGContextSetRGBStrokeColor(ctx, 0.0f, 0.0f, 0.0f, 1.0);
	CGContextSetRGBStrokeColor(ctx, 0.0f, 0.0f, 0.0f, 0.6f);	
	//線の太さ
	CGContextSetLineWidth(ctx, 1.0f);
	
	// 縦横線
	float h_line_w = [self.horizontal_point_label_ count] * HOL_POINT_SPAN_PIX + H_LINE_EDGE_SIZE;
	if(h_line_w < MIN_H_LINE_W) h_line_w = MIN_H_LINE_W;
	
	CGContextMoveToPoint(ctx, width - RIGHT_SPACE, TOP_SPACE - V_LINE_EDGE_SIZE); // 始点を指定
	CGContextAddLineToPoint(ctx, width - RIGHT_SPACE, TOP_SPACE + VER_POINT_SPAN_PIX * V_POINT_NUM);  // 始点から直線が到達する点を指定する
	CGContextAddLineToPoint(ctx, width - RIGHT_SPACE - h_line_w, TOP_SPACE + VER_POINT_SPAN_PIX * V_POINT_NUM);  // 上記の点から次の点へ結ぶ直線を指定する
	CGContextStrokePath(ctx); // 始点から最後の点までの線を引く
	
	
	//水平目盛り	
	for(int i=0; i<[self.horizontal_point_label_ count]; i++){
		//線の太さ
		CGContextSetLineWidth(ctx, 1.0f);
		// 線の色を決める
		CGContextSetRGBStrokeColor(ctx, 0.0f, 0.0f, 0.0f, 0.6f);
		
		CGContextMoveToPoint(ctx, width - RIGHT_SPACE - ([horizontal_point_label_ count] - i) * HOL_POINT_SPAN_PIX, TOP_SPACE + VER_POINT_SPAN_PIX * V_POINT_NUM); // 始点を指定
		CGContextAddLineToPoint(ctx, width - RIGHT_SPACE - ([horizontal_point_label_ count] - i) * HOL_POINT_SPAN_PIX, TOP_SPACE + VER_POINT_SPAN_PIX * V_POINT_NUM + PROT_SIZE);  // 始点から直線が到達する点を指定する
		CGContextStrokePath(ctx); // 始点から最後の点までの線を引く
		
		//文字列の描画		
		[[UIColor blackColor] set];
		//[[UIColor whiteColor] set];
		UIFont* font = [UIFont systemFontOfSize:FONT_SIZE];
		NSString* label = horizontal_point_label_[i];
		float label_offset_x = ((5.0f - [label length]) * FONT_SIZE / 2.0f) / 2.0f;
				
		[label drawAtPoint:CGPointMake(width - RIGHT_SPACE - ([horizontal_point_label_ count] - i) * HOL_POINT_SPAN_PIX + H_LABEL_OFFSET + label_offset_x, TOP_SPACE + VER_POINT_SPAN_PIX * V_POINT_NUM + PROT_SIZE + V_LABEL_OFFSET) withFont:font];
	}
	
	//垂直目盛り
	for(int i=0; i<=V_POINT_NUM; i++){
		//線の太さ
		CGContextSetLineWidth(ctx, 1.0f);
		// 線の色を決める
		CGContextSetRGBStrokeColor(ctx, 0.0f, 0.0f, 0.0f, 0.6f);

		//CGContextMoveToPoint(ctx, width - RIGHT_SPACE, TOP_SPACE + VER_POINT_SPAN_PIX * (V_POINT_NUM - i)); // 始点を指定
		CGContextMoveToPoint(ctx, width - RIGHT_SPACE - h_line_w, TOP_SPACE + VER_POINT_SPAN_PIX * (V_POINT_NUM - i)); // 始点を指定
		CGContextAddLineToPoint(ctx, width - RIGHT_SPACE + PROT_SIZE, TOP_SPACE + VER_POINT_SPAN_PIX * (V_POINT_NUM - i));  // 始点から直線が到達する点を指定する
		CGContextStrokePath(ctx); // 始点から最後の点までの線を引く
	}
	
	//垂直目盛り値
	[vlabel_view_ set_v_unit:v_unit_];
	[vlabel_view_ setNeedsDisplay];
}


//ラインのプロット位置
- (CGPoint)get_graph_point:(int)index val:(float)val{
	int width = self.frame.size.width;
	
	float x = width - RIGHT_SPACE - ([horizontal_point_label_ count] - index) * HOL_POINT_SPAN_PIX;
	
	if(val < 0){
		val = 0;
	}
	
	float y = TOP_SPACE + VER_POINT_SPAN_PIX * V_POINT_NUM - (val * VER_POINT_SPAN_PIX / v_unit_);
	if(val == 0){
		y = y - 2;
	}
	
	return CGPointMake(x, y);
}


//ラインの描画
- (void)drawLine:(CGContextRef)ctx{
	if(self.line_data_ == nil) return;
	
	for(int i=0; i<[self.line_data_ count]; i++){		
		NSArray* line = (self.line_data_)[i];
		if(line == (NSArray*)[NSNull null]) continue;		
		
		MyColor* color = (self.line_color_)[i];
		
		// 色を決める
		CGContextSetRGBFillColor(ctx, color.r, color.g, color.b, 0.8f);
		CGContextSetRGBStrokeColor(ctx, color.r, color.g, color.b, 0.8f);
		
		//線の太さ
		CGContextSetLineWidth(ctx, 3.0f);
		
		if([line count] == 0){
			continue;
		}
		else if([line count] == 1){
			//点を描画
			CGPoint point = [self get_graph_point:0 val:[line[0] floatValue]];
			CGContextFillEllipseInRect(ctx, CGRectMake(point.x - POINT_R + HOL_POINT_SPAN_PIX / 2, point.y - POINT_R, POINT_R * 2, POINT_R * 2));  // 円を塗りつぶす			
		}
		else{
			//線を描画
			CGPoint point = [self get_graph_point:0 val:[line[0] floatValue]];
			CGContextMoveToPoint(ctx, point.x + HOL_POINT_SPAN_PIX / 2, point.y);

			for(int j=1; j<[line count]; j++){
				point = [self get_graph_point:j val:[line[j] floatValue]];
				CGContextAddLineToPoint(ctx, point.x + HOL_POINT_SPAN_PIX / 2, point.y);
			}
			
			CGContextStrokePath(ctx);
		}
	}
}

//棒グラフの描画
- (void)drawBar:(CGContextRef)ctx{
	if(self.line_data_ == nil) return;
	
	int bar_num = 0;
	for(int i=0; i<[self.line_data_ count]; i++){		
		NSArray* line = (self.line_data_)[i];
		if(line != (NSArray*)[NSNull null]){
			bar_num ++;
		}
	}
		
	float bar_width = (HOL_POINT_SPAN_PIX - BAR_DATE_SPACE - BAR_SPACE * (bar_num - 1)) / bar_num;
	float bar_span = bar_width + BAR_SPACE;
	
	int bar_index = 0;
	for(int i=0; i<[self.line_data_ count]; i++){		
		NSArray* line = (self.line_data_)[i];
		if(line == (NSArray*)[NSNull null]) continue;
		
		MyColor* color = (self.line_color_)[i];
		
		// 色を決める
		CGContextSetRGBFillColor(ctx, color.r, color.g, color.b, 0.9f);
		CGContextSetRGBStrokeColor(ctx, color.r, color.g, color.b, 0.9f);
		
		//線の太さ
		CGContextSetLineWidth(ctx, bar_width);
		
		if([line count] == 0){
			continue;
		}
		else{
			//棒を描画
			for(int j=0; j<[line count]; j++){
				CGPoint point = [self get_graph_point:j val:[line[j] floatValue]];
				CGContextMoveToPoint(ctx, point.x + BAR_DATE_SPACE / 2 + bar_span * bar_index + bar_width / 2, point.y);
				
				CGContextAddLineToPoint(ctx, point.x + BAR_DATE_SPACE / 2 + bar_span * bar_index + bar_width / 2, TOP_SPACE + VER_POINT_SPAN_PIX * V_POINT_NUM - 0.5f);
			}
			
			CGContextStrokePath(ctx);
		}
		
		bar_index ++;
	}
}




@end
