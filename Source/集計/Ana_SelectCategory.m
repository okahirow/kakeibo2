//
//  Ana_SelectCategory.m
//  PSPTimer
//
//  Created by hiro on 11/04/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Ana_SelectCategory.h"
#import "MyModel.h"
#import "Ana_EditHistory.h"
#import "Ana_InputCategory.h"


@implementation Ana_SelectCategory
@synthesize category_list_;


#pragma mark -
#pragma mark Initialization



- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}



#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.title = NSLocalizedString(@"STR-021", nil);
	
	self.category_list_ = [g_model_ get_show_category_list];
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
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

//セルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	
	if(indexPath.row == 0){
		
	}
	else{
		DBCategory* category = category_list_[indexPath.row - 1];
		
		//セパレーターの場合
		if([category is_separator] == true){
			return 35;
		}
	}
	
	if([settings boolForKey:@"IS_NARROW_CELL"] == true){
		return 35;
	}
	else{
		return 44;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.category_list_ count] + 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.row == 0){
		cell.textLabel.text = NSLocalizedString(@"STR-022", nil);
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.textColor = [UIColor blackColor];
	}
	else{
		DBCategory* cat = (self.category_list_)[indexPath.row - 1];
		
		//セパレーターの場合
		if([cat is_separator] == true){
			cell.textLabel.text = cat.cur.name;
			cell.textLabel.textColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else{
			cell.textLabel.text = cat.cur.name;
			cell.textLabel.textColor = [UIColor blackColor];
		}
		
		cell.textLabel.minimumScaleFactor = 10.0;
		cell.textLabel.adjustsFontSizeToFitWidth = TRUE;
		cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
		
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.row == 0){
		cell.backgroundColor = [UIColor whiteColor];
	}
	else{
		DBCategory* category = category_list_[indexPath.row - 1];
		
		if([category is_separator] == true){
			cell.backgroundColor = [[UIColor alloc] initWithRed:60.0f/255.0f green:140.0f/255.0f blue:1.00f alpha:1.0f];
		}
		else{
			cell.backgroundColor = [UIColor whiteColor];
		}	
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

//項目が選択された場合
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //手動入力
	if(indexPath.row == 0){
		UIViewController* next_view = [[Ana_InputCategory alloc] init];
		[self.navigationController pushViewController:next_view animated:YES];
	}
	//それ以外
	else{
		DBCategory* cat = (self.category_list_)[indexPath.row - 1];
		
		//セパレーター
		if([cat is_separator] == true){
			return;
		}
		
		NSArray *allControllers = self.navigationController.viewControllers;
		Ana_EditHistory* parent = (Ana_EditHistory*)allControllers[[allControllers count] - 2];
		
		NSString* new_name = cat.cur.name;
		[parent set_category_name:new_name];
		
		[self.navigationController popViewControllerAnimated:YES];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}




@end

