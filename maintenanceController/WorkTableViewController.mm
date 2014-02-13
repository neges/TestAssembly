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
    if (self) {
		
	  }
	
    return self;
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
	workXML = [TBXML newTBXMLWithXMLString:theContents error:nil];
	maintenance = workXML.rootXMLElement;
	
	NSString* maintenanceName = [TBXMLFunctions getAttribute:@"name" OfElement:maintenance];
	[nameTextView setText:maintenanceName];
	
	
	if (!workXML) {
		NSLog(@"No structur file could be found or structur file is incorrect : %@", xmlPath);
		return;
	};
	

	steps = [[NSMutableArray alloc]init];
	[TBXMLFunctions getAllSteps:maintenance toArray:steps];
	
	currentStepRow = -1;
	
	

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView.tag == 0)
	{
		[self loadWorkInstructionForXML];
		
		return [steps count];
	}
	else
	{
		if (infParts)
			return [infParts count];
		else
			return 0;
	}
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

	switch (tableView.tag) {
		case 0:
			return @"steps";
			break;
			
		case 1:
			return @"infected parts";
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
	else
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


	}
	
}








#pragma mark -
#pragma mark Step Actions
#pragma mark -

-(void)loadStep:(NSString*)stepName
{

	//Get step in XML
	TBXMLElement *step = [TBXMLFunctions getElement:maintenance ByName:stepName];
	
	
	//Get Description
	[descriptionTextView setText:[TBXMLFunctions getDescriptionOfStep:step]];
	
	
	//Get infected parts
	if (!infParts)
		infParts = [[NSMutableArray alloc]init];
		
		if (currentStepRow == 0 )
			infParts = [TBXMLFunctions getAllInfectedObjectsForWorkInstruction:step];
		else
			infParts = [TBXMLFunctions getAllTableViewSubElements:step];
	
	int infPartsCounter;
	NSMutableArray* highlightedParts = [[NSMutableArray alloc]init];
	
	for (infPartsCounter = 0; infPartsCounter < [infParts count]; ++infPartsCounter) {
		if ([[[infParts objectAtIndex:infPartsCounter]objectAtIndex:2]isEqualToString:@"highlighted"])
		{
			[highlightedParts addObject:[[infParts objectAtIndex:infPartsCounter]objectAtIndex:1]];
		}
	}
	
	if ([highlightedParts count]> 0)
		[delegate select3dContentWithName:[highlightedParts objectAtIndex:0] withUIColor:@"red" toGroup:false withObjects:highlightedParts ];
	else
		[delegate select3dContentWithName:nil withUIColor:@"red" toGroup:false withObjects:nil ];
	
	[partsTable reloadData];
	



}
			 

- (IBAction)nextStep:(id)sender
{
	[self jumpToStep:currentStepRow + 1];
}



- (IBAction)prevStep:(id)sender
{
	[self jumpToStep:currentStepRow - 1];
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



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
