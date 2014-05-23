//
//  DateKeyboard.m
//  kakeibo2
//
//  Created by hiro on 2013/04/16.
//  Copyright (c) 2013年 hiro. All rights reserved.
//

#import "DateKeyboard.h"
#import "CommonAPI.h"

@interface DateKeyboard ()

@property (weak) UITextField *text_field;
@property (weak) NSDate* date;
@property (weak) IBOutlet UIDatePicker* picker;
@property (weak) id<DataKeyboardDelegate> delegate;

- (IBAction)date_changed:(UIDatePicker*)sender;

@end

@implementation DateKeyboard

- (void) init_text_field:(UITextField*)text_field date:(NSDate*)date delegate:(id)delegate{
	self.text_field = text_field;
	self.date = date;
	self.delegate = delegate;
}

- (void) set_date:(NSDate*)date{
	self.date = date;
	
	if(self.date != nil){
		self.picker.date = self.date;
		self.text_field.text = [CommonAPI get_day_string_with_week:self.picker.date];
	}
	else{
		self.picker.date = [NSDate date];
		self.text_field.text = @"なし";
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 216);
	
	if(self.date != nil){
		self.picker.date = self.date;
		self.text_field.text = [CommonAPI get_day_string_with_week:self.picker.date];
	}
	else{
		self.picker.date = [NSDate date];
		self.text_field.text = @"なし";
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)date_changed:(UIDatePicker*)sender{
	self.text_field.text = [CommonAPI get_day_string_with_week:sender.date];
	
	[self.delegate date_changed:self date:sender.date];
}

@end
