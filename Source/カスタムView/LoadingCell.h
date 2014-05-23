//
//  LoadingCell.h
//  PSPTimer
//
//  Created by hiro on 10/11/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadingCell : UITableViewCell {
	IBOutlet UILabel* title;
}

@property (strong) UILabel* title;

- (void) add_indicator;

@end
