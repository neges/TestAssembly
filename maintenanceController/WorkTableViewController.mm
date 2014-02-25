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
@synthesize addingReport;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
	{
		
		reportAddView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [super view].frame.size.width, [super view].frame.size.height)];
		screenshotTakeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , [super view].frame.size.width, [super view].frame.size.height)];
		screenshotUseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , [super view].frame.size.width, [super view].frame.size.height)];
		infectedPartSelected = [[NSString alloc]initWithFormat:@""];
		
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
	
	//Name der WO anzeigen
	[nameTextView setText:[TBXMLFunctions getAttribute:@"name" OfElement:maintenance]];
	//Schriftgröße korrigieren
	[nameTextView setFont:[UIFont boldSystemFontOfSize:17]];
	

	steps = [[NSMutableArray alloc]init];
	[TBXMLFunctions getAllChilds:maintenance toArray:steps];
	
	hiddenParts = [[NSMutableArray alloc]init];
	
	[self loadStep:[steps objectAtIndex:0]];


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
	
	if (!reportsArray)
		reportsArray = [[NSMutableArray alloc]init];
	
	if (!infectedPartsArray)
		infectedPartsArray = [[NSMutableArray alloc]init];
	
	//Alle Elemente mit Reports suchen und ablegen für die Structure View
	if (!reportsElementsArray)
		reportsElementsArray = [[NSMutableArray alloc]init];
	
	
	//alle Reports holen
	[reportsArray removeAllObjects];
	[TBXMLFunctions getAllChilds:reports toArray:reportsArray];
	
	for (int a = 0; a < [reportsArray count]; ++a )
	{
		NSMutableArray* tempReports = [[NSMutableArray alloc]init];
		
		TBXMLElement* reportTBXMLElement = [TBXMLFunctions getElement:reports ByName:[reportsArray objectAtIndex:a]];
		
		tempReports = [TBXMLFunctions	getValues:@"object" OfElement:reportTBXMLElement];
				
		for (int aa = 0; aa < [tempReports count]; ++aa )
		{
			NSMutableArray* temp = [[NSMutableArray alloc]init];
			[temp addObject:[tempReports objectAtIndex:aa]];
			[temp addObject:[reportsArray objectAtIndex:a]];
			[reportsElementsArray addObject:temp];
		}
		
	}
	
	[delegate getReportsForElements:reportsElementsArray];
		

}

-(void)loadReportForStep:(NSInteger)loadedStep
{
	
	[reportsArray removeAllObjects];
	if (loadedStep == 0)
		[TBXMLFunctions getAllChilds:reports toArray:reportsArray];
	else
		[TBXMLFunctions	getAllChilds:reports forValueNamed:@"step" withValue:[NSString stringWithFormat:@"%i",loadedStep] toArray:reportsArray];
	reportsArray = [[[reportsArray reverseObjectEnumerator] allObjects]mutableCopy]; //invertieren sodass neuster Report zu beginn
	
	[reportsTable reloadData];
	
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
			
		case 2:
			return [reportsArray count];
			break;
			
		case 4:
			return [infectedPartsArray count];
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
			
		case 2:
			return [NSString stringWithFormat:@"reports - %i", [reportsArray count] ];
			break;
			
		default:
			return nil;
			break;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
		if (tableView.tag == 4)
			{
						CGFloat cellWidth = tableView.frame.size.width;
			
						UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cellWidth, 40.0)];
						[myView setBackgroundColor:[UIColor lightGrayColor]];
			
						UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
						[button setFrame:CGRectMake(0.0, 0.0, 100, 40.0)];
						button.hidden = NO;
						[button setBackgroundColor:[UIColor clearColor]];
						[button	setTitle:@"add" forState:UIControlStateNormal];
						[button addTarget:self action:@selector(addInfectedPart) forControlEvents:UIControlEventTouchDown];
						[myView addSubview:button];
				
				
						UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
						[button2 setFrame:CGRectMake(cellWidth - 100.0, 0.0, 100, 40.0)];
						button2.hidden = NO;
						[button2 setBackgroundColor:[UIColor clearColor]];
						[button2	setTitle:@"close" forState:UIControlStateNormal];
						[button2 addTarget:self action:@selector(exitInfectedPartsSelection) forControlEvents:UIControlEventTouchDown];
						[myView addSubview:button2];
			
						return myView;
						
				}else
							return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	return nil;
}



-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	
	if (tableView.tag == 4)
		return 40;
	else
		return 28;
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
			cell.textLabel.text = [steps objectAtIndex:indexPath.row];
		//selektieren des Start steps
		if (indexPath.row == 0)
		{
			[tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
			[self loadStep:[steps objectAtIndex:indexPath.row]];
			[self loadReportForStep:0];
		}
		
	}
	else if (tableView.tag == 2)
	{
		cell.textLabel.text = [reportsArray objectAtIndex:indexPath.row];
	}
	else if (tableView.tag == 4)
	{
		cell.textLabel.text = [infectedPartsArray objectAtIndex:indexPath.row];
		if ([infectedPartsArray count] - 1 == indexPath.row)
			[tableView setEditing: YES animated: YES];
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	//Celle holen
	//UITableViewCell *cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
	
	if (tableView.tag == 0)
	{
		[self jumpToStep:indexPath.row];

	}else if (tableView.tag == 2)
	{
		NSString* repName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
		
		[self loadReportNamed:repName]; //nur den Step laden
				
		//sicherstellen das das richtige Texfeld sichbar ist
		[descriptionTextView setHidden:true];
		[reportTextView	setHidden:false];
		
	}
	
}




- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 2 || tableView.tag == 4)
		return YES;
	else
		return NO;
	
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (tableView.tag == 2 && editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSString* delReportNamed = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
		
		bool previouslyAdded = false;
		
		for (int arrayCounter = 0; arrayCounter < addedReportsArray.count; ++arrayCounter)
		{
			NSMutableArray* elementArray = [addedReportsArray objectAtIndex:arrayCounter];
		
			if ([[elementArray objectAtIndex:0] isEqualToString:delReportNamed] )
			{
				//delete report aus xml
				[self deleteReport:[elementArray objectAtIndex:1]];
				
				//delete objet aus dem added reports array
				[addedReportsArray removeObjectAtIndex:arrayCounter];
				
				previouslyAdded = true;
				
				break;
			}
				
		}
		
		if (previouslyAdded == false)
		{
			
			delIndexPathRow = indexPath.row;
			
			UIAlertView *alert = [[UIAlertView alloc] init];
			[alert setTitle:@"Confirm deletion"];
			[alert setMessage:@"You don't have the required access rights to delete this report!"];
			[alert setDelegate:self];
			[alert addButtonWithTitle:@"delete"];
			[alert addButtonWithTitle:@"cancel"];
			[alert show];
			
			
			
			
		}
			
		
    }
	else if (tableView.tag == 4 && editingStyle == UITableViewCellEditingStyleDelete) //infected Parts Table
	{
		[infectedPartsArray removeObjectAtIndex:indexPath.row];
		[infectedPartsTable reloadData];
	}
}

#pragma mark -
#pragma mark Alert Actions
#pragma mark -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)//delete report aus xml
		[self deleteReport:[self getXMLReportBlockByReportName:[reportsArray objectAtIndex:delIndexPathRow]]];
	else //edit zurücksetzen
		[reportsTable setEditing:false];
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
	
	[delegate addView:repImgScrollView to:true withAnimationsFrom:@"top"];
}

-(IBAction)closeFullScreenReportImage:(id)sender
{

	[delegate addView:repImgScrollView to:false withAnimationsFrom:@"top"];
	
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
	
	
	//relatedParts holen
	infectedPartsArray = [TBXMLFunctions getValues:@"object" OfElement:rep];
	if ([infectedPartsArray count] > 0)
	{
		descriptionTextStr = [descriptionTextStr stringByAppendingString:[NSString stringWithFormat:@"\r\rRelated parts:\r"]];
		for (int p = 0; p < [infectedPartsArray count] ; ++p)
		{
			descriptionTextStr = [descriptionTextStr stringByAppendingString:[NSString stringWithFormat:@"- %@\r", [infectedPartsArray objectAtIndex:p ]]];
		}
	}
	
	
					   
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
	
	//Schriftgröße korrigieren
	[reportTextView setFont:[UIFont systemFontOfSize:17]];
		
	
	
	





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

		reportXMLSring = [reportXMLSring stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",delString] withString:[NSString stringWithFormat:@""]];
		
		
		//schreiben der XML
		[reportXMLSring writeToFile:xmlPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
		
		//Daten neu einlesen
		[self loadReports];
		
		//Load Reports for this step
		[self loadReportForStep:currentStepRow];

		
				
		
	}
}

-(NSString*) getXMLReportBlockByReportName:(NSString*)tName
{
	//daten aus xml einlesen und als nsstring speichern
	NSString *workinstructionsPath =  [NSString stringWithFormat:@"%@/%@",documentsDir,@"workinstructions"];
	
	NSString *xmlPath =  [NSString stringWithFormat:@"%@/%@",workinstructionsPath,@"reports.xml"];
	
	NSString *reportXMLSring = [NSString stringWithContentsOfFile:xmlPath
													 usedEncoding:nil
															error:nil];
	if (reportXMLSring)
	{
		
		NSString* beginnLine = [NSString stringWithFormat:@"\t<report name=\"%@\" date", tName];
		NSString* endLine = [NSString stringWithFormat:@"</report>"];
		
		NSString* delBlock;
		
		
		NSRange startRange = [reportXMLSring rangeOfString:beginnLine];
		if (startRange.location != NSNotFound) {
			NSRange targetRange;
			targetRange.location = startRange.location + startRange.length;
			targetRange.length = [reportXMLSring length] - targetRange.location;
			NSRange endRange = [reportXMLSring rangeOfString:endLine options:0 range:targetRange];
			if (endRange.location != NSNotFound) {
				targetRange.length = endRange.location - targetRange.location;
				delBlock = [reportXMLSring substringWithRange:targetRange];
				
				delBlock = [NSString stringWithFormat:@"%@%@%@\r",beginnLine,delBlock,endLine];
			}
		}
		
		if (delBlock)
			return  delBlock;
		
	}
	
	return nil;
	
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
		for (int p = 0; p < [infectedPartsArray count]; ++p)
		{
			newReport = [newReport stringByAppendingString:[NSString stringWithFormat:@"\t\t<object>%@</object>\r",[infectedPartsArray objectAtIndex:p]]];
		}
		
		
		newReport = [newReport stringByAppendingString:[NSString stringWithFormat:@"\t</report>\r"]];
			
		reportXMLSring = [reportXMLSring stringByReplacingOccurrencesOfString:@"</reports>" withString:[NSString stringWithFormat:@"%@</reports>",newReport]];
			
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
			
			
		
		[delegate addView:reportAddView to:false withAnimationsFrom:@"top"];
			
		//Daten neu einlesen
		[self loadReports];
			
		//Load Reports for this step
		[self loadReportForStep:currentStepRow];
		
		//Step auswählen
		[self loadReportNamed: [reportsArray objectAtIndex:[reportsArray count]-1] ];
		[reportsTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:false scrollPosition:UITableViewScrollPositionTop];
		
	}
	
	addingReport = false;

}

-(void)addNewReport
{
	addingReport = true;
	
	
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
	
	//related parts leeren
	[infectedPartsArray removeAllObjects];
	[infectedPartsBto setTitle:@"none (click to add)" forState:UIControlStateNormal];
	[infectedPartsTable reloadData];
	
	
	//View laden
	[delegate addView:reportAddView to:true withAnimationsFrom:@"top"];
	[reportNameField becomeFirstResponder];
	 descriptionText.delegate = self;
	

		
}
-(IBAction)cancelReport:(id)sender
{

	//Placeholder für das Description Text Feld
	[descriptionText setText:@"Report description...."];
	[reportNameField setText:@""];
	[screenshotView setImage:nil];
	
	[delegate addView:reportAddView to:false withAnimationsFrom:@"top"];
	
	addingReport = false;

}

#pragma mark -
#pragma mark Reports for Element
#pragma mark -

- (void)getReportsForElementNamed:(NSString*)repElementName
{
	if (!reportsElementsArray)
		return;
	
	[reportsArray removeAllObjects];
	
	for (int ren = 0; ren < [reportsElementsArray count]; ++ren)
	{
		if ([[[reportsElementsArray objectAtIndex:ren]objectAtIndex:0] isEqualToString:repElementName])
		{
			[reportsArray addObject:[[reportsElementsArray objectAtIndex:ren]objectAtIndex:1]];
		}
	}
	
	[reportsTable reloadData];
	
	[delegate selectTabBarItem:0];
	[delegate slideTabBarIn:true];
	
	
	if ([reportsArray count] == 0)
		return;
	
	[reportsTable selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:false scrollPosition:UITableViewScrollPositionTop];
	[self loadReportNamed:[reportsArray objectAtIndex:0] ];
	[descriptionTextView setHidden:true];
	[stepsTable deselectRowAtIndexPath:[NSIndexPath indexPathForItem:currentStepRow inSection:0] animated:false];

}




#pragma mark -
#pragma mark Infected Parts
#pragma mark -

- (IBAction)addInfectedPartsToReport:(id)sender
{
	
	//Table setzten
	[infectedPartsTable setFrame:CGRectMake(1024-260, 480, 260, 288)];
	[delegate addView:infectedPartsTable to:true withAnimationsFrom:@"right"];
		
	
	//alles ausblenden
	[delegate removeWorkView:true];
	[reportAddView setHidden:true];
	[reportAddView endEditing:true];
	
	//structureview einblenden
	[delegate slideTableIn:true];
	
}

-(IBAction)exitInfectedPartsSelection
{
	
	//Table setzten
	[delegate addView:infectedPartsTable to:false withAnimationsFrom:@"right"];
	
	//structureview einblenden
	[delegate slideTableIn:false];
	
	
	//alles einsblenden
	[delegate removeWorkView:false];
	[reportAddView setHidden:false];
	[reportAddView endEditing:false];
	
	if ([infectedPartsArray count] == 0)
		[infectedPartsBto setTitle:@"none (click to add)" forState:UIControlStateNormal];
	else if ([infectedPartsArray count] == 1)
		[infectedPartsBto setTitle:[NSString stringWithFormat:@"%@ (click to edit)",[infectedPartsArray objectAtIndex:0]]  forState:UIControlStateNormal];
	else
		[infectedPartsBto setTitle:[NSString stringWithFormat:@"%i selected (click to edit)",[infectedPartsArray count]] forState:UIControlStateNormal];
	
	
}
-(IBAction)addInfectedPart
{
	if (![infectedPartSelected isEqualToString:@""] && infectedPartSelected)
	{
		
		if (![infectedPartsArray containsObject: infectedPartSelected])
		{
			[infectedPartsArray addObject:infectedPartSelected];
			[infectedPartsTable reloadData];
		}
		
	}
	
	
}

- (void)getSelectedElement:(NSString*)selectedElement
{
	infectedPartSelected = selectedElement;
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
	[delegate addView:screenshotTakeView to:true withAnimationsFrom:@"bottom"];
	[screenshotTakeView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)];
	
	

}


- (IBAction)takeScreenshot:(id)sender
{
	if (![infectedPartSelected isEqualToString:@""])
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
	[delegate addView:screenshotTakeView to:false withAnimationsFrom:@"bottom"];
	[delegate addView:screenshotUseView to:true withAnimationsFrom:@"bottom"];


}


- (IBAction)useScreenshot:(id)sender
{
	
	//Bild übertragen
	[screenshotView setImage:screenShotPreviewView.image];
	
	//alles einblenden
	[delegate removeWorkView:false];
	[reportAddView setHidden:false];
	[reportAddView endEditing:false];
	
	//screenshotleiste ausblenden
	[delegate addView:screenshotTakeView to:false withAnimationsFrom:@"bottom"];
	[delegate addView:screenshotUseView to:false withAnimationsFrom:@"bottom"];
	
	
	
	
}
- (IBAction)retryScreenshot:(id)sender
{
	
	[screenShotPreviewView setImage:nil];
	
	//screenshotleiste einblenden
	[delegate addView:screenshotTakeView to:true withAnimationsFrom:@"bottom"];
	[delegate addView:screenshotUseView to:false withAnimationsFrom:@"bottom"];
	
	
	
}


- (IBAction)screenshotCancel:(id)sender
{
	
	//alles einblenden
	[delegate removeWorkView:false];
	[reportAddView setHidden:false];
	[reportAddView endEditing:false];
	
	//screenshotleiste einblenden
	[delegate addView:screenshotTakeView to:false withAnimationsFrom:@"bottom"];
	[delegate addView:screenshotUseView to:false withAnimationsFrom:@"bottom"];
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
	
	//Schriftgröße korrigieren
	[descriptionTextView setFont:[UIFont systemFontOfSize:17]];
	

	
	//schon mal den neuen Step in die view für das anlegen ienes neuen reports setzt, fals diese schon offen ist
	[stepLable setText:stepName];
	



}

-(void)jumpToStep:(NSInteger) stepRow
{
	
	//sicherstellen das das richtige Texfeld sichbar ist
	[descriptionTextView setHidden:false];
	[delegate slideTableIn:false];
	
	//exit if not possible
	if (stepRow == [stepsTable numberOfRowsInSection:0] || stepRow < 0) {
		return;
	}
	
	NSIndexPath* nextIndexPath;
	
	do {
		NSString* nextStepName;
		
		
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
		
	
	} while (currentStepRow != stepRow);
	
	//select step
	nextIndexPath = [NSIndexPath indexPathForRow:(currentStepRow) inSection:0];
	[stepsTable selectRowAtIndexPath:nextIndexPath animated:true scrollPosition:UITableViewScrollPositionMiddle];
	
	
	//Load Reports for this step
	[self loadReportForStep:currentStepRow];
	
	
}

#pragma mark -
#pragma mark next/prev Buttons
#pragma mark -
			 

- (IBAction)nextTableCell:(id)sender
{
	[self jumpToStep:currentStepRow + 1];
}



- (IBAction)prevTableCell:(id)sender
{
	[self jumpToStep:currentStepRow -1];
}


@end
