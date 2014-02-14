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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
	{

	  }

	
    return self;
}

-(void)loadContent
{

	[self loadWorkInstructionForXML];
	[self loadReports];
	
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
	NSString *objectFolderPath = [[NSBundle mainBundle] pathForResource:@"Assets" ofType:nil];
	
	NSString *workinstructionsPath =  [NSString stringWithFormat:@"%@/%@",objectFolderPath,@"workinstructions"];
	
	NSString *xmlPath =  [NSString stringWithFormat:@"%@/%@",workinstructionsPath,@"work_20131113.xml"];
	
	//xml laden falls vorhanden
	NSString* theContents = [[NSString alloc] initWithContentsOfFile:xmlPath encoding:NSUTF8StringEncoding error:nil];
	TBXML* workXML = [TBXML newTBXMLWithXMLString:theContents error:nil];
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

	NSString *objectFolderPath = [[NSBundle mainBundle] pathForResource:@"Assets" ofType:nil];
	
	NSString *workinstructionsPath =  [NSString stringWithFormat:@"%@/%@",objectFolderPath,@"workinstructions"];
	
	NSString *xmlPath =  [NSString stringWithFormat:@"%@/%@",workinstructionsPath,@"reports.xml"];
	
	//xml laden falls vorhanden
	NSString* theContents = [[NSString alloc] initWithContentsOfFile:xmlPath encoding:NSUTF8StringEncoding error:nil];
	TBXML* reportsXML = [TBXML newTBXMLWithXMLString:theContents error:nil];
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
		
		
		//Get Description
		[reportTextView setText:[TBXMLFunctions getValue:@"description" OfElement:rep]];
		
		[self jumpToStep: [TBXMLFunctions getValue:@"step" OfElement:rep].integerValue];
		
		
		
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
        [reportsArray removeObjectAtIndex:indexPath.row];
		[reportsTable reloadData];
    }
}



#pragma mark -
#pragma mark Report Actions
#pragma mark -

-(IBAction)saveReport:(id)sender
{
	if (saveBto.isHidden)
		return;
	
	NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
	[inFormat setDateFormat:@"hh:mm:ss_dd-MM-yy"];
	NSString *time = [inFormat stringFromDate:[NSDate date]];
		
	NSMutableArray* newReport = [[NSMutableArray alloc]init];
	
	[newReport addObject:[NSString stringWithFormat:@"R_%@", time]];
	[newReport addObject:[NSString stringWithFormat:@"TEST"]];
	[newReport addObject:[NSString stringWithFormat:@"%i",currentStepRow]];
	
	NSLog(@"Save : %i", currentStepRow);
	
	[reportsArray addObject:newReport];
	[reportsTable reloadData];

}

-(IBAction)addScreenshot:(id)sender
{

	if (screenBto.isHidden)
		return;



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
	



}
			 

- (IBAction)nextStep:(id)sender
{
	if (nextStepBto.isHidden)
		return;
	
	[self jumpToStep:currentStepRow + 1];
	
}



- (IBAction)prevStep:(id)sender
{
	if (prevStepBto.isHidden)
		return;
	
	[self jumpToStep:currentStepRow - 1];
}


-(void)jumpToStep:(NSInteger) stepRow
{
	NSLog(@"Jump to step: %i", stepRow);
	
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
		
		
		
	} while (currentStepRow != stepRow);
	
		
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
		[nextStepBto setHidden:true];
		[prevStepBto setHidden:true];

		[saveBto setHidden:false];
		[screenBto setHidden:false];
		
		
		[reportsTable setHidden:false];
		[partsTable setHidden:true];
		
		
	}
	else
	{
		[descriptionTextView setHidden:false];
		[reportTextView setHidden:true];
		[nextStepBto setHidden:false];
		[prevStepBto setHidden:false];
		[saveBto setHidden:true];
		[screenBto setHidden:true];
	
		
		[reportsTable setHidden:true];
		[partsTable setHidden:false];
	}



}

@end
