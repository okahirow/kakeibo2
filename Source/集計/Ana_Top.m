//
//  Ana_Top.m
//  kakeibo
//
//  Created by hiro on 11/04/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Ana_Top.h"
#import "MyModel.h"
#import "LoadingCell.h"
#import "MyHistoryCell.h"
#import "DBHistory.h"
#import "MyAnaCategory.h"
#import "Ana_HistoryList.h"
#import "Ana_EditHistory.h"
#import "MyAnaGraphCell.h"
#import "MyColor.h"
#import "MyAnaCell.h"
#import "CommonAPI.h"
#import "MyAnaCell_multi.h"
#import "MyAnaGraphCircleCell.h"
#import "MyUIActionSheet.h"
#import "Ana_SelectDate.h"


@implementation Ana_Top
@synthesize sel_segment_, year_cur_, month_cur_, day_cur_, history_list_, ana_category_list_, custom_ana_list_;
@synthesize is_graph_on_, color_list_, cat_color_list_, graph_type_button_, img_graph_line_, img_graph_bar_, period_button_;


//タイトルを更新
- (void) update_title{
	NSString* title;
	NSString* next;
	NSString* prev;
	
	//年
	if(cur_period_ == 0){
		title = [NSString stringWithFormat:@"%d%@", self.year_cur_, NSLocalizedString(@"STR-048", nil)];
		next = [NSString stringWithFormat:@"%d%@", self.year_cur_ + 1, NSLocalizedString(@"STR-048", nil)];
		prev = [NSString stringWithFormat:@"%d%@", self.year_cur_ - 1, NSLocalizedString(@"STR-048", nil)];
	}
	//月
	else if(cur_period_ == 1){
		title = [NSString stringWithFormat:@"%d%@%d%@", self.year_cur_, NSLocalizedString(@"STR-048", nil), self.month_cur_, NSLocalizedString(@"STR-049", nil)];
		
		int next_month;
		int prev_month;
		
		if(self.month_cur_ == 1){
			next_month = 2;
			prev_month = 12;
		}
		else if (self.month_cur_ == 12) {
			next_month = 1;
			prev_month = 11;
		}
		else{
			next_month = self.month_cur_ + 1;
			prev_month = self.month_cur_ - 1;
		}
		
		prev = [NSString stringWithFormat:@"%d%@", prev_month, NSLocalizedString(@"STR-049", nil)];
		next = [NSString stringWithFormat:@"%d%@", next_month, NSLocalizedString(@"STR-049", nil)];
	}
	//日
	else{
		title = [NSString stringWithFormat:@"%d%@%d%@%d%@", self.year_cur_, NSLocalizedString(@"STR-048", nil), self.month_cur_, NSLocalizedString(@"STR-049", nil), self.day_cur_, NSLocalizedString(@"STR-124", nil)];
		
		int next_day;
		int next_month;
		int next_year;
		int prev_day;
		int prev_month;
		int prev_year;
		
		if(self.day_cur_ == 1){
			if(self.month_cur_ == 1){
				prev_year = self.year_cur_ - 1;
				prev_month = 12;
				prev_day = [self get_day_num_in_month:prev_year month:prev_month];
			}
			else{
				prev_year = self.year_cur_;
				prev_month = self.month_cur_ - 1;
				prev_day = [self get_day_num_in_month:prev_year month:prev_month];
			}
		}
		else{
			prev_day = self.day_cur_ - 1;
		}
		
		if(self.day_cur_ == [self get_day_num_in_month:self.year_cur_ month:self.month_cur_]){
			if(self.month_cur_ == 12){
				next_year = self.year_cur_ + 1;
				next_month = 1;
				next_day = 1;
			}
			else{
				next_year = self.year_cur_;
				next_month = self.month_cur_ + 1;
				next_day = 1;
			}
		}
		else{
			next_day = self.day_cur_ + 1;
		}
		
		prev = [NSString stringWithFormat:@"%d%@", prev_day, NSLocalizedString(@"STR-124", nil)];
		next = [NSString stringWithFormat:@"%d%@", next_day, NSLocalizedString(@"STR-124", nil)];
	}
	
	self.navigationItem.title = title;
	[self.period_button_ setTitle:title forState:UIControlStateNormal];
	self.period_button_.frame = CGRectMake(80, 0, 160, 30);
	
	self.navigationItem.leftBarButtonItem.title = prev;
	self.navigationItem.rightBarButtonItem.title = next;
}


- (void) reset_month{
	NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;	
	NSDateComponents *components = [cal components:unitFlags fromDate:[NSDate date]];
	
	self.year_cur_ = [components year];
	self.month_cur_ = [components month];
	self.day_cur_ = [components day];
	
	[self update_title];
}

-(void) show_custom_ana_list{
	if(self.custom_ana_list_ == nil){
		NSLog(@"custom_ana_list_ = nil");
	}
	else{
		NSLog(@"custom_ana_list_ count:%d", [self.custom_ana_list_ count]);
	}

}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	is_ana_multi_ = [settings boolForKey:@"IS_ANA_MULTI"];
	
	//アイコンの読み込み
	NSString* imagePath = [[NSBundle mainBundle] pathForResource:@"graph_bar" ofType:@"png"];
	if(self.img_graph_bar_ == nil){
		self.img_graph_bar_ = [[UIImage alloc] initWithContentsOfFile:imagePath];
	}
	imagePath = [[NSBundle mainBundle] pathForResource:@"graph_line" ofType:@"png"];
	if(self.img_graph_line_ == nil){
		self.img_graph_line_ = [[UIImage alloc] initWithContentsOfFile:imagePath];
	}
	
	//グラフタイプボタン
	self.graph_type_button_ = [UIButton buttonWithType:102];
	self.graph_type_button_.frame = CGRectMake(267, 10, 31, 30);
	[self.graph_type_button_ addTarget:self action:@selector(tap_graph_type_button) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.graph_type_button_];
	[self.graph_type_button_ setHidden:TRUE];
	
		
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStyleBordered 
																			 target:self 
																			 action:@selector(prev_month_button_tap)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@">" style:UIBarButtonItemStyleBordered 
																			 target:self 
																			 action:@selector(next_month_button_tap)];
	

	self.period_button_ = [UIButton buttonWithType:100];
	[self.period_button_.titleLabel setFont:[UIFont boldSystemFontOfSize:19.0f]];
	self.period_button_.frame = CGRectMake(80, 0, 160, 30);
	[self.period_button_ addTarget:self action:@selector(period_button_tap) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.titleView = period_button_;
	
	cur_period_ = [settings integerForKey:@"DEFAULT_PERIOD"];
	
	[self reset_month];
	
	self.sel_segment_ = 0;
	
	self.history_list_ = nil;
	self.ana_category_list_ = nil;
	self.custom_ana_list_ = nil;
	all_cat_total_ = 0;
	
	//[self get_ana_data];
	[self update_show_view];
}

- (void) reset_ana_data{
	self.history_list_ = nil;
	self.ana_category_list_ = nil;
	self.custom_ana_list_ = nil;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

//ビューが表示される直前
- (void)viewWillAppear:(BOOL)animated {
/*	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	if(cur_period_ != [settings integerForKey:@"DEFAULT_PERIOD"]){
		cur_period_ = [settings integerForKey:@"DEFAULT_PERIOD"];
		
		[self reset_month];
		[self update_title];
		[self get_ana_data];
		[self update_show_view];
		[table_view_ reloadData];
	}
	else{
		[table_view_ reloadData];
	}
*/	
//	[self get_ana_data];
//	[self update_show_view];
	[table_view_ reloadData];
	
    [super viewWillAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //集計
	if(sel_segment_ == 0){
		//読み込み中
		if(self.ana_category_list_ == nil || self.custom_ana_list_ == nil){
			return 1;			
		}
		//集計結果
		else{
			return 2;
		}		
	}
	//棒・円グラフ
	else if(sel_segment_ == 1 || sel_segment_ == 2){
		return 1;
	}
	//履歴一覧
    else{
		return 1;
	}
	
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//集計
	if(sel_segment_ == 0){
		//読み込み中
		if(self.ana_category_list_ == nil || self.custom_ana_list_ == nil){
			return 1;			
		}
		//集計結果
		else{
			//カスタム集計方法
			if(section == 0){
				return [self.custom_ana_list_ count];
			}
			//カテゴリーの集計
			else{
				return [self.ana_category_list_ count];
			}
		}
	}
	//棒・円グラフ
	else if(sel_segment_ == 1 || sel_segment_ == 2){
		//読み込み中
		if(self.ana_category_list_ == nil){
			return 1;			
		}
		//集計結果
		else{
			return [self.ana_category_list_ count];
		}
	}
	//履歴一覧
    else{
		//読み込み中
		if(self.history_list_ == nil){
			return 1;			
		}
		//集計結果
		else{
			return [self.history_list_ count];
		}
	}
}


//セルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	
	//集計結果
	if(sel_segment_ == 0){
		//読み込み中
		if(self.ana_category_list_ == nil || self.custom_ana_list_ == nil){
			return 44;			
		}
		//集計結果
		else{
			//カスタム集計方法
			if(indexPath.section == 0){
				DBCustomAna* ana = (self.custom_ana_list_)[indexPath.row];
				
				//セパレーターの場合
				if([ana is_separator] == true){
					return 35;
				}
				else{
					if([settings boolForKey:@"IS_NARROW_CELL"] == true && is_ana_multi_ == false){
						return 35;
					}
				}
			}
			//カテゴリーの集計
			else{
				MyAnaCategory* cat = (self.ana_category_list_)[indexPath.row];
				
				//セパレーターの場合
				if([cat is_separator] == true){
					return 35;
				}
				else{
					if([settings boolForKey:@"IS_NARROW_CELL"] == true && is_ana_multi_ == false){
						return 35;
					}
				}
			}
			
			return 44;
		}
	}
	//棒・円グラフ
	else if(sel_segment_ == 1 || sel_segment_ == 2){
		//読み込み中
		if(self.ana_category_list_ == nil){
			return 44;
		}
		//集計結果
		else{
			if([settings boolForKey:@"IS_NARROW_CELL"] == true){
				return 35;
			}
			else{
				//カテゴリーの集計
				MyAnaCategory* cat = (self.ana_category_list_)[indexPath.row];
				
				//セパレーターの場合
				if([cat is_separator] == true){
					return 35;
				}
				else{
					return 40;
				}
			}
		}
	}
	//履歴一覧
	else{
		return 60;
	}
}


//読み込み中セルを返す
- (UITableViewCell *)get_loading_cell:(UITableView *)tableView{
	static NSString *CellIdentifier = @"LoadingCell";
	
	LoadingCell *cell = (LoadingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		UIViewController *controller = [[UIViewController alloc] initWithNibName:@"LoadingCell" bundle:nil];
		cell = (LoadingCell *)controller.view;
		
		[cell add_indicator];
	}
	
	cell.title.text = NSLocalizedString(@"STR-050", nil);
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return cell;	
}


//履歴セルを返す
- (UITableViewCell *)get_history_cell:(UITableView *)tableView year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day category:(NSString*)category val:(NSInteger)val memo:(NSString*)memo{
	static NSString *CellIdentifier = @"HistoryCell";
	
	MyHistoryCell *cell = (MyHistoryCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		UIViewController *controller = [[UIViewController alloc] initWithNibName:@"MyHistoryCell" bundle:nil];
		cell = (MyHistoryCell *)controller.view;
	}
	
	cell.date_.text = [NSString stringWithFormat:@"%d/%02d/%02d", year, month, day];
	cell.category_.text = category;
	cell.val_.text = [CommonAPI money_str:val];
	cell.memo_.text = memo;
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	
	return cell;
}


//集計セルを返す
- (UITableViewCell *)get_category_cell:(UITableView *)tableView category:(NSString*)category total:(NSInteger)total{
	static NSString *CellIdentifier = @"AnaCategoryCell";
	
	MyAnaCell *cell = (MyAnaCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		UIViewController *controller = [[UIViewController alloc] initWithNibName:@"MyAnaCell" bundle:nil];
		cell = (MyAnaCell *)controller.view;
	}
	
	cell.title_.text = category;
	cell.total_.text = [CommonAPI money_str:total];
	cell.unit_.text = @"";
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	
	return cell;
}

//集計セル(積算)を返す
- (UITableViewCell *)get_category_cell_multi:(UITableView *)tableView category:(NSString*)category total:(NSInteger)total total_multi:(NSInteger)total_multi{
	static NSString *CellIdentifier = @"AnaCategoryCell_multi";
	
	MyAnaCell_multi *cell = (MyAnaCell_multi*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		UIViewController *controller = [[UIViewController alloc] initWithNibName:@"MyAnaCell_multi" bundle:nil];
		cell = (MyAnaCell_multi *)controller.view;
	}
	
	cell.title_.text = category;
	cell.total_.text = [CommonAPI money_str:total];
	cell.unit_.text = @"";
	
	cell.total_multi_.text = [CommonAPI money_str:total_multi];
	cell.unit_multi_.text = @"";
	
	//年
	if(cur_period_ == 0){
		cell.period_.text = NSLocalizedString(@"STR-174", nil);
	}
	//月
	else if(cur_period_ == 1){
		cell.period_.text = NSLocalizedString(@"STR-175", nil);
	}
	//日
	else{
		cell.period_.text = NSLocalizedString(@"STR-176", nil);
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	
	return cell;
}

//カスタム集計セルを返す
- (UITableViewCell *)get_custom_cell:(UITableView *)tableView custom:(DBCustomAna*)custom{
	static NSString *CellIdentifier = @"AnaCustomCell";
	
	MyAnaCell *cell = (MyAnaCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		UIViewController *controller = [[UIViewController alloc] initWithNibName:@"MyAnaCell" bundle:nil];
		cell = (MyAnaCell *)controller.view;
	}
	
	cell.title_.text = custom.cur.name;
	if(custom.is_total_error == FALSE){
		if([custom.cur.unit isEqualToString:@"￥"]){
			cell.total_.text = [CommonAPI money_str:custom.total];
			cell.unit_.text = @"";
		}
		else{
			cell.total_.text = [NSString stringWithFormat:@"%d", custom.total];
			cell.unit_.text = custom.cur.unit;
		}
	}
	else{
		cell.total_.text = NSLocalizedString(@"STR-051", nil);
		cell.unit_.text = @"";
	}	
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return cell;
}

//カスタム集計セル(積算)を返す
- (UITableViewCell *)get_custom_cell_multi:(UITableView *)tableView custom:(DBCustomAna*)custom{
	static NSString *CellIdentifier = @"AnaCustomCell_multi";
	
	MyAnaCell_multi *cell = (MyAnaCell_multi*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		UIViewController *controller = [[UIViewController alloc] initWithNibName:@"MyAnaCell_multi" bundle:nil];
		cell = (MyAnaCell_multi *)controller.view;
	}
		
	cell.title_.text = custom.cur.name;
	if(custom.is_total_error == FALSE){
		if([custom.cur.unit isEqualToString:@"￥"]){
			cell.total_.text = [CommonAPI money_str:custom.total];
			cell.unit_.text = @"";
			cell.total_multi_.text = [CommonAPI money_str:custom.total_multi];
			cell.unit_multi_.text = @"";
		}
		else{
			cell.total_.text = [NSString stringWithFormat:@"%d", custom.total];
			cell.unit_.text = custom.cur.unit;
			cell.total_multi_.text = [NSString stringWithFormat:@"%d", custom.total_multi];
			cell.unit_multi_.text = custom.cur.unit;
		}
	}
	else{
		cell.total_.text = NSLocalizedString(@"STR-051", nil);
		cell.unit_.text = @"";
		cell.total_multi_.text = NSLocalizedString(@"STR-051", nil);
		cell.unit_multi_.text = @"";
	}
	
	//年
	if(cur_period_ == 0){
		cell.period_.text = NSLocalizedString(@"STR-174", nil);
	}
	//月
	else if(cur_period_ == 1){
		cell.period_.text = NSLocalizedString(@"STR-175", nil);
	}
	//日
	else{
		cell.period_.text = NSLocalizedString(@"STR-176", nil);
	}
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return cell;
}


//棒グラフセルを返す
- (UITableViewCell *)get_graph_cell:(UITableView *)tableView category:(NSString*)category total:(NSInteger)total is_on:(Boolean)is_on index:(NSInteger)index{
	static NSString *CellIdentifier = @"MyAnaGraphCell";
	
	MyAnaGraphCell *cell = (MyAnaGraphCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		UIViewController *controller = [[UIViewController alloc] initWithNibName:@"MyAnaGraphCell" bundle:nil];
		cell = (MyAnaGraphCell *)controller.view;
	}
	
	cell.category_.text = category;
	cell.total_.text = [CommonAPI money_str:total];
	
	if(is_on == TRUE){
		for(int i=0; i<[self.cat_color_list_ count]; i++){
			if([(self.cat_color_list_)[i] intValue] == index){
				MyColor* color = (self.color_list_)[i];
				
				[cell.color_ setHidden:FALSE];
				cell.color_.textColor = [[UIColor alloc] initWithRed:color.r green:color.g blue:color.b alpha:color.a];
			}
		}
		
		cell.category_.textColor = [UIColor blackColor];
		cell.total_.textColor = [UIColor blackColor];
	}
	else{
		[cell.color_ setHidden:TRUE];
		
		cell.category_.textColor = [UIColor grayColor];
		cell.total_.textColor = [UIColor grayColor];
	}
/*	
	if(is_on == TRUE){
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
*/	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return cell;
}

//円グラフセルを返す
- (UITableViewCell *)get_graph_circle_cell:(UITableView *)tableView category:(NSString*)category total:(NSInteger)total rate:(float)rate is_on:(Boolean)is_on index:(NSInteger)index{
	static NSString *CellIdentifier = @"MyAnaGraphCircleCell";
	
	MyAnaGraphCircleCell *cell = (MyAnaGraphCircleCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		UIViewController *controller = [[UIViewController alloc] initWithNibName:@"MyAnaGraphCircleCell" bundle:nil];
		cell = (MyAnaGraphCircleCell *)controller.view;
	}
	
	cell.category_.text = category;
	cell.total_.text = [CommonAPI money_str:total];
	cell.rate_.text = [NSString stringWithFormat:@"%d%%", (int)(100*rate)];
	
	if(is_on == TRUE){
		for(int i=0; i<[self.cat_color_list_ count]; i++){
			if([(self.cat_color_list_)[i] intValue] == index){
				MyColor* color = (self.color_list_)[i];
				
				[cell.color_ setHidden:FALSE];
				cell.color_.textColor = [[UIColor alloc] initWithRed:color.r green:color.g blue:color.b alpha:color.a];
			}
		}
		
		cell.category_.textColor = [UIColor blackColor];
		cell.total_.textColor = [UIColor blackColor];
		cell.rate_.textColor = [UIColor blackColor];
	}
	else{
		[cell.color_ setHidden:TRUE];
		
		cell.category_.textColor = [UIColor grayColor];
		cell.total_.textColor = [UIColor grayColor];
		cell.rate_.textColor = [UIColor grayColor];
	}
	/*	
	 if(is_on == TRUE){
	 cell.accessoryType = UITableViewCellAccessoryCheckmark;
	 }
	 else{
	 cell.accessoryType = UITableViewCellAccessoryNone;
	 }
	 */	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return cell;
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


//セルの作成
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//集計結果
	if(sel_segment_ == 0){
		//単月
		if(is_ana_multi_ == false){
			//読み込み中
			if(self.ana_category_list_ == nil || self.custom_ana_list_ == nil){
				return [self get_loading_cell:tableView];		
			}
			//集計結果
			else{
				//カスタム集計方法
				if(indexPath.section == 0){
					DBCustomAna* custom = (self.custom_ana_list_)[indexPath.row];
					
					//セパレーターの場合
					if([custom is_separator] == true){
						return [self get_separator_cell:tableView title:custom.cur.name];
					}
					else{
						return [self get_custom_cell:tableView custom:custom];
					}					
				}
				else{
					//カテゴリーの集計
					MyAnaCategory* cat = (self.ana_category_list_)[indexPath.row];
					
					//セパレーターの場合
					if([cat is_separator] == true){
						return [self get_separator_cell:tableView title:cat.category_];
					}
					else{
						return [self get_category_cell:tableView category:cat.category_ total:cat.total_];
					}
				}
			}
		}
		//積算
		else{
			//読み込み中
			if(self.ana_category_list_ == nil || self.custom_ana_list_ == nil){
				return [self get_loading_cell:tableView];		
			}
			//集計結果
			else{
				//カスタム集計方法
				if(indexPath.section == 0){
					DBCustomAna* custom = (self.custom_ana_list_)[indexPath.row];
					
					//セパレーターの場合
					if([custom is_separator] == true){
						return [self get_separator_cell:tableView title:custom.cur.name];
					}
					else{
						return [self get_custom_cell_multi:tableView custom:custom];
					}
				}
				else{
					//カテゴリーの集計
					MyAnaCategory* cat = (self.ana_category_list_)[indexPath.row];
					
					//セパレーターの場合
					if([cat is_separator] == true){
						return [self get_separator_cell:tableView title:cat.category_];
					}
					else{
						return [self get_category_cell_multi:tableView category:cat.category_ total:cat.total_ total_multi:cat.total_multi_];
					}
				}
			}
		}
	}
	//棒グラフ
    else if(sel_segment_ == 1){
		//読込中
		if(self.ana_category_list_ == nil){
			return [self get_loading_cell:tableView];	
		}
		//集計結果
		else{
			MyAnaCategory* cat = (self.ana_category_list_)[indexPath.row];
			
			//セパレーターの場合
			if([cat is_separator] == true){
				return [self get_separator_cell:tableView title:cat.category_];
			}
			else{
				Boolean is_on = [(self.is_graph_on_)[indexPath.row] boolValue];
				return [self get_graph_cell:tableView category:cat.category_ total:cat.total_ is_on:is_on index:indexPath.row];	
			}
		}		
	}
	//円グラフ
    else if(sel_segment_ == 2){
		//読込中
		if(self.ana_category_list_ == nil){
			return [self get_loading_cell:tableView];	
		}
		//集計結果
		else{
			MyAnaCategory* cat = (self.ana_category_list_)[indexPath.row];
			
			//セパレーターの場合
			if([cat is_separator] == true){
				return [self get_separator_cell:tableView title:cat.category_];
			}
			else{
				Boolean is_on = [(self.is_graph_on_)[indexPath.row] boolValue];
				float rate = (float)cat.total_ / all_cat_total_;
				
				return [self get_graph_circle_cell:tableView category:cat.category_ total:cat.total_ rate:rate is_on:is_on index:indexPath.row];	
			}
		}		
	}
	//履歴一覧
    else{
		//NSLog(@"row:%d",indexPath.row);
		//読込中
		if(self.history_list_ == nil){
			return [self get_loading_cell:tableView];	
		}
		//集計結果
		else{
			DBHistory* his = (self.history_list_)[indexPath.row];
			return [self get_history_cell:tableView year:his.cur.year month:his.cur.month day:his.cur.day category:his.cur.category val:his.cur.val memo:his.cur.memo];		
		}		
	}
}


//セルの色
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	//集計結果
	if(sel_segment_ == 0){
		if(self.ana_category_list_ != nil && self.custom_ana_list_ != nil){
			if(indexPath.section == 0){
				DBCustomAna* ana = (self.custom_ana_list_)[indexPath.row];
				
				if([ana is_separator] == true){
					cell.backgroundColor = [[UIColor alloc] initWithRed:60.0f/255.0f green:140.0f/255.0f blue:1.00f alpha:1.0f];
					return;
				}
			}
			else if(indexPath.section == 1){
				MyAnaCategory* cat = (self.ana_category_list_)[indexPath.row];
				
				if([cat is_separator] == true){
					cell.backgroundColor = [[UIColor alloc] initWithRed:60.0f/255.0f green:140.0f/255.0f blue:1.00f alpha:1.0f];
					return;
				}
			}
		}
	}
	//棒・円グラフ
	else if(sel_segment_ == 1 || sel_segment_ == 2){
		if(self.ana_category_list_ != nil){
			MyAnaCategory* cat = (self.ana_category_list_)[indexPath.row];
			
			if([cat is_separator] == true){
				cell.backgroundColor = [[UIColor alloc] initWithRed:60.0f/255.0f green:140.0f/255.0f blue:1.00f alpha:1.0f];
				return;
			}
		}
	}
	
	cell.backgroundColor = [UIColor whiteColor];
}

//セクション名
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
	//集計
	if(sel_segment_ == 0){
		//読み込み中
		if(self.ana_category_list_ == nil || self.custom_ana_list_ == nil){
			return @"";			
		}
		//集計結果
		else{
			//カスタム集計方法
			if(section == 0){
				if([self.custom_ana_list_ count] > 0){
					return NSLocalizedString(@"STR-052", nil);	
				}
				else{
					return @"";
				}
			}
			//カテゴリーの集計
			else{
				return NSLocalizedString(@"STR-053", nil);	
			}
		}
	}
	//棒・円グラフ
    else if(sel_segment_ == 1 || sel_segment_ == 2){
		return @"";	
	}
	//履歴一覧
	else{
		return @"";	
	}	
}


//表示用データ取得
- (void) get_ana_data{
	self.history_list_ = nil;
	self.custom_ana_list_ = nil;
	self.ana_category_list_ = nil;
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	is_ana_multi_ = [settings boolForKey:@"IS_ANA_MULTI"];
	
	[table_view_ reloadData];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	//■■　履歴一覧　■■
	NSPredicate *pred;
	//年
	if(cur_period_ == 0){
		NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
		int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
		if(month_end_day == 0){
			pred = [NSPredicate predicateWithFormat:@"year_cur == %d and diff_type != %@", self.year_cur_, @"del"];
		}
		else{
			pred = [NSPredicate predicateWithFormat:@"%d < (year_cur * 10000 + month_cur * 100 + day_cur) and (year_cur * 10000 + month_cur * 100 + day_cur) <= %d and diff_type != %@", 
					((self.year_cur_ - 1) * 10000 + 12 * 100 + month_end_day), (self.year_cur_ * 10000 + 12 * 100 + month_end_day), @"del"];
		}
	}
	//月
	else if(cur_period_ == 1){
		NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
		int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
		if(month_end_day == 0){
			pred = [NSPredicate predicateWithFormat:@"year_cur == %d and month_cur == %d and diff_type != %@", self.year_cur_, self.month_cur_, @"del"];
		}
		else{
			if(self.month_cur_ > 1){
				pred = [NSPredicate predicateWithFormat:@"%d < (year_cur * 10000 + month_cur * 100 + day_cur) and (year_cur * 10000 + month_cur * 100 + day_cur) <= %d and diff_type != %@", 
						(self.year_cur_ * 10000 + (self.month_cur_ - 1) * 100 + month_end_day), (self.year_cur_ * 10000 + self.month_cur_ * 100 + month_end_day), @"del"];
			}
			else{
				pred = [NSPredicate predicateWithFormat:@"%d < (year_cur * 10000 + month_cur * 100 + day_cur) and (year_cur * 10000 + month_cur * 100 + day_cur) <= %d and diff_type != %@", 
						((self.year_cur_ - 1) * 10000 + 12 * 100 + month_end_day), (self.year_cur_ * 10000 + self.month_cur_ * 100 + month_end_day), @"del"];
			}
		}
	}
	//日
	else{
		pred = [NSPredicate predicateWithFormat:@"year_cur == %d and month_cur == %d and day_cur == %d and diff_type != %@", self.year_cur_, self.month_cur_, self.day_cur_, @"del"];
	}
	
	if([settings boolForKey:@"IS_SORT_ASCEND"] == TRUE){
		self.history_list_ = [[g_model_ get_history_list_with_pred:pred] sortedArrayUsingSelector:@selector(compare_date_ascend:)];
	}
	else{
		self.history_list_ = [[g_model_ get_history_list_with_pred:pred] sortedArrayUsingSelector:@selector(compare_date_descend:)];
	}
	
	//■■　カスタム集計 ■■
	self.custom_ana_list_ = [g_model_ get_use_custom_ana_list];
	for(int i=0; i<[self.custom_ana_list_ count]; i++){
		DBCustomAna* custom = (self.custom_ana_list_)[i];
	
		if([custom is_separator] == false){
			[custom calc_formula:self.year_cur_ month:self.month_cur_ day:self.day_cur_ period:cur_period_ is_multi:false];
			
			if(is_ana_multi_ == true){
				[custom calc_formula:self.year_cur_ month:self.month_cur_ day:self.day_cur_ period:cur_period_ is_multi:true];
			}			
		}
	}
	
	//集計結果が0のカスタム集計方法を弾く
	if([settings boolForKey:@"IS_HIDE_0"] == true){
		NSMutableArray* tmp_custom_ana_list2 = [[NSMutableArray alloc] init];
		
		for(int i=0; i< [self.custom_ana_list_ count]; i++){
			DBCustomAna* custom = (self.custom_ana_list_)[i];
			
			if([custom is_separator] == true){
				[tmp_custom_ana_list2 addObject:custom];
			}
			else{
				if(custom.total != 0){
					[tmp_custom_ana_list2 addObject:custom];
				}
			}
		}
		
		self.custom_ana_list_ = tmp_custom_ana_list2;
	}	
	
	//■■　集計　■■
	//既存のカテゴリーの集計
	NSMutableArray* tmp_ana_cat_list = [[NSMutableArray alloc] init];
	NSArray* show_category_list = [g_model_ get_show_category_list];
		
	for(int i=0; i< [show_category_list count]; i++){
		DBCategory* cat = show_category_list[i];
		
		MyAnaCategory* ana_cat = [[MyAnaCategory alloc] init];
		//NSLog(@"cur.name:%@", cat.cur.name);
		ana_cat.category_ = cat.cur.name;
		ana_cat.year_ = self.year_cur_;
		ana_cat.month_ = self.month_cur_;
		ana_cat.day_ = self.day_cur_;
	
		//年
		if(cur_period_ == 0){
			NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
			int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
			if(month_end_day == 0){
				pred = [NSPredicate predicateWithFormat:@"year_cur == %d and category_cur == %@ and diff_type != %@", self.year_cur_, ana_cat.category_, @"del"];
			}
			else{
				pred = [NSPredicate predicateWithFormat:@"%d < ((year_cur * 10000) + (month_cur * 100) + day_cur) and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@", 
						(((self.year_cur_ - 1) * 10000) + (12 * 100) + month_end_day), ((self.year_cur_ * 10000) + (12 * 100) + month_end_day), ana_cat.category_, @"del"];
			}
		}
		//月
		else if(cur_period_ == 1){			
			NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
			int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
			if(month_end_day == 0){
				pred = [NSPredicate predicateWithFormat:@"year_cur == %d and month_cur == %d and category_cur == %@ and diff_type != %@", self.year_cur_, self.month_cur_, ana_cat.category_, @"del"];
			}
			else{				
				if(self.month_cur_ > 1){
					pred = [NSPredicate predicateWithFormat:@"%d < ((year_cur * 10000) + (month_cur * 100) + day_cur) and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@", 
							((self.year_cur_ * 10000) + ((self.month_cur_ - 1) * 100) + month_end_day), ((self.year_cur_ * 10000) + (self.month_cur_ * 100) + month_end_day), ana_cat.category_, @"del"];
				}
				else{
					pred = [NSPredicate predicateWithFormat:@"%d < ((year_cur * 10000) + (month_cur * 100) + day_cur) and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@", 
							(((self.year_cur_ - 1) * 10000) + (12 * 100) + month_end_day), ((self.year_cur_ * 10000) + (self.month_cur_ * 100) + month_end_day), ana_cat.category_, @"del"];
				}
			}
		}
		//日
		else{
			pred = [NSPredicate predicateWithFormat:@"year_cur == %d and month_cur == %d and day_cur == %d and category_cur == %@ and diff_type != %@", self.year_cur_, self.month_cur_, self.day_cur_, ana_cat.category_, @"del"];
		}
		
		ana_cat.history_list_ = [g_model_ get_history_list_with_pred:pred];
		
		[tmp_ana_cat_list addObject:ana_cat];
	}
	
	//その他のカテゴリーの集計
	NSMutableArray* other_category_list = [[NSMutableArray alloc] init];
	
	NSMutableArray* param_list = [[NSMutableArray alloc] init];
	NSString* pred_format;
	
	//年
	if(cur_period_ == 0){
		NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
		int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
		if(month_end_day == 0){
			pred_format = @"year_cur = %d and diff_type != %@";
			[param_list addObject:@(self.year_cur_)];
			[param_list addObject:@"del"];
		}
		else{
			pred_format = @"%d < ((year_cur * 10000) + (month_cur * 100) + day_cur) and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and diff_type != %@";
			[param_list addObject:@(((self.year_cur_ - 1) * 10000) + (12 * 100) + month_end_day)];
			[param_list addObject:@((self.year_cur_ * 10000) + (12 * 100) + month_end_day)];
			[param_list addObject:@"del"];
		}
	}
	//月
	else if(cur_period_ == 1){		
		NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
		int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
		if(month_end_day == 0){
			pred_format = @"year_cur == %d and month_cur == %d and diff_type != %@";
			[param_list addObject:@(self.year_cur_)];
			[param_list addObject:@(self.month_cur_)];
			[param_list addObject:@"del"];
		}
		else{
			if(self.month_cur_ > 1){
				pred_format = @"%d < ((year_cur * 10000) + (month_cur * 100) + day_cur) and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and diff_type != %@";
				[param_list addObject:@((self.year_cur_ * 10000) + ((self.month_cur_ - 1) * 100) + month_end_day)];
				[param_list addObject:@((self.year_cur_ * 10000) + (self.month_cur_ * 100) + month_end_day)];
				[param_list addObject:@"del"];
			}
			else{
				pred_format = @"%d < ((year_cur * 10000) + (month_cur * 100) + day_cur) and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and diff_type != %@";
				[param_list addObject:@(((self.year_cur_ - 1) * 10000) + (12 * 100) + month_end_day)];
				[param_list addObject:@((self.year_cur_ * 10000) + (self.month_cur_ * 100) + month_end_day)];
				[param_list addObject:@"del"];
			}
		}
	}
	//日
	else{
		pred_format = @"year_cur = %d and month_cur = %d and day_cur = %d and diff_type != %@";
		[param_list addObject:@(self.year_cur_)];
		[param_list addObject:@(self.month_cur_)];
		[param_list addObject:@(self.day_cur_)];
		[param_list addObject:@"del"];
	}
	
	for(int i=0; i<[show_category_list count]; i++){
		DBCategory* cat = show_category_list[i];
			
		pred_format = [pred_format stringByAppendingString:@" and category_cur != %@"];		
		[param_list addObject:cat.cur.name];
	}
	//NSLog(@"pred_format:%@", pred_format);
	pred = [NSPredicate predicateWithFormat:pred_format argumentArray:param_list];
	//NSLog(@"pred:%@", pred);
	NSArray* tmp_history_list_ = [g_model_ get_history_list_with_pred_cat_order:pred];
	
	NSString* last_cat_name = nil;
	for(int i=0; i< [tmp_history_list_ count]; i++){
		DBHistory* his = tmp_history_list_[i];
		
		if(last_cat_name == nil){
			last_cat_name = his.cur.category;
			
			[other_category_list addObject:last_cat_name];
		}
		else if([last_cat_name isEqualToString:his.cur.category] == FALSE){
			last_cat_name = his.cur.category;
			
			[other_category_list addObject:last_cat_name];
		}
	}	
	
	for(int i=0; i< [other_category_list count]; i++){
		NSString* cat_name = other_category_list[i];
		
		MyAnaCategory* ana_cat = [[MyAnaCategory alloc] init];
		ana_cat.category_ = cat_name;
		ana_cat.year_ = self.year_cur_;
		ana_cat.month_ = self.month_cur_;
		ana_cat.day_ = self.day_cur_;
		
		//年
		if(cur_period_ == 0){
			NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
			int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
			if(month_end_day == 0){
				pred = [NSPredicate predicateWithFormat:@"year_cur == %d and category_cur == %@ and diff_type != %@", self.year_cur_, ana_cat.category_, @"del"];
			}
			else{
				pred = [NSPredicate predicateWithFormat:@"%d < ((year_cur * 10000) + (month_cur * 100) + day_cur) and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@",
						(((self.year_cur_ - 1) * 10000) + (12 * 100) + month_end_day), ((self.year_cur_ * 10000) + (12 * 100) + month_end_day), ana_cat.category_, @"del"];
			}
		}
		//月
		else if(cur_period_ == 1){
			NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
			int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
			if(month_end_day == 0){
				pred = [NSPredicate predicateWithFormat:@"year_cur == %d and month_cur == %d and category_cur == %@ and diff_type != %@", self.year_cur_, self.month_cur_, ana_cat.category_, @"del"];
			}
			else{				
				if(self.month_cur_ > 1){
					pred = [NSPredicate predicateWithFormat:@"%d < ((year_cur * 10000) + (month_cur * 100) + day_cur) and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@", 
							((self.year_cur_ * 10000) + ((self.month_cur_ - 1) * 100) + month_end_day), ((self.year_cur_ * 10000) + (self.month_cur_ * 100) + month_end_day), ana_cat.category_, @"del"];
				}
				else{
					pred = [NSPredicate predicateWithFormat:@"%d < ((year_cur * 10000) + (month_cur * 100) + day_cur) and ((year_cur * 10000) + (month_cur * 100) + day_cur) <= %d and category_cur == %@ and diff_type != %@", 
							(((self.year_cur_ - 1) * 10000) + (12 * 100) + month_end_day), ((self.year_cur_ * 10000) + (self.month_cur_ * 100) + month_end_day), ana_cat.category_, @"del"];
				}
			}
		}
		//日
		else{
			pred = [NSPredicate predicateWithFormat:@"year_cur == %d and month_cur == %d and day_cur == %d and category_cur == %@ and diff_type != %@", self.year_cur_, self.month_cur_, self.day_cur_, ana_cat.category_, @"del"];
		}

		ana_cat.history_list_ = [g_model_ get_history_list_with_pred:pred];
		
		[tmp_ana_cat_list addObject:ana_cat];
	}
	
	//合計を計算
	for(int i=0; i< [tmp_ana_cat_list count]; i++){
		MyAnaCategory* ana_cat = tmp_ana_cat_list[i];
		ana_cat.total_ = 0;
		
		for(int j=0; j<[ana_cat.history_list_ count]; j++){
			DBHistory *history = (ana_cat.history_list_)[j];
			
			ana_cat.total_ += history.cur.val;
		}
	}
	

	
	//年
	if(cur_period_ == 0){
		//1月単位の合計を計算
		for(int i=0; i< [tmp_ana_cat_list count]; i++){
			MyAnaCategory* ana_cat = tmp_ana_cat_list[i];
			[ana_cat update_month_total_list];
			
			if(is_ana_multi_ == true){
				[ana_cat update_total_multi_:cur_period_];
			}
		}
	}
	//月
	else if(cur_period_ == 1){
		//1日単位の合計を計算
		for(int i=0; i< [tmp_ana_cat_list count]; i++){
			MyAnaCategory* ana_cat = tmp_ana_cat_list[i];
			[ana_cat update_day_total_list];
			
			if(is_ana_multi_ == true){
				[ana_cat update_total_multi_:cur_period_];
			}
		}
	}
	//日
	else{
		//1日単位の合計を計算
		for(int i=0; i< [tmp_ana_cat_list count]; i++){
			MyAnaCategory* ana_cat = tmp_ana_cat_list[i];
			[ana_cat update_1_day_total_list];
			
			if(is_ana_multi_ == true){
				[ana_cat update_total_multi_:cur_period_];
			}
		}
	}
	
	//集計結果が0円のカテゴリーを弾く
	if([settings boolForKey:@"IS_HIDE_0"] == true){
		NSMutableArray* tmp_ana_cat_list2 = [[NSMutableArray alloc] init];
		
		for(int i=0; i< [tmp_ana_cat_list count]; i++){
			MyAnaCategory* ana_cat = tmp_ana_cat_list[i];
			
			if(ana_cat.total_ != 0){
				[tmp_ana_cat_list2 addObject:ana_cat];
			}
		}
		
		tmp_ana_cat_list = tmp_ana_cat_list2;
	}	
	
	self.ana_category_list_ = tmp_ana_cat_list;
	
	//通常カテゴリーの合計
	all_cat_total_ = 0;
	for(int i=0; i < [self.ana_category_list_ count]; i ++){
		MyAnaCategory* cat = (self.ana_category_list_)[i];
		all_cat_total_ += cat.total_;
	}
	
	//グラフデータ初期化
	[self init_graph_data];
	
	[table_view_ reloadData];
}


//セルが選択された
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//集計結果
	if(self.sel_segment_ == 0){
		//読み込み中
		if(self.ana_category_list_ == nil || self.custom_ana_list_ == nil){
			return;
		}
		//集計結果
		else{
			//カスタム集計方法
			if(indexPath.section == 0){
				return;
			}
			//カテゴリーの集計
			else{
				MyAnaCategory* category = (self.ana_category_list_)[indexPath.row];

				if([category is_separator] == true){
					return;
				}
				else{
					UIViewController* next_view = [[Ana_HistoryList alloc] init:category.category_ history_list:category.history_list_];
					[self.navigationController pushViewController:next_view animated:YES];
				}
			}
		}
		
	}
	//棒グラフ
	else if(self.sel_segment_ == 1){
		MyAnaCategory* category = (self.ana_category_list_)[indexPath.row];
		
		if([category is_separator] == true){
			return;
		}
		else{
			[self change_is_show_cat:indexPath.row];
		}
	}
	//円グラフ
	else if(self.sel_segment_ == 2){
		MyAnaCategory* category = (self.ana_category_list_)[indexPath.row];
		
		if([category is_separator] == true){
			return;
		}
		else{
			[self change_is_show_cat:indexPath.row];
		}
	}
	//履歴一覧
	else{
		
	}
	
}


//詳細表示ボタンが押された
-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath{
	if(self.sel_segment_ == 1){
		DBHistory* history = (self.history_list_)[indexPath.row];
		
		UIViewController* next_view = [[Ana_EditHistory alloc] initWithHistory:history];
		[self.navigationController pushViewController:next_view animated:YES];
	}
}


//表示するViewの更新
- (void) update_show_view{	
	
	//集計結果
	if(self.sel_segment_ == 0){
		[self.graph_type_button_ setHidden:TRUE];
		[scroll_view_ setHidden:YES];
		[graph_v_label_view_ setHidden:YES];
		[graph_sub_view_ setHidden:YES];
		[graph_view_circle_ setHidden:YES];
		
		CGRect frame = self.view.frame;
		frame.origin.y = 47.0;
		frame.size.height = self.view.frame.size.height - 47.0;
		[table_view_ setFrame:frame];
		
		[table_view_ setSectionHeaderHeight:10.0];
	}
	//棒グラフ
	else if(self.sel_segment_ == 1){
		[self.graph_type_button_ setHidden:NO];
		[scroll_view_ setHidden:NO];
		[graph_v_label_view_ setHidden:NO];
		[graph_sub_view_ setHidden:NO];
		[graph_view_circle_ setHidden:YES];
		
		if(graph_view_.is_line_graph_ == TRUE){
			[self.graph_type_button_ setImage:self.img_graph_line_ forState:UIControlStateNormal];
		}
		else{
			[self.graph_type_button_ setImage:self.img_graph_bar_ forState:UIControlStateNormal];
		}
		
		CGRect frame = table_view_.frame;
		frame.origin.y = scroll_view_.frame.size.height;
		frame.size.height = self.view.frame.size.height - scroll_view_.frame.size.height;
		[table_view_ setFrame:frame];
		
		[table_view_ setSectionHeaderHeight:10.0];
		
		
		//目盛りセット
		[graph_view_ set_hol_point_labels:[self get_holizontal_label_list]];
		
		//グラフViewのサイズ
		scroll_view_.contentSize = graph_view_.frame.size;
		
		//初期スクロール位置
		if(graph_view_.frame.size.width > 320) scroll_view_.contentOffset = CGPointMake(graph_view_.frame.size.width - 320, 0);
		else scroll_view_.contentOffset = CGPointMake(0, 0);		
		
		[self update_graph];
	}
	//円グラフ
	else if(self.sel_segment_ == 2){
		[self.graph_type_button_ setHidden:YES];
		[scroll_view_ setHidden:YES];
		[graph_v_label_view_ setHidden:YES];
		[graph_sub_view_ setHidden:YES];
		[graph_view_circle_ setHidden:NO];
		
		CGRect frame = table_view_.frame;
		frame.origin.y = graph_view_circle_.frame.size.height;
		frame.size.height = self.view.frame.size.height - graph_view_circle_.frame.size.height;
		[table_view_ setFrame:frame];
		
		[table_view_ setSectionHeaderHeight:10.0];
	
		[self update_graph];
	}
	//履歴一覧
	else{
		[self.graph_type_button_ setHidden:TRUE];
		[scroll_view_ setHidden:YES];
		[graph_v_label_view_ setHidden:YES];
		[graph_sub_view_ setHidden:YES];
		[graph_view_circle_ setHidden:YES];
		
		CGRect frame = table_view_.frame;
		frame.origin.y = 47.0f;
		frame.size.height = 320.0f;
		[table_view_ setFrame:frame];
	}
}


//セグメントの変更
- (IBAction) segmentDidChange:(id)sender{
	UISegmentedControl* segment = sender;
	self.sel_segment_ = segment.selectedSegmentIndex;
	
	[self update_show_view];
	[table_view_ reloadData];
	
	///リストの先頭を表示
	if([table_view_ numberOfRowsInSection:0] > 0){
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		[table_view_ scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
	}
}


//集計結果に戻す
- (void) reset_segment{
	[segment_ setSelectedSegmentIndex:0];
	[self segmentDidChange:segment_];
}


//前の月
- (void) prev_month_button_tap{
	//年
	if(cur_period_ == 0){
		self.year_cur_ --;
		self.month_cur_ = 1;
		self.day_cur_ = 1;
	}
	//月
	else if(cur_period_ == 1){
		if(self.month_cur_ == 1){
			self.year_cur_ --;
			self.month_cur_ = 12;
			self.day_cur_ = 1;
		}
		else{
			self.month_cur_ --;
			self.day_cur_ = 1;
		}
	}
	//日
	else{
		if(self.day_cur_ == 1){
			if(self.month_cur_ == 1){
				self.year_cur_ --;
				self.month_cur_ = 12;
				self.day_cur_ = [self get_day_num_in_month:self.year_cur_ month:self.month_cur_];
			}
			else{
				self.month_cur_ --;
				self.day_cur_ = [self get_day_num_in_month:self.year_cur_ month:self.month_cur_];
			}
		}
		else{
			self.day_cur_ --;
		}
	}
	
	[self update_title];
	[self get_ana_data];
	[self update_show_view];
	[table_view_ reloadData];
}


//次の月
- (void) next_month_button_tap{
	//年
	if(cur_period_ == 0){
		self.year_cur_ ++;
		self.month_cur_ = 1;
		self.day_cur_ = 1;
	}
	//月
	else if(cur_period_ == 1){
		if(self.month_cur_ == 12){
			self.year_cur_ ++;
			self.month_cur_ = 1;
			self.day_cur_ = 1;
		}
		else{
			self.month_cur_ ++;
			self.day_cur_ = 1;
		}
	}
	//日
	else{
		if(self.day_cur_ == [self get_day_num_in_month:self.year_cur_ month:self.month_cur_]){
			if(self.month_cur_ == 12){
				self.year_cur_ ++;
				self.month_cur_ = 1;
				self.day_cur_ = 1;
			}
			else{
				self.month_cur_ ++;
				self.day_cur_ = 1;
			}
		}
		else{
			self.day_cur_ ++;
		}
	}
	
	[self update_title];
	[self get_ana_data];
	[self update_show_view];
	[table_view_ reloadData];
}


//期間変更
- (void) period_button_tap{
	Ana_SelectDate *vc = [[Ana_SelectDate alloc] init:cur_period_ year:year_cur_ month:month_cur_ day:day_cur_];
	[self.navigationController pushViewController:vc animated:YES];
	
	return;
	
	UIActionSheet* sheet = [[MyUIActionSheet alloc] init];
	sheet.delegate = self;
	sheet.tag = 1;
	
	sheet.title = NSLocalizedString(@"STR-204", nil);
	[sheet addButtonWithTitle:NSLocalizedString(@"STR-122", nil)];
	[sheet addButtonWithTitle:NSLocalizedString(@"STR-123", nil)];
	[sheet addButtonWithTitle:NSLocalizedString(@"STR-124", nil)];	
	[sheet addButtonWithTitle:NSLocalizedString(@"STR-003", nil)];
	sheet.cancelButtonIndex = 3;
	
	[sheet showInView:self.tabBarController.view];
}

- (IBAction) date_selected:(int)unit_ year:(int)year_ month:(int)month_ day:(int)day_{
	cur_period_ = unit_;
	self.year_cur_ = year_;
	self.month_cur_ = month_;
	self.day_cur_ = day_;
	
	[self update_title];
	[self get_ana_data];
	[self update_show_view];
	[table_view_ reloadData];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{	
	//日単位
	if(buttonIndex == 0){		
		cur_period_ = 0;
	}
	//月単位
	else if(buttonIndex == 1){
		cur_period_ = 1;
	}
	//年単位
	else if(buttonIndex == 2){
		cur_period_ = 2;
	}
	//キャンセル
	else{
		return;
	}
		
	[self update_title];
	[self get_ana_data];
	[self update_show_view];
	[table_view_ reloadData];
}


//■■■　グラフ用
//データの初期化
- (void) init_graph_data{	
	self.is_graph_on_ = [[NSMutableArray alloc] init];
	for(int i=0; i < [self.ana_category_list_ count]; i ++){
		[self.is_graph_on_ addObject:[NSNumber numberWithBool:FALSE]];		
	}
	
	self.color_list_ = [self get_color_list];
	
	self.cat_color_list_ = [[NSMutableArray alloc] init];
	for(int i=0; i < [self.color_list_ count]; i ++){
		[self.cat_color_list_ addObject:@-1];
	}
	
	//先頭３つは表示ONにする
	int on_num = 0;
	for(int i=0; i < [self.ana_category_list_ count] && on_num < 3; i ++){
		MyAnaCategory* category = (self.ana_category_list_)[i];
		
		if([category is_separator] == false){
			[self change_is_show_cat:i];
			on_num ++;
		}
	}
}


//当月の日数を取得
- (int) get_day_num_in_month:(NSInteger)year month:(NSInteger)month{	
	//月末の日を取得
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:year];
	[comps setMonth:month];
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDate *date = [cal dateFromComponents:comps];
	
	// inUnit:で指定した単位（月）の中で、rangeOfUnit:で指定した単位（日）が取り得る範囲
	NSRange range = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
	NSInteger max = range.length;
	
	return max;
}

- (int) get_day_num_in_month{
	return [self get_day_num_in_month:self.year_cur_ month:self.month_cur_];
}


//描画するラインのリスト
- (NSMutableArray*) get_draw_line_list{	
	NSMutableArray* lines = [[NSMutableArray alloc] init];
	
	for(int i=0; i < [self.cat_color_list_ count]; i ++){
		int index = [(self.cat_color_list_)[i] intValue];
		
		if(index == -1){
			[lines addObject:[NSNull null]];
		}
		else{
			MyAnaCategory* cat = (self.ana_category_list_)[index];
			[lines addObject:cat.day_total_list_];
		}
	}
	
	return lines;
}

//描画する円グラフの割合のリスト
- (NSMutableArray*) get_draw_cat_rate_list_{
	NSMutableArray* cat_rate_list = [[NSMutableArray alloc] init];
	
	for(int i=0; i < [self.cat_color_list_ count]; i ++){
		int index = [(self.cat_color_list_)[i] intValue];
		
		if(index == -1){
			[cat_rate_list addObject:[NSNull null]];
		}
		else{
			MyAnaCategory* cat = (self.ana_category_list_)[index];
			float rate = (float)cat.total_ / all_cat_total_;

			[cat_rate_list addObject:@(rate)];
		}
	}

	return cat_rate_list;
}


//水平目盛りのリスト
- (NSMutableArray*) get_holizontal_label_list{
	NSMutableArray* labels;
	
	//年
	if(cur_period_ == 0){
		int day_num = 12;
		
		labels = [[NSMutableArray alloc] init];
		
		for(int i=1; i <= day_num; i ++){
			NSString* label = [NSString stringWithFormat:@"%d%@", i, NSLocalizedString(@"STR-123", nil)];
			
			[labels addObject:label];
		}
	}
	//月
	else if(cur_period_ == 1){
		NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
		int month_end_day = [settings integerForKey:@"MONTH_END_DAY"];
		
		if(month_end_day == 0){
			int day_num = [self get_day_num_in_month];
			
			labels = [[NSMutableArray alloc] init];
			
			for(int i=1; i <= day_num; i ++){
				NSString* label = [NSString stringWithFormat:@"%d/%d", month_cur_, i];
				
				[labels addObject:label];
			}
		}
		else{
			int prev_month_day_num;
			if(self.month_cur_ == 1){
				prev_month_day_num = [self get_day_num_in_month:self.year_cur_ - 1 month:12];
			}
			else{
				prev_month_day_num = [self get_day_num_in_month:self.year_cur_ month:self.month_cur_ - 1];
			}
			int month_day_num = [self get_day_num_in_month:self.year_cur_ month:self.month_cur_];
			
			labels = [[NSMutableArray alloc] init];
			
			for(int i=month_end_day+1; i<=prev_month_day_num; i++){
				NSString* label;
				if(self.month_cur_ == 1){
					label = [NSString stringWithFormat:@"%d/%d", 12, i];
				}
				else{
					label = [NSString stringWithFormat:@"%d/%d", self.month_cur_ - 1, i];
				}
				
				[labels addObject:label];
			}
			
			for(int i=1; i<=month_end_day && i<=month_day_num; i++){
				NSString* label = [NSString stringWithFormat:@"%d/%d", self.month_cur_, i];
				
				[labels addObject:label];
			}
		}
	}
	//日
	else{		
		labels = [[NSMutableArray alloc] init];
		
		NSString* label = [NSString stringWithFormat:@"%d/%d", month_cur_, day_cur_];
			
		[labels addObject:label];
	}
	
	return labels;
}


//スイッチが切り替えられた
- (void) change_is_show_cat:(NSInteger) data_index{
	BOOL cur_is_on = [(self.is_graph_on_)[data_index] boolValue];
	
	if(cur_is_on == FALSE){
		int i;
		for(i=0; i<[self.cat_color_list_ count]; i++){
			int index = [(self.cat_color_list_)[i] intValue];
			
			//色に空きがある場合
			if(index == -1){
				(self.cat_color_list_)[i] = @(data_index);
				(self.is_graph_on_)[data_index] = [NSNumber numberWithBool:TRUE];
				break;
			}
		}
	}
	else{
		(self.is_graph_on_)[data_index] = [NSNumber numberWithBool:FALSE];
		
		for(int i=0; i<[self.cat_color_list_ count]; i++){
			int index = [(self.cat_color_list_)[i] intValue];
			
			if(index == data_index){
				(self.cat_color_list_)[i] = @-1;
				break;
			}
		}
	}
	
	[table_view_ reloadData];
	[self update_graph];
}


//グラフの描画
- (void) update_graph{
	//棒グラフ
	if(self.sel_segment_ == 1){
		//描画データのセット
		NSArray* draw_lines = [self get_draw_line_list];
		
		[graph_view_ set_draw_data:draw_lines line_color:self.color_list_];
		
		//再描画
		[graph_view_ setNeedsDisplay];
	}
	//円グラフ
	else if(self.sel_segment_ == 2){
		//描画データのセット
		NSArray* draw_cat_rate_list_ = [self get_draw_cat_rate_list_];
		
		[graph_view_circle_ set_draw_data:draw_cat_rate_list_ cat_color_list:self.color_list_];
		
		//再描画
		[graph_view_circle_ setNeedsDisplay];
	}
}


//ライン色作成
- (NSArray*) get_color_list{
	NSArray* colors = @[[[MyColor alloc]initWithColorNo:0], [[MyColor alloc]initWithColorNo:1], [[MyColor alloc]initWithColorNo:2], 
					   [[MyColor alloc]initWithColorNo:3], [[MyColor alloc]initWithColorNo:4], [[MyColor alloc]initWithColorNo:5], 
					   [[MyColor alloc]initWithColorNo:6], [[MyColor alloc]initWithColorNo:7], [[MyColor alloc]initWithColorNo:8], 
					   [[MyColor alloc]initWithColorNo:9]];
	
	return colors;
}


//グラフタイプの変更
- (void) tap_graph_type_button{
	[graph_view_ set_is_line_graph:! graph_view_.is_line_graph_];
	if(graph_view_.is_line_graph_ == TRUE){
		[self.graph_type_button_ setImage:self.img_graph_line_ forState:UIControlStateNormal];
	}
	else{
		[self.graph_type_button_ setImage:self.img_graph_bar_ forState:UIControlStateNormal];
	}
	
	[graph_view_ setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
