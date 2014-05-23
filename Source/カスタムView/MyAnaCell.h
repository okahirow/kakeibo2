//
//  MyAnaCell.h
//  kakeibo
//
//  Created by hiro on 11/04/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyAnaCell : UITableViewCell {
	IBOutlet UILabel* title_;	
	IBOutlet UILabel* total_;
	IBOutlet UILabel* unit_;
}

@property (strong) UILabel* title_;
@property (strong) UILabel* total_;
@property (strong) UILabel* unit_;

@end
