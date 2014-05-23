//
//  MyConflictCell_Category.m
//  kakeibo
//
//  Created by hiro on 11/04/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyConflictCell_CustomAna.h"


@implementation MyConflictCell_CustomAna
@synthesize radio_button_, label_src_, label_name_, label_formula_, label_unit_;


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
