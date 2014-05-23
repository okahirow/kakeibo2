//
//  LoadingCell.m
//  PSPTimer
//
//  Created by hiro on 10/11/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoadingCell.h"


@implementation LoadingCell

@synthesize title;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
	}
    return self;
}

- (void) add_indicator{
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[self addSubview:indicator];
	
	[indicator setFrame:CGRectMake(20, (self.bounds.size.height - indicator.frame.size.height)/2.0f, indicator.frame.size.width, indicator.frame.size.height)];
	indicator.contentMode = UIViewContentModeScaleAspectFit;
	indicator.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[indicator startAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
