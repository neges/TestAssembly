//
//  WorkTableViewController.m
//  Template
//
//  Created by Mac on 15.11.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import "WorkTableViewController.h"

@interface WorkTableViewController ()

@end

@implementation WorkTableViewController

@synthesize delegate;
@synthesize reportAddView, screenshotTakeView, screenshotUseView;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
	{
		
		reportAddView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [super view].frame.size.width, [super view].frame.size.height)];
		screenshotTakeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , [super view].frame.size.width, [super view].frame.size.height)];
		screenshotUseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , [super view].frame.size.width, [super view].frame.size.height)];
		
	}

	
    return self;
}

-(void)loadContent
{

	//Dokuenten Ordner holen
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	documentsDir = [paths objectAtIndex:0];
	
	[self loadWorkInstructionForXML];
	[self loadReports];
	
	addedReportsArray = [[NSMutableArray alloc]init];
	repImgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)];
	
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	
}


#pragma mark -
#pragma mark - Load Work Instructions
#pragma mark -


- (void)loadWorkInstructionForXML
{

	NSString *workinstructionsPath =  [NSString stringWithFormat:@"%@/%@",documentsDir,@"workinstructions"];
	
	NSString *xmlPath =  [NSString stringWithFormat:@"%@/%@",workinstructionsPath,@"work_20131113.xml"];
	
	//xml laden falls vorhanden
	NSString* theContents = [[NSString alloc] initWithContentsOfFile:xmlPath encoding:NSUTF8StringEncoding error:nil];
	workXML = [TBXML newTBXMLWithXMLString:theContents error:nil];
	
	maintenance = workXML.rootXMLElement;

	if (!workXML || !maintenance) {
		NSLog(@"No structur file could be found or structur file is incorrect : %@", xmlPath);
		return;
	};
	
	
	[nameTextView setText:[TBXMLFunctions getAttribute:@"name" OfElement:maintenance]];
	

	steps = [[NSMutableArray alloc]init];
	[TBXMLFunctions getAllChilds:maintenance toArray:steps];
	
	currentStepRow = -1;
	
	hiddenParts = [[NSMutableArray alloc]init];
	
	
	
	

}

-(void)loadReports
{


	NSString *workinstructionsPath =  [NSString stringWithFormat:@"%@/%@",documentsDir,@"workinstructions"];
	
	NSString *xmlPath =  [NSString stringWithFormat:@"%@/%@",workinstructionsPath,@"reports.xml"];
	
	//xml laden falls vorhanden
	NSString* theContents = [[NSString alloc] initWithContentsOfFile:xmlPath encoding:NSUTF8StringEncoding error:nil];
	reportsXML = [TBXML newTBXMLWithXMLString:theContents error:nil];
	reports = reportsXML.rootXMLElement;
	
	if (!reportsXML || !reports) {
		NSLog(@"No structur file could be found or structur file is incorrect : %@", xmlPath);
		return;
	};
	
	
	reportsArray = [[NSMutableArray alloc]init];
	[TBXMLFunctions getAllChilds:reports toArray:reportsArray];

	
	
	

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	
	
	switch (tableView.tag) {
		case 0:
			return [steps count];
			break;
			
		case 1:
			if (infParts)
				return [infParts count];
			else
				return 0;
			break;
			
		case 2:
			return [reportsArray count];
			break;
			
		default:
			return 0;
			break;
	}
	
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

	switch (tableView.tag) {
		case 0:
			return [NSString stringWithFormat:@"steps - %i", [steps count] ];
			break;
			
		case 1:
			return [NSString stringWithFormat:@"infected parts - %i", [infParts count] ];
			break;
			
		case 2:
			return [NSString stringWithFormat:@"reports - %i", [reportsArray count] ];
			break;
			
		default:
			return nil;
			break;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	if (tableView.tag == 2)
	{
			CGFloat cellWidth = tableView.frame.size.width;
			
			UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cellWidth, 40.0)];
			[myView setBackgroundColor:[UIColor lightGrayColor]];
		
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			[button setFrame:CGRectMake(0.0, 10.0, cellWidth, 20.0)];
			button.tag = section;
			button.hidden = NO;
			[button setBackgroundColor:[UIColor clearColor]];
			[button	setTitle:@"Add report" forState:UIControlStateNormal];
			[button addTarget:self action:@selector(addReport:) forControlEvents:UIControlEventTouchDown];
			[myView addSubview:button];
		
			return myView;
			
	}else{
			return nil;
	}
}


- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	
	switch (tableView.tag) {
		case 2:
			return 40.0;
			break;
			
		default:
			return nil;
			break;
	}
	
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
	}
	
	if (tableView.tag == 0)
	{
			NSString *stepName = [steps objectAtIndex:indexPath.row];
			cell.textLabel.text = stepName;
	}
	else if (tableView.tag == 1)
	{
		if (infParts)
		{
			cell.textLabel.text = [[infParts objectAtIndex:indexPath.row]objectAtIndex:1];
			
			if ([[[infParts objectAtIndex:indexPath.row]objectAtIndex:2] isEqualToString:@"hidden"])
				cell.textLabel.textColor = [UIColor lightGrayColor];
			else
				cell.textLabel.textColor = [UIColor blackColor];
			
			
			
		}
	
	}
	else if (tableView.tag == 2)
	{
    
		cell.textLabel.text = [reportsArray objectAtIndex:indexPath.row];
		
	}
	
	if (indexPath.row == 0)
		[tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	//Celle holen
	//UITableViewCell *cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
	
	if (tableView.tag == 0)
	{
		if (currentStepRow == -1)
			[self jumpToStep:0];
		else
			[self jumpToStep:indexPath.row];


	}else if (tableView.tag == 2)
	{
		NSString* repName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
		
		//Get step in XML
		TBXMLElement *rep = [TBXMLFunctions getElement:reports ByName:repName];
		
		if ([TBXMLFunctions getValue:@"step" OfElement:rep].integerValue == currentStepRow)//wir sind im gleichen Step
		{
			[self loadReportNamed:repName]; //nur den Step laden
		}else{
			//Zum neuen Workstep springen
			[self jumpToStep: [TBXMLFunctions getValue:@"step" OfElement:rep].integerValue];
		}
		
		
		
		
	}
	
}




- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 2)
		return YES;
	else
		return NO;
	
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 2 && editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSString* delReportNamed = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
		
		for (int arrayCounter = 0; arrayCounter < addedReportsArray.count; ++arrayCounter)
		{
			NSMutableArray* elementArray = [addedReportsArray objectAtIndex:arrayCounter];
		
			if ([[elementArray objectAtIndex:0] isEqualToString:delReportNamed] )
			{
				[self deleteReport:[elementArray objectAtIndex:1]];
				[addedReportsArray removeObjectAtIndex:arrayCounter];
				[self jumpToStep:currentStepRow];
				[reportsTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:false scrollPosition:UITableViewScrollPositionTop];
				break;
			}
			

			
		}
    }
}



#pragma mark -
#pragma mark Report Actions
#pragma mark -

- (IBAction)showReportPictureFull:(id)sender
{
	
	UIImageView* repImgView;
	
	if ([repImgScrollView subviews].count > 0) {
		repImgView = [[repImgScrollView subviews]objectAtIndex:0];
	}else{
		repImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, repImgScrollView.frame.size.width, repImgScrollView.frame.size.height)];
		repImgView.contentMode = UIViewContentModeScaleAspectFit;
		[repImgView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)];
		[repImgScrollView addSubview:repImgView];
		
		[repImgScrollView setUserInteractionEnabled:YES];
		UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeFullScreenReportImage:)];
		[singleTap setNumberOfTapsRequired:1];
		[repImgScrollView addGestureRecognizer:singleTap];
		
		[repImgScrollView setUserInteractionEnabled:YES];
		UITapGestureRecognizer *doubleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetScaleForScrollView:)];
		[doubleTap setNumberOfTapsRequired:2];
		[repImgScrollView addGestureRecognizer:doubleTap];
		
		[singleTap requireGestureRecognizerToFail:doubleTap];
		
		
		[repImgScrollView setMaximumZoomScale:10.0];
		[repImgScrollView setMinimumZoomScale:1.0];
		repImgScrollView.delegate=self;
	}
	
	[repImgView setImage:[reportPictureBto backgroundImageForState:UIControlStateNormal]];
	[repImgScrollView setZoomScale:1.0];
	
	[delegate addView:repImgScrollView to:true withAnimations:true];
}

-(IBAction)closeFullScreenReportImage:(id)sender
{

	[delegate addView:repImgScrollView to:false withAnimations:true];
	
}

-(IBAction)resetScaleForScrollView:(id)sender
{
	[repImgScrollView	setZoomScale:1.00 animated:true];

}

-(void) loadReportNamed:(NSString*)reportName
{

	//Get step in XML
	TBXMLElement *rep = [TBXMLFunctions getElement:reports ByName:reportName];
	
	//Namen des Steps bekommen
	NSInteger stepInt = [TBXMLFunctions getValue:@"step" OfElement:rep].intValue;
	NSIndexPath *stepInd = [NSIndexPath indexPathForRow: stepInt inSection:0];
	NSString* stepN = [stepsTable cellForRowAtIndexPath:stepInd].textLabel.text ;
	
	
	
	//Get Description
	NSString* descriptionTextStr = [NSString stringWithFormat:@"Date : %@\r", [TBXMLFunctions getAttribute:@"date" OfElement:rep]];
	descriptionTextStr = [descriptionTextStr stringByAppendingString:[NSString stringWithFormat:@"User : %@\r",[TBXMLFunctions getAttribute:@"user" OfElement:rep]]];
	descriptionTextStr = [descriptionTextStr stringByAppendingString:[NSString stringWithFormat:@"Affects : %@\r\r",stepN]];
	descriptionTextStr = [descriptionTextStr stringByAppendingString:[NSString stringWithFormat:@"%@",[TBXMLFunctions getValue:@"description" OfElement:rep]]];
					   
	[reportTextView setText:descriptionTextStr];
	
	NSString* reportImg = [TBXMLFunctions getValue:@"pic" OfElement:rep];
	if ([reportImg isEqualToString:@""]){
		[reportPictureBto setHidden:true];

		[reportPictureBto setBackgroundImage:nil
                            forState:UIControlStateNormal];
	}else{
		[reportPictureBto setHidden:false];
		//Bild holen
		NSString *workinstructionsPath =  [NSString stringWithFormat:@"%@/%@",documentsDir,@"workinstructions"];
		NSString* reportImgStr = [NSString stringWithFormat:@"%@/%@",workinstructionsPath,reportImg];
		UIImage* reportImg = [[UIImage alloc] initWithContentsOfFile:reportImgStr];
		[reportPictureBto setBackgroundImage:reportImg
									forState:UIControlStateNormal];
	}
		
	
	
	





}

-(void) deleteReport:(NSString*)delString
{

	//daten aus xml einlesen und als nsstring speichern
	NSString *workinstructionsPath =  [NSString stringWithFormat:@"%@/%@",documentsDir,@"workinstructions"];
	
	NSString *xmlPath =  [NSString stringWithFormat:@"%@/%@",workinstructionsPath,@"reports.xml"];
	
	NSString *reportXMLSring = [NSString stringWithContentsOfFile:xmlPath
													 usedEncoding:nil
															error:nil];
	if (reportXMLSring)
	{

		reportXMLSring = [reportXMLSring stringByReplacingOccurrencesOfString:delString withString:[NSString stringWithFormat:@""]];
		
		
		//schreiben der XML
		[reportXMLSring writeToFile:xmlPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
		
		//Daten neu einlesen
		[self loadReports];
		[reportsTable reloadData];
				
		
	}
}

-(IBAction)saveReport:(id)sender
{
	
	//Daten aus der View holen
	NSString *tDate = dateLable.text;
	NSString *tUser = userLable.text;
	NSString *tStep = [NSString	stringWithFormat:@"%i",currentStepRow];
	NSString *tName = reportNameField.text;
	if ([tName isEqualToString:@""])
		tName = tDate;
		
	NSString *tDescription = descriptionText.text;
	if ([tDescription rangeOfString:@"Report description"].location != NSNotFound) {
		tDescription = @"";
	}
	
	//Bild holen und ablegen
	NSString* tPic = @"";
	NSData *pngData = UIImagePNGRepresentation(screenshotView.image);
	if (screenshotView.image)
	{
		tPic = [NSString stringWithFormat:@"%@.png",tDate];
		tPic = [tPic stringByReplacingOccurrencesOfString:@" "
												 withString:@"_"];
		tPic = [tPic stringByReplacingOccurrencesOfString:@"/"
												 withString:@""];
		tPic = [tPic stringByReplacingOccurrencesOfString:@":"
											   withString:@""];
		
	}
			
	//daten aus xml einlesen und als nsstring speichern
	NSString *workinstructionsPath =  [NSString stringWithFormat:@"%@/%@",documentsDir,@"workinstructions"];
	
	NSString *xmlPath =  [NSString stringWithFormat:@"%@/%@",workinstructionsPath,@"reports.xml"];
	
	NSString *reportXMLSring = [NSString stringWithContentsOfFile:xmlPath
											   usedEncoding:nil
													  error:nil];
	if (reportXMLSring)
	{
		
		if (pngData)
		{
			NSString* pngPath = [NSString stringWithFormat:@"%@/%@",workinstructionsPath,tPic];
			[pngData writeToFile:pngPath atomically:YES]; //Write the file
		}
		
		
		NSString* newReport = [NSString stringWithFormat:@"\t<report name=\"%@\" date=\"%@\" user=\"%@\">\r", tName, tDate, tUser];
		newReport = [newReport stringByAppendingString:[NSString stringWithFormat:@"\t\t<description>%@</description>\r",tDescription]];
		newReport = [newReport stringByAppendingString:[NSString stringWithFormat:@"\t\t<pic>%@</pic>\r",tPic]];
		newReport = [newReport stringByAppendingString:[NSString stringWithFormat:@"\t\t<step>%@</step>\r",tStep]];
		newReport = [newReport stringByAppendingString:[NSString stringWithFormat:@"\t</report>\r"]];
			
		reportXMLSring = [reportXMLSring stringByReplacingOccurrencesOfString:@"</reports>" withString:[NSString stringWithFormat:@"%@\r</reports>",newReport]];
			
			//zwischenspeichern was eingefügt wurde ume es evl wieder löschen zu können
			NSMutableArray* addReportArray = [[NSMutableArray alloc]init];
			[addReportArray addObject:tName];
			[addReportArray addObject:newReport];
			[addedReportsArray addObject:addReportArray];

		
		
		//schreiben der XML
		[reportXMLSring writeToFile:xmlPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

		
		//Leeren
			//Placeholder für das Description Text Feld
			[descriptionText setText:@"Report description...."];
			
			//Titel leeren
			[reportNameField setText:@""];
			
			//Image
			[screenshotView setImage:nil];
			
			
		
		[delegate addView:reportAddView to:false withAnimations:true];
			
		//Daten neu einlesen
		[self loadReports];
			
		//Load Reports for this step
		[reportsArray removeAllObjects];
		if (tStep.integerValue == 0)
			[TBXMLFunctions getAllChilds:reports toArray:reportsArray];
		else
			[TBXMLFunctions	getAllChilds:reports forValueNamed:@"step" withValue:tStep toArray:reportsArray];
		
		//Step auswählen
		[self loadReportNamed: [reportsArray objectAtIndex:[reportsArray count]-1] ];
		[reportsTable reloadData];
		[reportsTable deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:false];
		[reportsTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:([reportsArray count]-1) inSection:0] animated:false scrollPosition:UITableViewScrollPositionBottom];
		
	}

}

-(IBAction)addReport:(id)sender
{
	
	//Zeit holen
	NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
	[inFormat setDateFormat:@"dd/MM/yy hh:mm:ss"];
	NSString *time = [inFormat stringFromDate:[NSDate date]];
	[dateLable setText:time];
	
	//User holen
	NSString *user = [NSString stringWithFormat:@"Matthias Neges"];
	[userLable setText:user];
	
	//Step holen
	NSInteger currentRow;
	if (currentStepRow < 0)
		currentRow	= 0;
	else
		currentRow = currentStepRow;
		
	
	UITableViewCell* currentCell = [stepsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:0]];
	NSString *stepName = [NSString stringWithFormat:@"%@",currentCell.textLabel.text];
	[stepLable setText:stepName];
	
	//Placeholder für das Description Text Feld
	[descriptionText setText:@"Report description...."];
	
	[delegate addView:reportAddView to:true withAnimations:true];
	[reportNameField becomeFirstResponder];
	 descriptionText.delegate = self;
	
	
	
	
}
-(IBAction)cancelReport:(id)sender
{

	//Placeholder für das Description Text Feld
	[descriptionText setText:@"Report description...."];
	[reportNameField setText:@""];
	[screenshotView setImage:nil];
	
	[delegate addView:reportAddView to:false withAnimations:true];

}



#pragma mark -
#pragma mark Sceenshots
#pragma mark -

-(IBAction)addScreenshot:(id)sender
{
	//alles ausblenden
	[delegate removeWorkView:true];
	[reportAddView setHidden:true];
	[reportAddView endEditing:true];
	
	//screenshotleiste einblenden
	[delegate addView:screenshotTakeView to:true withAnimations:false];
	[screenshotTakeView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)];
	
	

}


- (IBAction)takeScreenshot:(id)sender
{

	[delegate getScreenshotFromMetaio];
		
}

- (IBAction)take5sScreenshot:(id)sender
{
	timerValue = 5;
	[timerLabel setHidden:false];
	[timerLabel setText:[NSString stringWithFormat:@"%i", timerValue]];
	
	screenshotTimer = [NSTimer    scheduledTimerWithTimeInterval:1.0    target:self    selector:@selector(timerForScreenshot)    userInfo:nil repeats:YES];
	
}

- (void)timerForScreenshot
{
	timerValue = timerValue - 1;
	
	[timerLabel setText:[NSString stringWithFormat:@"%i", timerValue]];

	if (timerValue == 0)
	{
		[screenshotTimer invalidate];
		screenshotTimer = nil;
		
		[delegate getScreenshotFromMetaio];
		
		[timerLabel setHidden:true];
	}

}


-(void)requestCameraImage:(UIImage*)requestedImage
{

	[screenShotPreviewView setImage:requestedImage];
	[screenShotPreviewView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)];
	
	//screenshotleiste einblenden
	[delegate addView:screenshotTakeView to:false withAnimations:false];
	[delegate addView:screenshotUseView to:true withAnimations:false];


}


- (IBAction)useScreenshot:(id)sender
{
	
	//Bild übertragen
	[screenshotView setImage:screenShotPreviewView.image];
	
	//alles ausblenden
	[delegate removeWorkView:false];
	[reportAddView setHidden:false];
	[reportAddView endEditing:false];
	
	//screenshotleiste einblenden
	[delegate addView:screenshotTakeView to:false withAnimations:false];
	[delegate addView:screenshotUseView to:false withAnimations:false];
	
	
	
	
}
- (IBAction)retryScreenshot:(id)sender
{
	
	[screenShotPreviewView setImage:nil];
	
	//screenshotleiste einblenden
	[delegate addView:screenshotTakeView to:true withAnimations:false];
	[delegate addView:screenshotUseView to:false withAnimations:false];
	
	
	
}


- (IBAction)screenshotCancel:(id)sender
{
	
	//alles ausblenden
	[delegate removeWorkView:false];
	[reportAddView setHidden:false];
	[reportAddView endEditing:false];
	
	//screenshotleiste einblenden
	[delegate addView:screenshotTakeView to:false withAnimations:false];
	[delegate addView:screenshotUseView to:false withAnimations:false];
}

- (IBAction)virtualModeChange:(id)sender
{
	
	[delegate setObjectToInvisibleCos];
	
	UIButton* tempBTO = sender;
	
	if ([tempBTO.titleLabel.text isEqualToString:@"virtual ON"])
		[tempBTO setTitle:@"virtual OFF" forState:UIControlStateNormal];
	else
		[tempBTO setTitle:@"virtual ON" forState:UIControlStateNormal];
		
	
}

#pragma mark -
#pragma mark Scroll View Delegates
#pragma mark -

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [[scrollView subviews]objectAtIndex:0];
}


#pragma mark -
#pragma mark Text View Delegates
#pragma mark -

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.text = @"";
}



#pragma mark -
#pragma mark Step Actions
#pragma mark -

-(void)loadStep:(NSString*)stepName
{

	//Get step in XML
	TBXMLElement *step = [TBXMLFunctions getElement:maintenance ByName:stepName];
	
	
	//Get Description
	[descriptionTextView setText:[TBXMLFunctions getValue:@"description" OfElement:step]];
	
	
	//Get infected parts
	if (!infParts)
		infParts = [[NSMutableArray alloc]init];
		
		if (currentStepRow == 0 )
			infParts = [TBXMLFunctions getAllInfectedObjectsForWorkInstruction:step];
		else
			infParts = [TBXMLFunctions getAllTableViewSubElements:step];
	
	int PartsCounter;
	NSMutableArray* highlightedParts = [[NSMutableArray alloc]init];
	[hiddenParts removeAllObjects];
	
	for (PartsCounter = 0; PartsCounter < [infParts count]; ++PartsCounter)
	{
		if ([[[infParts objectAtIndex:PartsCounter]objectAtIndex:2]isEqualToString:@"highlighted"])
			[highlightedParts addObject:[[infParts objectAtIndex:PartsCounter]objectAtIndex:1]];
		else if ([[[infParts objectAtIndex:PartsCounter]objectAtIndex:2]isEqualToString:@"hidden"])
			[hiddenParts addObject:[[infParts objectAtIndex:PartsCounter]objectAtIndex:1]];
	}
	
	
	//Highlight der Parts
	if ([highlightedParts count]> 0)
		[delegate select3dContentWithName:[highlightedParts objectAtIndex:0] withUIColor:@"red" toGroup:false withObjects:highlightedParts ];
	else
		[delegate select3dContentWithName:nil withUIColor:@"red" toGroup:false withObjects:nil ];
	
	
		
	//Hidden/Zeigen der Parts
	for (PartsCounter = 0; PartsCounter < [hiddenParts count]; ++PartsCounter)
	{
		[delegate setModelWithName: [hiddenParts objectAtIndex:PartsCounter] visible:false];
		[delegate saveInXMLforObjectName:[hiddenParts objectAtIndex:PartsCounter] toAttribute:@"visible" withValue:(char*)"false"];
	
	}
	
	//structerView neu laden
	[delegate reloadStructerTable];
	
	
	//infected Parts Table neu laden
	[partsTable reloadData];
	
	//schon mal den neuen Step in die view für das anlegen ienes neuen reports setzt, fals diese schon offen ist
	[stepLable setText:stepName];
	



}

-(void)jumpToStep:(NSInteger) stepRow
{
	
	//exit if not possible
	if (stepRow == [stepsTable numberOfRowsInSection:0] || stepRow < 0) {
		return;
	}
	
	
	do {
		NSString* nextStepName;
		NSIndexPath* nextIndexPath;
		
		if (currentStepRow < stepRow) {
			
			nextIndexPath = [NSIndexPath indexPathForRow:(currentStepRow + 1) inSection:0];
			currentStepRow = currentStepRow + 1;
			
		}else if (currentStepRow > stepRow) {
			
			nextIndexPath = [NSIndexPath indexPathForRow:(currentStepRow - 1) inSection:0];
			currentStepRow = currentStepRow - 1;
			
			//ausgeblendete Elemente wieder herstellen
			
			//Hidden/Zeigen der Parts
			int PartsCounter;
			for (PartsCounter = 0; PartsCounter < [hiddenParts count]; ++PartsCounter)
			{
				[delegate setModelWithName: [hiddenParts objectAtIndex:PartsCounter] visible:true];
				[delegate saveInXMLforObjectName:[hiddenParts objectAtIndex:PartsCounter] toAttribute:@"visible" withValue:(char*)"true"];
				
			}
			
		}else{
			nextIndexPath = [NSIndexPath indexPathForRow:(currentStepRow) inSection:0];
		}
		
		
		//Get name of the next/previous step
		nextStepName = [stepsTable cellForRowAtIndexPath:nextIndexPath].textLabel.text;
		
		//load step
		[self loadStep:nextStepName];
		
		//select step
		[stepsTable selectRowAtIndexPath:nextIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
		
		
		//Load Reports for this step
		[reportsArray removeAllObjects];
		if (nextIndexPath.row == 0) //Start also alle
			[TBXMLFunctions getAllChilds:reports toArray:reportsArray];
		else //Step als nur die gültigen für diesen step
			[TBXMLFunctions	getAllChilds:reports forValueNamed:@"step" withValue:[NSString stringWithFormat:@"%i",nextIndexPath.row] toArray:reportsArray];
		
		if ([reportsArray count] != 0)
			[self loadReportNamed: [reportsArray objectAtIndex:0] ];
		
		[reportsTable reloadData];
			
		
		
		
	} while (currentStepRow != stepRow);
	
	
}

#pragma mark -
#pragma mark next/prev Buttons
#pragma mark -
			 

- (IBAction)nextTableCell:(id)sender
{
	if (reportTextView.isHidden) //next Step
		[self jumpToStep:currentStepRow + 1];
	else //next Report
	{
		if ([reportsArray count] == 0)
			return;
		
		NSInteger toRow = [reportsTable indexPathForSelectedRow].row + 1;
		
		if (toRow == [reportsArray count])
			return;
		
		
		NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow: toRow inSection:0];
		
		[reportsTable selectRowAtIndexPath:newIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
		
		[self loadReportNamed:[reportsArray objectAtIndex:toRow]];
	
	}
	
}



- (IBAction)prevTableCell:(id)sender
{
	if (reportTextView.isHidden) //next Step
		[self jumpToStep:currentStepRow -1];
	else //next Report
	{
		if ([reportsArray count] == 0)
			return;
		
		NSInteger toRow = [reportsTable indexPathForSelectedRow].row - 1;
		
		if (toRow < 0)
			return;
		
		NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow: toRow inSection:0];
		
		[reportsTable selectRowAtIndexPath:newIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
		
		[self loadReportNamed:[reportsArray objectAtIndex:toRow]];
		
	}
}










#pragma mark -
#pragma mark change work/report
#pragma mark -


-(void)changeToReport:(bool)change
{

	if (change)
	{
		[descriptionTextView setHidden:true];
		[reportTextView setHidden:false];
		
		[reportsTable setHidden:false];
		[partsTable setHidden:true];
		
		
	}
	else
	{
		[descriptionTextView setHidden:false];
		[reportTextView setHidden:true];
		
		[reportsTable setHidden:true];
		[partsTable setHidden:false];
		[reportPictureBto setHidden:true];
		
	}



}

@end
