//
//  ViewController.m
//  Template
//
//  Created by Mac on 30.04.13.
//  Copyright (c) 2013 itm. All rights reserved.
//


//-------------------
//Template für metaio5.3
//-------------------


#import "ViewController.h"


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
}

-(void)viewDidAppear:(BOOL)animated
{
	
	animated = true;
	
	if (animated == false)
	{
		navigationViewController *nvc = [[navigationViewController alloc]init];
		
		[self presentViewController:nvc animated:YES completion:nil];
	}


	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startMaintenance:(id)sender
{
	MaintenanceViewController *mvc = [[MaintenanceViewController alloc]init];
	
	[self presentViewController:mvc animated:YES completion:nil];

}

- (IBAction)startNavigation:(id)sender
{

	navigationViewController *nvc = [[navigationViewController alloc]init];
	
	[self presentViewController:nvc animated:YES completion:nil];
	
}





@end
