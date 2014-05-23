//
//  MyConflictCell_CustomAna.h
//  kakeibo
//
//  Created by hiro on 11/04/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyConflictCell_CustomAna : UITableViewCell {
	IBOutlet UIImageView* radio_button_;
	IBOutlet UILabel* label_src_;
	IBOutlet UILabel* label_name_;
	IBOutlet UILabel* label_unit_;
	IBOutlet UILabel* label_formula_;
}

@property (nonatomic, strong) UIImageView* radio_button_;
@property (nonatomic, strong) UILabel* label_src_;
@property (nonatomic, strong) UILabel* label_name_;
@property (nonatomic, strong) UILabel* label_formula_;
@property (nonatomic, strong) UILabel* label_unit_;

@end
