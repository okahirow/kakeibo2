//
//  MyAnaGraphCell.m
//  PSPTimer
//
//  Created by hiro on 11/02/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyAnaGraphCell.h"


@implementation MyAnaGraphCell

@synthesize category_, total_, color_;

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
