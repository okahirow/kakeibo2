//
//  MyHistoryCell.m
//  kakeibo
//
//  Created by hiro on 11/04/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyHistoryCell.h"


@implementation MyHistoryCell
@synthesize date_, category_, val_, memo_;

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
