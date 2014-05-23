//
//  MyHistoryCell.h
//  kakeibo
//
//  Created by hiro on 11/04/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyHistoryCell : UITableViewCell {
	IBOutlet UILabel* date_;
	IBOutlet UILabel* category_;
	IBOutlet UILabel* val_;
	IBOutlet UILabel* memo_;
}

@property (nonatomic, strong) UILabel* date_;
@property (nonatomic, strong) UILabel* category_;
@property (nonatomic, strong) UILabel* val_;
@property (nonatomic, strong) UILabel* memo_;


@end
