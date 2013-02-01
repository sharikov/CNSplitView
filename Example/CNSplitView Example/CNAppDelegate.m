//
//  CNAppDelegate.m
//  CNSplitView Example
//
//  Created by Frank Gregor on 03.01.13.
//  Copyright (c) 2013 cocoa:naut. All rights reserved.
//

#import "CNAppDelegate.h"
#import "CNSplitViewToolbar.h"
#import "CNSplitViewToolbarButton.h"
#import "CNSplitViewDefinitions.h"


@interface CNAppDelegate () {
    CNSplitViewToolbar *toolbar;
}
@end

@implementation CNAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.secondView.text = @"A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart.";
    self.secondView.textBoxWidth = 380;
    self.secondView.icon = [NSImage imageNamed:@"SplitLeaf-Icon"];
    self.secondView.iconVerticalOffset = 70;

    toolbar = [[CNSplitViewToolbar alloc] init];

    CNSplitViewToolbarButton *button1 = [[CNSplitViewToolbarButton alloc] init];
    button1.toolbarButtonImage = CNSplitViewToolbarButtonImageAdd;
    button1.keyEquivalent = @"n";
    button1.keyEquivalentModifierMask = NSCommandKeyMask;

    CNSplitViewToolbarButton *button2 = [[CNSplitViewToolbarButton alloc] init];
    button2.toolbarButtonImage = CNSplitViewToolbarButtonImageRemove;

    CNSplitViewToolbarButton *button3 = [[CNSplitViewToolbarButton alloc] init];
    button3.toolbarButtonAlign = CNSplitViewToolbarButtonAlignRight;
    button3.toolbarButtonImage = CNSplitViewToolbarButtonImageLockUnlocked;
    button3.imagePosition = NSImageRight;
    button3.title = @"Lock";

    CNSplitViewToolbarButton *button4 = [[CNSplitViewToolbarButton alloc] init];
    button4.toolbarButtonAlign = CNSplitViewToolbarButtonAlignRight;
    button4.toolbarButtonImage = CNSplitViewToolbarButtonImageRefresh;
    button4.title = @"Refresh";

    [toolbar addButton:button1];
    [toolbar addButton:button2];
    [toolbar addButton:button3];
    [toolbar addButton:button4];

    self.splitView.delegate = self;
    [self.splitView setVertical:YES];
    [self.splitView addToolbar:toolbar besidesSubviewAtIndex:0 onEdge:CNSplitViewToolbarEdgeBottom];
}

- (IBAction)showHideToolbarAction:(id)sender
{
    NSNumber *visibility;
    if ([(NSButton *)sender state] == NSOnState)    visibility = [NSNumber numberWithInteger:CNSplitViewToolbarVisibilityVisible];
    else                                            visibility = [NSNumber numberWithInteger:CNSplitViewToolbarVisibilityHidden];
    [[NSNotificationCenter defaultCenter] postNotificationName:CNSplitViewShowHideToolbarNotification object:visibility];
}

- (IBAction)enableDisableToolbarItemsAction:(id)sender
{
    if ([(NSButton *)sender state] == NSOnState)    [toolbar disable];
    else                                            [toolbar enable];
}

- (IBAction)enableDisableToolbarItemsDelimiterAction:(id)sender
{
    if ([(NSButton *)sender state] == NSOnState)    toolbar.itemDelimiterEnabled = NO;
    else                                            toolbar.itemDelimiterEnabled = YES;
}

- (IBAction)centerToolbarItemsAction:(id)sender
{
    if ([(NSButton *)sender state] == NSOnState)    toolbar.contentAlign = CNSplitViewToolbarContentAlignCentered;
    else                                            toolbar.contentAlign = CNSplitViewToolbarContentAlignItemDirected;
}

- (IBAction)draggingHandleEnabledAction:(id)sender
{
    if ([(NSButton *)sender state] == NSOnState)    self.splitView.draggingHandleEnabled = YES;
    else                                            self.splitView.draggingHandleEnabled = NO;
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

@end
