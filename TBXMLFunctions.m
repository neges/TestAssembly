//
//  TBXMLFunctions.m
//  Template
//
//  Created by Mac on 25.10.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import "TBXMLFunctions.h"

@implementation TBXMLFunctions


#pragma mark -
#pragma mark tbxml Methodes
#pragma mark -

+(TBXMLElement*) getElement:(TBXMLElement*)element
					 ByName:(NSString*) elementName
{
	
	do{
		
		
		TBXMLAttribute *attribute = element->firstAttribute;
		
		while (attribute)
		{
			if ([[TBXML attributeValue:attribute] isEqualToString:elementName])
			{
				return element;
			}
			
			attribute = attribute->next;
			
		}
		
		if (element->firstChild)
		{
			TBXMLElement* tempElement = [self getElement:element->firstChild ByName:elementName];
			if (tempElement) {
				return tempElement;
			}
		}
		
		
	}while ((element = element->nextSibling));
	
	return nil;
	
	
}

+(void)getAllElements:(TBXMLElement*)element
{
	
	
	do{
		
		
		if (element->firstAttribute)
		{
			
			TBXMLAttribute *attribute = element->firstAttribute;
			
			while (attribute)
			{
				//NSLog(@"%@ : %@ = %@", [TBXML elementName:element], [TBXML attributeName:attribute], [TBXML attributeValue:attribute]);
				
				NSLog(@"%@ = %@", [TBXML elementName:element], [TBXML attributeValue:attribute]);
				
				attribute = attribute->next;
				
			}
			
		}
		
		if (element->firstChild)
		{
			[self getAllElements:element->firstChild];
		}
		
		
	}while ((element = element->nextSibling));
	
}

+(void)getAllElements:(TBXMLElement*)element
		   withGroups:(bool)wGroups
			  toArray:(NSMutableArray *)elementArray
{
	
	
	do
	{
		
		if (element->firstAttribute)
		{
		
			TBXMLAttribute *attribute = element->firstAttribute;
			
			while (attribute)
			{
				if (wGroups) {
					[elementArray addObject: [TBXML attributeValue:attribute]];
					
				}else{
					if (!element->firstChild)
					{
						[elementArray addObject: [TBXML attributeValue:attribute]];
					}
					
					
				}
				//NSLog(@"%@ : %@ = %@", [TBXML elementName:element], [TBXML attributeName:attribute], [TBXML attributeValue:attribute]);
				
				attribute = attribute->next;
				
			}
			
		}
		
		if (element->firstChild)
		{
			[self getAllElements:element->firstChild withGroups:wGroups toArray:elementArray];
		}
		
		
	}while ((element = element->nextSibling));
	
}


+(NSString*)getNameOfElement:(TBXMLElement*)element
{
	
	do {
		
		TBXMLAttribute *attribute = element->firstAttribute;
		
		if ([[TBXML attributeName:attribute] isEqualToString:@"name"])
		{
			return [TBXML attributeValue:attribute];
		}
		
		attribute = attribute->next;
	}
	
	while (element->nextSibling);
	
	return @"";
	
}

+(NSString*)getTypeOfElement:(TBXMLElement*)element
{
	
	return [TBXML elementName:element];
	
}








#pragma mark -
#pragma mark save
#pragma mark -

-(void)getLogAllElements:(TBXMLElement*) rootElement
{
	
	if (rootElement)
	{
		//[self getXMLElements:rootElement];
		
		NSString* searchName = @"screws_FRONT";
		
		
		TBXMLElement* foundedElement = [TBXMLFunctions getElement:rootElement ByName:searchName];
		if (foundedElement) {
			TBXMLAttribute *attribute = foundedElement->firstAttribute;
			NSLog(@"%@ = %@", [TBXML elementName:foundedElement], [TBXML attributeValue:attribute]);
			
			
			
			NSLog(@"----------Childs------------");
			if (foundedElement->firstChild)
				[self getLogAllElements:foundedElement->firstChild];
			else
				NSLog(@"none");
			
			
			
			NSLog(@"----------Parent------------");
			if (foundedElement->parentElement)
			{
				TBXMLElement* elementParent = foundedElement->parentElement;
				if (foundedElement) {
					TBXMLAttribute *attribute = elementParent->firstAttribute;
					NSLog(@"%@ = %@", [TBXML elementName:elementParent], [TBXML attributeValue:attribute]);
				}
			}else
				NSLog(@"none");
			
			
		}else
			NSLog(@"This element does not exists");
		
		
	}
}

@end
