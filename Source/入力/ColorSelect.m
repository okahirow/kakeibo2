//
//  ColorSelect.m
//  kakeibo2
//
//  Created by hiro on 2013/03/19.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "ColorSelect.h"
#import "MyColor.h"

@interface ColorSelect ()

@end

@implementation ColorSelect

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		self.cur_color = [[MyColor alloc] initWithR:1.0 G:1.0 B:1.0 A:1.0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self update_color_view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (IBAction) color_tap:(UIButton*)sender{
	UIColor* color = sender.backgroundColor;
	float r, g, b;
	[color getRed:&r green:&g blue:&b alpha:nil];
	self.cur_color = [[MyColor alloc] initWithR:r G:g B:b A:1.0];
	
	[self update_color_view];
}

- (void)update_color_view{
	[self.slider_r setValue:self.cur_color.r animated:YES];
	[self.slider_g setValue:self.cur_color.g animated:YES];
	[self.slider_b setValue:self.cur_color.b animated:YES];
	
	self.label_r.text = [NSString stringWithFormat:@"%d", (int)(255 * self.cur_color.r)];
	self.label_g.text = [NSString stringWithFormat:@"%d", (int)(255 * self.cur_color.g)];
	self.label_b.text = [NSString stringWithFormat:@"%d", (int)(255 * self.cur_color.b)];
	
	self.label_color.textColor = [self.cur_color ui_color];
}

- (IBAction) slider_move:(UISlider*)sender{
	self.cur_color.r = self.slider_r.value;
	self.cur_color.g = self.slider_g.value;
	self.cur_color.b = self.slider_b.value;
	
	[self update_color_view];
}

- (IBAction) done_tap:(id)sender{
	[self.color_select_delegate color_selected:self.cur_color];
	[self.navigationController popViewControllerAnimated:YES];
}

@end
