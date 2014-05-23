//
//  MyAnaGraphCell.h
//  PSPTimer
//
//  Created by hiro on 11/02/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAnaGraphCell : UITableViewCell {
	IBOutlet UILabel* category_;
	IBOutlet UILabel* total_;
	IBOutlet UILabel* color_;
}

@property (strong) UILabel* category_;
@property (strong) UILabel* total_;
@property (strong) UILabel* color_;

@end
