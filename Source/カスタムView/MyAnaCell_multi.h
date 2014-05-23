//
//  MyAnaCell_multi.h
//  kakeibo
//
//  Created by hiro on 11/04/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyAnaCell_multi : UITableViewCell {
	IBOutlet UILabel* title_;	
	IBOutlet UILabel* total_;
	IBOutlet UILabel* unit_;
	
	IBOutlet UILabel* period_;
	IBOutlet UILabel* total_multi_;
	IBOutlet UILabel* unit_multi_;
}

@property (strong) UILabel* title_;
@property (strong) UILabel* total_;
@property (strong) UILabel* unit_;
@property (strong) UILabel* period_;
@property (strong) UILabel* total_multi_;
@property (strong) UILabel* unit_multi_;

@end
