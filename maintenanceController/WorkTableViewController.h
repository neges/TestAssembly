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

@protocol WorkTableViewControllerDelegate;


@interface WorkTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{

	
	TBXMLElement* maintenance;
	TBXMLElement* reports;
	TBXML* workXML;
	TBXML* reportsXML;
	
	
	
	
	NSMutableArray *steps ; //Array für die steps für die TableView
	NSMutableArray *infParts ; //Array für die infected parts für die TableView
	
	NSInteger currentStepRow; //speichert die aktuelle row der stepstable

	NSTimer *highlightTimer; //Timmer für das Blinken
	
	NSMutableArray* hiddenParts ;
	NSMutableArray* reportsArray;
	
	
	
	IBOutlet UITextView *descriptionTextView;
	IBOutlet UITextView *nameTextView;
	IBOutlet UITableView *stepsTable;
	IBOutlet UITableView *partsTable;
	IBOutlet UITableView *reportsTable;
	IBOutlet UITextView *reportTextView;
	
	
	IBOutlet UIButton *nextStepBto;
	IBOutlet UIButton *prevStepBto;
	
	IBOutlet UILabel *dateLable;
	IBOutlet UILabel *userLable;
	IBOutlet UILabel *stepLable;
	IBOutlet UIImageView *screenshotView;
	IBOutlet UITextField *reportNameField;
	IBOutlet UITextView *descriptionText;
	IBOutlet UIView *newReportView;
	

}

@property (nonatomic,weak) id <WorkTableViewControllerDelegate> delegate;




-(void)loadContent;
-(void)changeToReport:(bool)change;

- (IBAction)nextStep:(id)sender;
- (IBAction)prevStep:(id)sender;
- (IBAction)saveReport:(id)sender;
- (IBAction)addScreenshot:(id)sender;
- (IBAction)cancelReport:(id)sender;


@end

@protocol WorkTableViewControllerDelegate

- (void)select3dContentWithName:(NSString*)content
					withUIColor:(NSString*)sColor
						toGroup:(bool)group
					withObjects:(NSMutableArray*)wObjects;

-(bool)setModelWithName:(NSString *)sName
				visible:(bool)visible;

-(void)saveInXMLforObjectName:(NSString*)oName
				  toAttribute:(NSString*)atr
					withValue:(char*)val;

-(void) reloadStructerTable;

-(void) addView:(UIView*)aView
			 to:(bool)show;



@end
