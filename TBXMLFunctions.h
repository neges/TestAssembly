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


+(NSString*)getNameOfElement:(TBXMLElement*)element;


+(NSString*)getTypeOfElement:(TBXMLElement*)element;


@end
