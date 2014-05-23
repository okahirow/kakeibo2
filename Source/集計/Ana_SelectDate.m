//
//  Ana_SelectDate.m
//  kakeibo
//
//  Created by hiro on 12/06/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Ana_SelectDate.h"
#import "Ana_Top.h"

@interface Ana_SelectDate ()

@end

@implementation Ana_SelectDate
@synthesize cur_date;

- (id) init:(int)unit_ year:(int)year_ month:(int)month_ day:(int)day_{
	self = [super init];
    if (self) {
        unit = unit_;
		
		NSDateComponents *comps = [[NSDateComponents alloc] init];
		[comps setYear:year_];
		[comps setMonth:month_];
		[comps setDay:day_];
		NSCalendar *cal = [NSCalendar currentCalendar];
		self.cur_date = [cal dateFromComponents:comps];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.title = @"集計期間の変更";
	segment.selectedSegmentIndex = unit;
	
	[self segment_changed:segment];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) date_selected:(int)unit_ year:(int)year_ month:(int)month_ day:(int)day_{
	NSArray *allControllers = self.navigationController.viewControllers;
	Ana_Top* top = (Ana_Top*)allControllers[0];
	[top date_selected:unit_ year:year_ month:month_ day:day_];
	[top get_ana_data];
	[top update_show_view];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) segment_changed:(UISegmentedControl*)sender{
	if(sender.selectedSegmentIndex == 0){
		[calender_year setHidden:false];
		[calender_month setHidden:true];
		[calender_day setHidden:true];
		[calender_year set_info:self.cur_date delegate:self];
	}
	else if(sender.selectedSegmentIndex == 1){
		[calender_year setHidden:true];
		[calender_month setHidden:false];
		[calender_day setHidden:true];
		[calender_month set_info:self.cur_date delegate:self];
	}
	else{
		[calender_year setHidden:true];
		[calender_month setHidden:true];
		[calender_day setHidden:false];
		[calender_day set_info:self.cur_date delegate:self];
	}
}


@end
