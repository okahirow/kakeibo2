//
//  GraphView_Circle.m
//  PSPTimer
//
//  Created by hiro on 11/02/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphView_Circle.h"
#import "MyColor.h"
#import "MyCircleData.h"

@implementation GraphView_Circle

@synthesize cat_data_list;

#define CENTER_X 160.0
#define CENTER_Y 100.0
#define CIRCLE_R 55.0

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
	self.cat_data_list = nil;
}

//描画データを設定
- (void)set_draw_data:(NSArray*)cat_rate_list_ cat_color_list:(NSArray*)cat_color_list_{
	NSMutableArray* tmp_list = [[NSMutableArray alloc] init];
	
	for(int i=0; i<[cat_rate_list_ count]; i++){		
		NSNumber* tmp_cat_rate = cat_rate_list_[i];
		if(tmp_cat_rate == (NSNumber*)[NSNull null]) continue;	
		
		MyCircleData* data = [[MyCircleData alloc] init];
		data.color_ = cat_color_list_[i];
		data.rate_ = [tmp_cat_rate floatValue];
		
		[tmp_list addObject:data];
	}

	//rateの降順に並び替える
    NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"rate_" ascending:NO];  
    NSArray* sortDescArray = @[sort];  
	
    self.cat_data_list = [tmp_list sortedArrayUsingDescriptors:sortDescArray];  
}

// 画面描画
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	[self drawBase:ctx];
	[self drawCircle:ctx];
}


//背景の描画
- (void)drawBase:(CGContextRef)ctx{	
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
}

//円弧の描画
- (void) draw_1_cat:(CGContextRef)ctx color:(MyColor*)color start_angle:(float)start_angle end_angle:(float)end_angle{
	CGContextMoveToPoint(ctx, CENTER_X, CENTER_Y);
	CGContextAddArc(ctx, CENTER_X, CENTER_Y, CIRCLE_R, start_angle, end_angle, 0);
	CGContextClosePath(ctx);

	// 色を決める
	CGContextSetRGBFillColor(ctx, color.r, color.g, color.b, 1.0f);
	CGContextSetRGBStrokeColor(ctx, color.r, color.g, color.b, 1.0f);
	
	//線の太さ
	CGContextSetLineWidth(ctx, 1.0f);
	
	CGContextFillPath(ctx);	
}

//円の描画
- (void)drawCircle:(CGContextRef)ctx{
	if(self.cat_data_list == nil) return;
	
	//ベースの円を書く
	//円の範囲  
	CGRect rectEllipse = CGRectMake(CENTER_X - CIRCLE_R, CENTER_Y - CIRCLE_R, CIRCLE_R*2, CIRCLE_R*2);

	//円の中身を描画  
	CGContextSetRGBFillColor(ctx, 0.5f, 0.5f, 0.5f, 1.0f);
	CGContextFillEllipseInRect(ctx, rectEllipse);  
		
	//カテゴリごとの円弧を描く
	float start_angle = -M_PI_2;
	for(int i=0; i<[self.cat_data_list count]; i++){		
		MyCircleData* data = (self.cat_data_list)[i];
		
		float cat_rate = data.rate_;
		float end_angle = start_angle + (2.0 * M_PI * cat_rate);
		
		//カテゴリーの円弧を描画
		[self draw_1_cat:ctx color:data.color_ start_angle:start_angle end_angle:end_angle];
		
		start_angle = end_angle;
	}
	
	//円の線を描画
	CGContextSetLineWidth(ctx, 1.0f);
	CGContextSetRGBStrokeColor(ctx, 0.0f, 0.0f, 0.0f, 1.0f);
	CGContextStrokeEllipseInRect(ctx, rectEllipse); 
}



@end
