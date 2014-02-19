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


@interface WorkTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIScrollViewDelegate>
{

	NSString* documentsDir; //Pfad zum dokumenten ordner
	
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
	NSMutableArray* addedReportsArray;
	
	
	
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
	IBOutlet UIView *reportAddView;
	IBOutlet UIButton *reportPictureBto;
	
	UIScrollView* repImgScrollView; //View um das image des reports in fullscreen zu zeigen
	
	
	IBOutlet UIView *screenshotTakeView;

	

}

@property (nonatomic,weak) id <WorkTableViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIView *reportAddView;
@property (nonatomic, strong) IBOutlet UIView *screenshotTakeView;



-(void)loadContent;
-(void)changeToReport:(bool)change;

- (IBAction)nextStep:(id)sender;
- (IBAction)prevStep:(id)sender;
- (IBAction)saveReport:(id)sender;
- (IBAction)addScreenshot:(id)sender;
- (IBAction)cancelReport:(id)sender;
- (IBAction)showReportPictureFull:(id)sender;


- (IBAction)screenshotCancel:(id)sender;
- (IBAction)takeScreenshot:(id)sender;
- (IBAction)take5sScreenshot:(id)sender;



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
			 to:(bool)show
 withAnimations:(bool)ani;

-(void) removeWorkView:(bool)front;


@end
