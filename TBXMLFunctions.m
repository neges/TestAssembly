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
                    if ([[TBXML attributeName:attribute] isEqualToString:@"name"])
                    {
                        [elementArray addObject: [TBXML attributeValue:attribute]];
                    }
					
				}else{
					if (!element->firstChild)
					{
                        if ([[TBXML attributeName:attribute] isEqualToString:@"name"])
                        {
                            [elementArray addObject: [TBXML attributeValue:attribute]];
                        }
                        
						
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

+(NSMutableArray*)getAllTableViewSubElements:(TBXMLElement*)topElement
{

    NSMutableArray* elementArray = [[NSMutableArray alloc]init];
    
    if (!topElement->firstChild)
        return elementArray;
    
    
    //Eigenschaften der Unterobjekte holen
    TBXMLElement* element = topElement->firstChild;
    
        do
        {
            NSMutableArray* tempArray = [[NSMutableArray alloc]init];
			
            if (element->firstAttribute)
            {
                
                
                TBXMLAttribute *attribute = element->firstAttribute;
                
                
                
                [tempArray addObject:[TBXML elementName:element]];
                
                
                while (attribute)
                {
                    
					[tempArray addObject:[TBXML attributeValue:attribute]];
                    
                    
                    attribute = attribute->next;
                    
                }
                
                [elementArray addObject: tempArray];
                
            }
            
            
        }while ((element = element->nextSibling));
	
		
	 return elementArray;
	
}


+(NSString*)getAttribute:(NSString*)attrib
			   OfElement:(TBXMLElement*)element
{
	if (!element)
		return @"";
	
	if (!element->firstAttribute)
		return @"";
	
	TBXMLAttribute *attribute = element->firstAttribute;
	
	while (attribute)
	{
		
		if ([[TBXML attributeName:attribute] isEqualToString:attrib])
		{
			return [TBXML attributeValue:attribute];
		}
		
		attribute = attribute->next;
	}
	
	return @"";
	
}

+(NSString*)getTypeOfElement:(TBXMLElement*)element
{
	
	return [TBXML elementName:element];
	
}

+(NSMutableArray*)getAllParentElementsFrom:(TBXMLElement*)element

{
	NSMutableArray* elementArray = [[NSMutableArray alloc]init];
	
	
	TBXMLElement *tempElement = element;
	
	if (tempElement) {
		
            NSMutableArray* tempArray = [[NSMutableArray alloc]init];
			
            if (tempElement->firstAttribute)
            {
                
                
                TBXMLAttribute *attribute = tempElement->firstAttribute;
                
                
                
                [tempArray addObject:[TBXML elementName:tempElement]];
                
                
                while (attribute)
                {
                    
					[tempArray addObject:[TBXML attributeValue:attribute]];
                    
                    
                    attribute = attribute->next;
                    
                }
                
                [elementArray addObject: tempArray];
                
            }
        
		
		while (tempElement->parentElement)
		{
			
			tempElement = tempElement->parentElement;
			
			NSMutableArray* tempArray = [[NSMutableArray alloc]init];
			
			if (tempElement->firstAttribute)
			{
				
				
				TBXMLAttribute *attribute = tempElement->firstAttribute;
				
				
				
				[tempArray addObject:[TBXML elementName:tempElement]];
				
				
				while (attribute)
				{
					
					[tempArray addObject:[TBXML attributeValue:attribute]];
					
					
					attribute = attribute->next;
					
				}
				
				[elementArray addObject: tempArray];
				
			}
				
						
		}
		
	}
	
	NSMutableArray* reversedArray = [[NSMutableArray alloc] initWithArray:[[[[NSArray alloc] initWithArray: elementArray] reverseObjectEnumerator] allObjects]];
	
	return reversedArray;
	
	
	
}








#pragma mark -
#pragma mark save in tbxml
#pragma mark -


+(bool)saveAttributForName:(NSString*)aName
				 withValue:(char*) aValue
				 toElement:(TBXMLElement*)aElement
{


	TBXMLAttribute *attribute = aElement->firstAttribute;
	
	while (attribute)
	{
		
		if ([[TBXML attributeName:attribute] isEqualToString:aName])
		{
			
			attribute->value = aValue;
			
			return true;
		}
		
		attribute = attribute->next;
	}
	
	return false;




	return true;

}



#pragma mark -
#pragma mark archiv
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
