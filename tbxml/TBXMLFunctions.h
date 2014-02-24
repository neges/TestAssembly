//
//  TBXMLFunctions.h
//  Template
//
//  Created by Mac on 25.10.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import "TBXML.h"

@interface TBXMLFunctions : TBXML


+(TBXMLElement*) getElement:(TBXMLElement*)element
					 ByName:(NSString*) elementName;


+(void)getAllElements:(TBXMLElement*)element;

+(void)getAllElements:(TBXMLElement*)element
		   withGroups:(bool)wGroups
			  toArray:(NSMutableArray *)elementArray;

+(void)getAllChilds:(TBXMLElement*)element
			toArray:(NSMutableArray *)elementArray;

+(void)getAllChilds:(TBXMLElement*)element
	  forValueNamed:(NSString*)valueNamed
		  withValue:(NSString*)value
			toArray:(NSMutableArray *)elementArray;

+(NSString*)getValue:(NSString*)value
		   OfElement:(TBXMLElement*)element;

+(NSMutableArray*)getValues:(NSString*)value
				  OfElement:(TBXMLElement*)element;


+(NSString*)getAttribute:(NSString*)attrib
			   OfElement:(TBXMLElement*)element;


+(NSString*)getTypeOfElement:(TBXMLElement*)element;

+(NSMutableArray*)getAllParentElementsFrom:(TBXMLElement*)element;
+(NSMutableArray *)getAllTableViewSubElements:(TBXMLElement*)element;
+(NSMutableArray*)getAllInfectedObjectsForWorkInstruction:(TBXMLElement*)topElement;


+(bool)saveAttributForName:(NSString*)aName
				 withValue:(char*)aValue
				 toElement:(TBXMLElement*)aElement;


@end
