//
//  MyColor.h
//  PSPTimer
//
//  Created by hiro on 11/02/22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyColor : NSObject<NSCopying>

@property (assign) float r;
@property (assign) float g;
@property (assign) float b;
@property (assign) float a;

-(id)initWithR:(float)R G:(float)G B:(float)B A:(float)A;
-(id)initWithColorNo:(int)index;
-(UIColor*)ui_color;

@end
