/*
 * TNToolbar.j
 *
 * Copyright (C) 2010 Antoine Mercadal <antoine.mercadal@inframonde.eu>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "TNAvatarManager.j";

/*! @global
    @group TNToolBarItem
    identifier for item logout
*/
TNToolBarItemLogout         = @"TNToolBarItemLogout";


/*! @global
    @group TNToolBarItem
    identifier for item help
*/
TNToolBarItemHelp           = @"TNToolBarItemHelp";

/*! @global
    @group TNToolBarItem
    identifier for item status
*/
TNToolBarItemStatus             = @"TNToolBarItemStatus";

TNToolBarItemAvatar             = @"TNToolBarItemAvatar";

/*! @ingroup archipelcore
    subclass of CPToolbar that allow dynamic insertion. This is used by TNModuleLoader
*/
@implementation TNToolbar  : CPToolbar
{
    CPDictionary    _toolbarItems;
    CPDictionary    _toolbarItemsOrder;
    CPArray         _sortedToolbarItems;
}

/*! initialize the class with a target
    @param aTarget the target
    @return a initialized instance of TNToolbar
*/
-(id)initWithTarget:(id)aTarget
{
    if (self = [super init])
    {
        var bundle          = [CPBundle bundleForClass:self];
        _toolbarItems       = [CPDictionary dictionary];
        _toolbarItemsOrder  = [CPDictionary dictionary];

        [self addItemWithIdentifier:TNToolBarItemLogout label:@"Log out" icon:[bundle pathForResource:@"logout.png"] target:aTarget action:@selector(toolbarItemLogoutClick:)];
        [self addItemWithIdentifier:TNToolBarItemHelp label:@"Help" icon:[bundle pathForResource:@"help.png"] target:aTarget action:@selector(toolbarItemHelpClick:)];
        
        var statusSelector = [[CPPopUpButton alloc] initWithFrame:CGRectMake(8.0, 8.0, 120.0, 24.0)];

        var availableItem = [[CPMenuItem alloc] init];
        [availableItem setTitle:TNArchipelStatusAvailableLabel];
        [availableItem setImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"Available.png"]]];
        [statusSelector addItem:availableItem];
        
        var awayItem = [[CPMenuItem alloc] init];
        [awayItem setTitle:TNArchipelStatusAwayLabel];
        [awayItem setImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"Away.png"]]];
        [statusSelector addItem:awayItem];
        
        var busyItem = [[CPMenuItem alloc] init];
        [busyItem setTitle:TNArchipelStatusBusyLabel];
        [busyItem setImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"Busy.png"]]];
        [statusSelector addItem:busyItem];
        
        var statusItem = [self addItemWithIdentifier:TNToolBarItemStatus label:@"Status" view:statusSelector target:aTarget action:@selector(toolbarItemPresenceStatusClick:)];
        [statusItem setMinSize:CGSizeMake(120.0, 24.0)];
        [statusItem setMaxSize:CGSizeMake(120.0, 24.0)];
        
        var avatarSelector = [[TNAvatarManager alloc] initWithFrame:CGRectMake(0.0, 0.0, 32.0, 32.0)];
        [avatarSelector setImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"user-unknown.png"]]];

        var avatarItem = [self addItemWithIdentifier:TNToolBarItemAvatar label:@"Avatar" view:avatarSelector target:nil action:nil];
        [avatarItem setMinSize:CGSizeMake(32.0, 32.0)];
        [avatarItem setMaxSize:CGSizeMake(32.0, 32.0)];
        
        [_toolbarItemsOrder setObject:TNToolBarItemStatus forKey:0];
        [_toolbarItemsOrder setObject:CPToolbarSeparatorItemIdentifier forKey:1];

        [_toolbarItemsOrder setObject:CPToolbarFlexibleSpaceItemIdentifier forKey:500];
        [_toolbarItemsOrder setObject:CPToolbarSeparatorItemIdentifier forKey:901];
        [_toolbarItemsOrder setObject:TNToolBarItemHelp forKey:902];
        [_toolbarItemsOrder setObject:TNToolBarItemLogout forKey:903];
        
        //[self setPosition:0 forToolbarItemIdentifier:TNToolBarItemStatus];
        //[self setPosition:1 forToolbarItemIdentifier:CPToolbarSeparatorItemIdentifier];
        //[self setPosition:900 forToolbarItemIdentifier:CPToolbarFlexibleSpaceItemIdentifier];
        //[self setPosition:901 forToolbarItemIdentifier:CPToolbarSeparatorItemIdentifier];
        //[self setPosition:902 forToolbarItemIdentifier:TNToolBarItemHelp];
        //[self setPosition:903 forToolbarItemIdentifier:TNToolBarItemLogout];
        
        [self setDelegate:self];
    }

    return self;
}

/*! add a new CPToolbarItem
    @param anIdentifier CPString containing the identifier
    @param aLabel CPString containing the label
    @param anImage CPImage containing the icon of the item
    @param aTarget an object that will be the target of the item
    @param anAction a selector of the aTarget to perform on click
*/
- (void)addItemWithIdentifier:(CPString)anIdentifier label:(CPString)aLabel icon:(CPImage)anImage target:(id)aTarget action:(SEL)anAction
{
    var newItem = [[CPToolbarItem alloc] initWithItemIdentifier:anIdentifier];

    [newItem setLabel:aLabel];
    [newItem setImage:[[CPImage alloc] initWithContentsOfFile:anImage size:CPSizeMake(32,32)]];
    [newItem setTarget:aTarget];
    [newItem setAction:anAction];

    [_toolbarItems setObject:newItem forKey:anIdentifier];
}

- (void)addItem:(CPToolbarItem)anItem withIdentifier:(CPString)anIdentifier
{
    [_toolbarItems setObject:anItem forKey:anIdentifier];
}

- (void)_reloadToolbarItems
{
    var sortedKeys = [[_toolbarItemsOrder allKeys] sortedArrayUsingFunction:function(a, b, context){
        var indexA = a;
        var indexB = b;
        if (a < b)
                return CPOrderedAscending;
            else if (a > b)
                return CPOrderedDescending;
            else
                return CPOrderedSame;
    }];
    
    _sortedToolbarItems = [CPArray array];
    for (var i = 0; i < [sortedKeys count]; i++)
    {
        var key = [sortedKeys objectAtIndex:i];
        [_sortedToolbarItems addObject:[_toolbarItemsOrder objectForKey:key]];
    }
    
    [super _reloadToolbarItems];
}


/*! add a new CPToolbarItem with a custom view
    @param anIdentifier CPString containing the identifier
    @param aLabel CPString containing the label
    @param anImage CPImage containing the icon of the item
    @param aTarget an object that will be the target of the item
    @param anAction a selector of the aTarget to perform on click
*/
- (CPToolbarItem)addItemWithIdentifier:(CPString)anIdentifier label:(CPString)aLabel view:(CPView)aView target:(id)aTarget action:(SEL)anAction
{
    var newItem = [[CPToolbarItem alloc] initWithItemIdentifier:anIdentifier];
    
    //[newItem setMinSize:CGSizeMake(120.0, 24.0)];
    //[newItem setMaxSize:CGSizeMake(120.0, 24.0)]
            
    [newItem setLabel:aLabel];
    [newItem setView:aView];
    [newItem setTarget:aTarget];
    [newItem setAction:anAction];

    [_toolbarItems setObject:newItem forKey:anIdentifier];
    
    return newItem
}

/*! define the position of a given existing CPToolbarItem according to its identifier
    @param anIndentifier CPString containing the identifier
*/
- (void)setPosition:(CPNumber)aPosition forToolbarItemIdentifier:(CPString)anIndentifier
{
    
    [_toolbarItemsOrder setObject:anIndentifier forKey:aPosition];
}

/*! CPToolbar Protocol
*/
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
    return  _sortedToolbarItems;
}

/*! CPToolbar Protocol
*/
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
    return  _sortedToolbarItems;
}

/*! CPToolbar Protocol
*/
- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];

    return ([_toolbarItems objectForKey:anItemIdentifier]) ? [_toolbarItems objectForKey:anItemIdentifier] : toolbarItem;
}


@end