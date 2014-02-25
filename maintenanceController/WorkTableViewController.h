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
	NSMutableArray* reportsElementsArray;
	NSMutableArray* addedReportsArray;
	
	NSMutableArray* infectedPartsArray;
	
	NSString* infectedPartSelected;

	
	
	
	
	IBOutlet UITextView *descriptionTextView;
	IBOutlet UITextView *nameTextView;
	IBOutlet UITableView *stepsTable;
	IBOutlet UITableView *reportsTable;
	IBOutlet UITextView *reportTextView;
	
	IBOutlet UILabel *dateLable;
	IBOutlet UILabel *userLable;
	IBOutlet UILabel *stepLable;
	IBOutlet UIImageView *screenshotView;
	IBOutlet UITextField *reportNameField;
	IBOutlet UITextView *descriptionText;
	IBOutlet UIView *reportAddView;
	IBOutlet UIButton *reportPictureBto;
	IBOutlet UIImageView *screenShotPreviewView;
	IBOutlet UIButton *take5sScreenshotBto;
	
	IBOutlet UIButton *infectedPartsBto;
	IBOutlet UITableView *infectedPartsTable;
	
	
	
	NSTimer* screenshotTimer;
	int timerValue;
	
	NSInteger delIndexPathRow;
	
	
	UIScrollView* repImgScrollView; //View um das image des reports in fullscreen zu zeigen
	
	IBOutlet UILabel *timerLabel;


}

@property (nonatomic,weak) id <WorkTableViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIView *reportAddView;
@property (nonatomic, strong) IBOutlet UIView *screenshotTakeView;
@property (nonatomic, strong) IBOutlet UIView *screenshotUseView;
@property (nonatomic) bool addingReport; //Variable um festzuhalen das gerade eine Report geadded wird




- (void)loadContent;

- (void)requestCameraImage:(UIImage*)requestedImage;

- (void)addNewReport;

- (void)getSelectedElement:(NSString*)selectedElement;

- (void)getReportsForElementNamed:(NSString*)repElementName;


- (IBAction)nextTableCell:(id)sender;
- (IBAction)prevTableCell:(id)sender;
- (IBAction)saveReport:(id)sender;
- (IBAction)addScreenshot:(id)sender;
- (IBAction)cancelReport:(id)sender;
- (IBAction)showReportPictureFull:(id)sender;
- (IBAction)addInfectedPartsToReport:(id)sender;


- (IBAction)screenshotCancel:(id)sender;
- (IBAction)takeScreenshot:(id)sender;
- (IBAction)take5sScreenshot:(id)sender;
- (IBAction)virtualModeChange:(id)sender;
- (IBAction)useScreenshot:(id)sender;
- (IBAction)retryScreenshot:(id)sender;




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
withAnimationsFrom:(NSString*)ani;

-(void) removeWorkView:(bool)front;

-(void) setObjectToInvisibleCos;

-(void) getScreenshotFromMetaio;

- (void) slideTableIn:(bool)ingoing;

- (void)slideTabBarIn:(bool)ingoing;

- (void) getReportsForElements:(NSMutableArray*)gArray;

- (void) selectTabBarItem:(NSInteger)tabBarItemIndex;





@end
