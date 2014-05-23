//
//  MyUITableViewController.m
//  PSPTimer
//
//  Created by hiro on 10/11/25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyUITableViewController.h"
#import "MyUITableView.h"


@implementation MyUITableViewController


#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
		style_ = style;
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	//独自TableViewを使用
	MyUITableView* table_view = [[MyUITableView alloc] initWithFrame:self.tableView.frame style:UITableViewStyleGrouped];
	table_view.controller_ = self;
	//NSLog(@"MyUITableViewController viewDidLoad self %d Count %d", self, [self retainCount]);
	self.tableView = table_view;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[super viewDidLoad];
	
	self.tableView = nil;
}


- (void)dealloc {
	self.tableView = nil;
	
}


@end

