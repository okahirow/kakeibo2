//
//  GraphVLabelView.m
//  PSPTimer
//
//  Created by hiro on 11/02/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphVLabelView.h"
#import "CommonAPI.h"


@implementation GraphVLabelView

#define FONT_SIZE 10
#define TOP_SPACE 45
#define VER_POINT_SPAN_PIX 19
#define V_POINT_NUM 5
#define LEFT_SPACE 1

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

//初期化
- (void)awakeFromNib{
	v_unit_ = 500;
	
	//[self setBackgroundColor:[[UIColor alloc] initWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
}


//目盛りの間隔を設定
- (void) set_v_unit:(int)val{
	v_unit_ = val;
}


// 画面描画
- (void)drawRect:(CGRect)rect {	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
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
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	
	//垂直目盛り
	for(int i=0; i<=V_POINT_NUM; i++){
		//文字列の描画
		NSString* string;
		
		string = [NSString stringWithFormat:@"%@", [CommonAPI money_str_no_unit:i * v_unit_]];
		
		/*
		if(v_unit_ < 5000){
			if(i == V_POINT_NUM) string = [NSString stringWithFormat:@"%@%d", [settings stringForKey:@"MONEY_UNIT"], i * v_unit_];
			else string = [NSString stringWithFormat:@"%d", i * v_unit_];
		}
		else{
			if(i == V_POINT_NUM) string = [NSString stringWithFormat:@"%@%.1f", [settings stringForKey:@"MONEY_UNIT"], i * v_unit_ / 10000.0f];
			else string = [NSString stringWithFormat:@"%.1f", i * v_unit_ / 10000.0f];
		}
		 */
		
		[[UIColor blackColor] set];
		UIFont* font = [UIFont systemFontOfSize:FONT_SIZE];
		[string drawAtPoint:CGPointMake(LEFT_SPACE, TOP_SPACE + VER_POINT_SPAN_PIX * (V_POINT_NUM - i) - FONT_SIZE / 2) withFont:font];
	}	
}




@end
