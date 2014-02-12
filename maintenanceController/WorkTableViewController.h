//
//  WorkTableViewController.h
//  Template
//
//  Created by Mac on 15.11.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBXML.h"
#import "TBXMLFunctions.h"

@interface WorkTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{


	TBXML* workXML;
	TBXMLElement* maintenance;
	
	
	
	NSMutableArray *steps ; //Array für die steps für die TableView
	NSMutableArray *infParts ; //Array für die infected parts für die TableView
	
	NSInteger currentStepRow; //speichert die aktuelle row der stepstable

	
	
	IBOutlet UITextView *descriptionTextView;
	IBOutlet UITextView *nameTextView;
	IBOutlet UITableView *stepsTable;
	IBOutlet UITableView *partsTable;

}

- (IBAction)nextStep:(id)sender;
- (IBAction)prevStep:(id)sender;

@end
