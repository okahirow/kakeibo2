//
//  MyDebugHistoryCell.h
//  kakeibo
//
//  Created by hiro on 11/04/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyDebugHistoryCell : UITableViewCell {
	IBOutlet UILabel* label1_;
	IBOutlet UILabel* label2_;
	IBOutlet UILabel* label3_;
}

@property (nonatomic, strong) UILabel* label1_;
@property (nonatomic, strong) UILabel* label2_;
@property (nonatomic, strong) UILabel* label3_;


@end
