/*
 * TNLibvirtDeviceHostDevSourceAddress.j
 *
 * Copyright (C) 2010  Antoine Mercadal <antoine.mercadal@inframonde.eu>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

@import <Foundation/Foundation.j>
@import <StropheCappuccino/TNXMLNode.j>

@import "TNLibvirtBase.j"


/*! @ingroup virtualmachinedefinition
    Model for hostdev's source address
*/
@implementation TNLibvirtDeviceHostDevSourceAddress : TNLibvirtBase
{
    CPString _bus       @accessors(property=bus);
    CPString _slot      @accessors(property=slot);
    CPString _function  @accessors(property=function);
}


#pragma mark -
#pragma mark Initialization

/*! initialize the object with a given XML node
    @param aNode the node to use
*/
- (id)initWithXMLNode:(TNXMLNode)aNode
{
    if (self = [super initWithXMLNode:aNode])
    {
        if ([aNode name] != @"address")
            [CPException raise:@"XML not valid" reason:@"The TNXMLNode provided is not a valid hostdev source address"];

        _bus = [aNode valueForAttribute:@"bus"];
        _slot = [aNode valueForAttribute:@"slot"];
        _function = [aNode valueForAttribute:@"function"];
    }

    return self;
}


#pragma mark -
#pragma mark Generation

/*! return a TNXMLNode representing the object
    @return TNXMLNode
*/
- (TNXMLNode)XMLNode
{
    var node = [TNXMLNode nodeWithName:@"address"];

    if (_bus)
        [node setValue:_bus forAttribute:@"bus"];
    if (_slot)
        [node setValue:_slot forAttribute:@"slot"];
    if (_function)
        [node setValue:_function forAttribute:@"function"];

    return node;
}

@end