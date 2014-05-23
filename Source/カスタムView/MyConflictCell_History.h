//
//  MyConflictCell_History.h
//  kakeibo
//
//  Created by hiro on 11/04/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyConflictCell_History : UITableViewCell {
	IBOutlet UIImageView* radio_button_;
	IBOutlet UILabel* label_src_;
	IBOutlet UILabel* label_date_;
	IBOutlet UILabel* label_category_;
	IBOutlet UILabel* label_val_;
	IBOutlet UILabel* label_memo_;
}

@property (nonatomic, strong) UIImageView* radio_button_;
@property (nonatomic, strong) UILabel* label_src_;
@property (nonatomic, strong) UILabel* label_date_;
@property (nonatomic, strong) UILabel* label_category_;
@property (nonatomic, strong) UILabel* label_val_;
@property (nonatomic, strong) UILabel* label_memo_;

@end
