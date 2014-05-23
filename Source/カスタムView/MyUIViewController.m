    //
//  MyUIViewController.m
//  PSPTimer
//
//  Created by hiro on 10/11/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyUIViewController.h"


@implementation MyUIViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
	[self.view addSubview:tableView];
	[self.view sendSubviewToBack:tableView];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

//スワイプ右を検知
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	touch_begin_ = [[touches anyObject] locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	CGPoint point = [[touches anyObject] locationInView:self.view];
	
	NSInteger distance_horizontal = point.x - touch_begin_.x;
	NSInteger distance_vertical = point.y - touch_begin_.y;
	
	//右にスワイプした場合
	if(abs(distance_horizontal) > abs(distance_vertical) && distance_horizontal >= 50){
		//前の画面に戻る
		//[self.navigationController popViewControllerAnimated:YES];
	}
	
	[super touchesMoved:touches withEvent:event];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
