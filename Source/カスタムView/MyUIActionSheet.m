//
//  MyUIActionSheet.m
//  kakeibo
//
//  Created by hiro on 12/06/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyUIActionSheet.h"

@implementation MyUIActionSheet

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
		
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) applicationDidEnterBackground:(NSNotification*) notification {
    // We should not be here when entering back to foreground state
    [self dismissWithClickedButtonIndex:[self cancelButtonIndex] animated:NO];
}

@end
