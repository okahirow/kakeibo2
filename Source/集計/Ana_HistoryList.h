//
//  Ana_HistoryList.h
//  kakeibo
//
//  Created by hiro on 11/04/13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUITableViewController.h"


@interface Ana_HistoryList : MyUITableViewController {
	NSString* category_;
	NSArray* history_list_;
}

@property (copy) NSString* category_;
@property (copy) NSArray* history_list_;

- (id) init:(NSString*)category history_list:(NSArray*)history_list;

@end
