//
//  Settings_CustomAna_SelCategory.m
//  PSPTimer
//
//  Created by hiro on 11/04/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Settings_CustomAna_SelCategory.h"
#import "MyModel.h"
#import "Settings_CustomAna_Add.h"


@implementation Settings_CustomAna_SelCategory
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

	self.navigationItem.title = NSLocalizedString(@"STR-009", nil);
	
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if(section == 0){
		return 1;
	}
	else{
		return [self.category_list_ count];
	}
}


//セルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	
	if(indexPath.section == 0){
		return 44;
	}
	else{
		DBCategory* cat = (self.category_list_)[indexPath.row];
		
		//セパレーターの場合
		if([cat is_separator] == true){
			return 35;
		}
		else{
			if([settings boolForKey:@"IS_NARROW_CELL"] == true){
				return 35;
			}
			else{
				return 44;
			}
		}
	}
}

//セルの色
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section == 0){
		cell.backgroundColor = [UIColor whiteColor];
	}
	else{
		DBCategory* cat = (self.category_list_)[indexPath.row];
		
		//セパレーターの場合
		if([cat is_separator] == true){
			cell.backgroundColor = [[UIColor alloc] initWithRed:60.0f/255.0f green:140.0f/255.0f blue:1.00f alpha:1.0f];
		}
		else{
			cell.backgroundColor = [UIColor whiteColor];
		}
	}
}



//セパレーターセルを返す
- (UITableViewCell *)get_separator_cell:(UITableView *)tableView title:(NSString*)title{
	static NSString *CellIdentifier = @"AnaSeparatorCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
	cell.textLabel.text = title;
	cell.textLabel.textColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
	
	if(indexPath.section == 0){
		cell.textLabel.text = NSLocalizedString(@"STR-128", nil);
		cell.detailTextLabel.text = NSLocalizedString(@"STR-129", nil);
	}
	else{
		DBCategory* cat = (self.category_list_)[indexPath.row];
		
		//セパレーターの場合
		if([cat is_separator] == true){
			return [self get_separator_cell:tableView title:cat.cur.name];
		}
		else{
			cell.textLabel.text = cat.cur.name;
			
			cell.textLabel.minimumScaleFactor = 10.0;
			cell.textLabel.adjustsFontSizeToFitWidth = TRUE;
			cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
			
			cell.detailTextLabel.text = @"";
		}
	}
    
    return cell;
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
	NSArray *allControllers = self.navigationController.viewControllers;
	Settings_CustomAna_Add* parent = (Settings_CustomAna_Add*)allControllers[[allControllers count] - 2];
	
	if(indexPath.section == 0){
		[parent Settings_CustomAna_Add:NSLocalizedString(@"STR-128", nil)];
	}
	else{
		DBCategory* cat = (self.category_list_)[indexPath.row];
		
		if([cat is_separator] == true){
			return;
		}
		else{
			NSString* new_name = cat.cur.name;
			[parent Settings_CustomAna_Add:new_name];
		}
	}

	[self.navigationController popViewControllerAnimated:YES];
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

