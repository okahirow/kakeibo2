//
//  MyDBHistory.h
//  kakeibo
//
//  Created by hiro on 11/04/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyDBHistory : NSObject

@property (assign) NSInteger id_;
@property (assign) NSInteger year_;
@property (assign) NSInteger month_;
@property (assign) NSInteger day_;
@property (copy) NSString* category_;
@property (assign) NSInteger val_;
@property (copy) NSString* memo_;

- (NSComparisonResult)compare:(MyDBHistory*)data;

@end
