//
//  MyDBCategory.h
//  kakeibo
//
//  Created by hiro on 11/04/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyDBCategory : NSObject

@property (assign) NSInteger id_;
@property (copy) NSString* name_;
@property (assign) NSInteger index_;

- (NSComparisonResult)compare:(MyDBCategory*)data;

@end