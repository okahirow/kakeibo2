//
//  MyAnaCell_multi.m
//  kakeibo
//
//  Created by hiro on 11/04/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyAnaCell_multi.h"


@implementation MyAnaCell_multi
@synthesize total_, title_, unit_;
@synthesize total_multi_, unit_multi_, period_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}




@end
