//
//  MyDBCustomAna.h
//  kakeibo
//
//  Created by hiro on 11/04/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyDBCustomAna : NSObject

@property (assign) NSInteger id_;
@property (copy) NSString* name_;
@property (copy) NSString* formula_;
@property (copy) NSString* unit_;
@property (assign) NSInteger index_;
@property (assign) BOOL is_show_;

- (NSComparisonResult)compare:(MyDBCustomAna*)data;

@end
