//
//  MyCategorySelectCell.h
//  kakeibo
//
//  Created by hiro on 11/04/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyCategorySelectCell : UITableViewCell {
	IBOutlet UILabel* title_;	
	IBOutlet UILabel* category_;	
}

@property (strong) UILabel* category_;
@property (strong) UILabel* title_;

@end
