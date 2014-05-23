//
//  MyConflictCell_Category.h
//  kakeibo
//
//  Created by hiro on 11/04/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyConflictCell_Category : UITableViewCell {
	IBOutlet UIImageView* radio_button_;
	IBOutlet UILabel* label_src_;
	IBOutlet UILabel* label_val_;
}

@property (nonatomic, strong) UIImageView* radio_button_;
@property (nonatomic, strong) UILabel* label_src_;
@property (nonatomic, strong) UILabel* label_val_;

@end
