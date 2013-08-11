//
//  CNAppDelegate.m
//  CNSplitView Example
//
//  Created by Frank Gregor on 03.01.13.
//  Copyright (c) 2013 cocoa:naut. All rights reserved.
//

#import "CNAppDelegate.h"

static NSUInteger attachedSubViewIndex = 0;

@interface CNAppDelegate () {
    CNSplitViewToolbar *toolbarTop;
    CNSplitViewToolbar *toolbarBottom;
    CNSplitViewToolbar *secondaryToolbarTop;
    CNSplitViewToolbar *secondaryToolbarBottom;
    BOOL useAnimations;
}
@end

@implementation CNAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.secondView.text = @"A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart.";
    self.secondView.textBoxWidth = 380;
    self.secondView.icon = [NSImage imageNamed:@"SplitLeaf-Icon"];
    self.secondView.iconVerticalOffset = 70;
    
    useAnimations = NO;
    toolbarTop = [[CNSplitViewToolbar alloc] init];
    toolbarTop.itemDelimiterEnabled = NO;
    toolbarBottom = [[CNSplitViewToolbar alloc] init];
    
    secondaryToolbarTop = [[CNSplitViewToolbar alloc] init];
    secondaryToolbarBottom = [[CNSplitViewToolbar alloc] init];
    secondaryToolbarBottom.itemDelimiterEnabled= NO;

    NSMenu *contextMenu = [[NSMenu alloc] init];
    [contextMenu addItemWithTitle:@"Add new Item" action:@selector(contextMenuItemSelection:) keyEquivalent:@""];
    [contextMenu addItemWithTitle:@"Add new Group" action:@selector(contextMenuItemSelection:) keyEquivalent:@""];
    CNSplitViewToolbarButton *button1 = [[CNSplitViewToolbarButton alloc] initWithContextMenu:contextMenu];
    button1.imageTemplate = CNSplitViewToolbarButtonImageTemplateAdd;
    
    CNSplitViewToolbarButton *button2 = [[CNSplitViewToolbarButton alloc] init];
    button2.imageTemplate = CNSplitViewToolbarButtonImageTemplateRemove;
    
    CNSplitViewToolbarButton *button3 = [[CNSplitViewToolbarButton alloc] init];
    button3.imageTemplate = CNSplitViewToolbarButtonImageTemplateLockUnlocked;
    button3.imagePosition = NSImageRight;
    button3.title = @"Lock";
    
    CNSplitViewToolbarButton *button4 = [[CNSplitViewToolbarButton alloc] init];
    button4.imageTemplate = CNSplitViewToolbarButtonImageTemplateRefresh;
    button4.title = @"Refresh";
    
    
    NSSearchField *searchField = [[NSSearchField alloc] initWithFrame:NSMakeRect(0, 0, 200, 16)];
    [searchField setToolbarItemWidth:200];
    [searchField.cell setControlSize:NSMiniControlSize];
    
    NSTextField *textField = [[NSTextField alloc] init];
    [textField setBordered:NO];
    [textField setDrawsBackground:NO];
    [textField setToolbarItemWidth:80.0];
    textField.stringValue = @"hello";
    [textField setEditable:NO];
    [textField setAlignment:NSRightTextAlignment];
    [textField.cell setControlSize:NSSmallControlSize];
    
    NSPopUpButton *popupButton = [[NSPopUpButton alloc] init];
    [popupButton setToolbarItemWidth:120];
    [popupButton addItemsWithTitles:@[ @"Foo...", @"Bar...", @"Yelly" ]];
    [[popupButton cell] setControlSize:NSSmallControlSize];
    
    NSSlider *slider = [[NSSlider alloc] init];
    [slider setToolbarItemWidth:100.0];
    [[slider cell] setControlSize:NSSmallControlSize];
    
    
    [toolbarTop addItem:popupButton align:CNSplitViewToolbarItemAlignLeft];
    [toolbarTop addItem:searchField align:CNSplitViewToolbarItemAlignRight];
    
    [secondaryToolbarBottom addItem:slider align:CNSplitViewToolbarItemAlignRight];

    
    [toolbarBottom addItem:button1 align:CNSplitViewToolbarItemAlignLeft];
    [toolbarBottom addItem:button2 align:CNSplitViewToolbarItemAlignLeft];
    [toolbarBottom addItem:button3 align:CNSplitViewToolbarItemAlignRight];
    [toolbarBottom addItem:button4 align:CNSplitViewToolbarItemAlignRight];
    
    self.splitView.delegate = self;
    self.splitView.toolbarDelegate = self;
    [self.splitView attachToolbar:toolbarTop toSubViewAtIndex:attachedSubViewIndex onEdge:CNSplitViewToolbarEdgeTop];
    [self.splitView attachToolbar:toolbarBottom toSubViewAtIndex:attachedSubViewIndex onEdge:CNSplitViewToolbarEdgeBottom];
    [self.splitView attachToolbar:secondaryToolbarTop toSubViewAtIndex:1 onEdge:CNSplitViewToolbarEdgeTop];
    [self.splitView attachToolbar:secondaryToolbarBottom toSubViewAtIndex:1 onEdge:CNSplitViewToolbarEdgeBottom];
    
}

- (void)awakeFromNib
{
}

- (void)contextMenuItemSelection:(id)sender
{
    CNLog(@"selected menu item: %@", [(NSMenuItem *)sender title]);
}

- (IBAction)showHideToolbarAction:(id)sender
{
    if ([(NSButton *)sender state] == NSOnState) {
        
        [self.splitView showHideToolbarsAnimated:useAnimations show:YES forSubViewAtIndex:attachedSubViewIndex];
        [self.splitView showHideToolbarsAnimated:useAnimations show:YES forSubViewAtIndex:1];
        //        [self.splitView showToolbarAnimated:useAnimations forToolbar:toolbar];
        //        [self.splitView showToolbarAnimated:useAnimations forToolbar:toolbar2];
    } else {
        
        [self.splitView showHideToolbarsAnimated:useAnimations show:NO forSubViewAtIndex:attachedSubViewIndex];
        [self.splitView showHideToolbarsAnimated:useAnimations show:NO forSubViewAtIndex:1];
        
   }
}

- (IBAction)useAnimationsAction:(id)sender
{
    if ([(NSButton *)sender state] == NSOnState)    useAnimations = YES;
    else                                            useAnimations = NO;
}

- (IBAction)enableDisableToolbarItemsAction:(id)sender
{
    if ([(NSButton *)sender state] == NSOnState)    {[toolbarTop disable]; [toolbarBottom disable];}
    
    else                                            {[toolbarTop enable]; [toolbarBottom enable];}
}

- (IBAction)enableDisableToolbarItemsDelimiterAction:(id)sender
{
    if ([(NSButton *)sender state] == NSOnState)    toolbarTop.itemDelimiterEnabled = NO;
    else                                            toolbarTop.itemDelimiterEnabled = YES;
}

- (IBAction)centerToolbarItemsAction:(id)sender
{
    if ([(NSButton *)sender state] == NSOnState)    toolbarTop.contentAlign = CNSplitViewToolbarContentAlignCentered;
    else                                            toolbarTop.contentAlign = CNSplitViewToolbarContentAlignItemDirected;
}

- (IBAction)draggingHandleEnabledAction:(id)sender
{
    if ([(NSButton *)sender state] == NSOnState)    [self.splitView setDraggingHandleEnabledForToolbar:toolbarTop enabled:YES];
    else                                            [self.splitView setDraggingHandleEnabledForToolbar:toolbarTop enabled:NO];
}

- (IBAction)splitViewOrientationAction:(id)sender
{
    switch ([self.splitViewOrientationPopUp indexOfSelectedItem]) {
        case CNSplitViewDeviderOrientationVertical: {
            [self.splitView setVertical:YES];
            break;
        }
        case CNSplitViewDeviderOrientationHorizontal: {
            [self.splitView setVertical:NO];
            break;
        }
    }
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
    return 180;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
    return [[[self window] contentView] bounds].size.width - 180;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CNSplitViewToolbar Delegate

- (NSUInteger)toolbarAttachedSubviewIndex:(CNSplitViewToolbar *)theToolbar
{
    return attachedSubViewIndex;
}

- (void)splitView:(CNSplitView *)theSplitView willShowToolbar:(CNSplitViewToolbar *)theToolbar onEdge:(CNSplitViewToolbarEdge)theEdge
{
    NSLog(@"splitView:willShowToolbar:onEdge:");
}

- (void)splitView:(CNSplitView *)theSplitView didShowToolbar:(CNSplitViewToolbar *)theToolbar onEdge:(CNSplitViewToolbarEdge)theEdge
{
    NSLog(@"splitView:didShowToolbar:onEdge:");
}

- (void)splitView:(CNSplitView *)theSplitView willHideToolbar:(CNSplitViewToolbar *)theToolbar onEdge:(CNSplitViewToolbarEdge)theEdge
{
    NSLog(@"splitView:willHideToolbar:onEdge:");
}

- (void)splitView:(CNSplitView *)theSplitView didHideToolbar:(CNSplitViewToolbar *)theToolbar onEdge:(CNSplitViewToolbarEdge)theEdge
{
    NSLog(@"splitView:didHideToolbar:onEdge:");
}

@end
