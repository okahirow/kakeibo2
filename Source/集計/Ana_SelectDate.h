//
//  Ana_SelectDate.h
//  kakeibo
//
//  Created by hiro on 12/06/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalenderDay_View.h"
#import "CalenderMonth_View.h"
#import "CalenderYear_View.h"
#import "MyUIViewController.h"

@interface Ana_SelectDate : MyUIViewController <Calender_protocol>{
	IBOutlet UISegmentedControl* segment;
	IBOutlet CalenderDay_View* calender_day;
	IBOutlet CalenderMonth_View* calender_month;
	IBOutlet CalenderYear_View* calender_year;
	
	int unit;
	NSDate* cur_date;
}

@property (copy) NSDate* cur_date;

- (id) init:(int)unit_ year:(int)year_ month:(int)month_ day:(int)day_;
- (IBAction) segment_changed:(UISegmentedControl*)sender;


@end
