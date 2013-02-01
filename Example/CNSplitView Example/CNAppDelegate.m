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
//    toolbar.contentAlign = CNSplitViewToolbarContentAlignCentered;
//    toolbar.itemDelimiterEnabled = NO;

    CNSplitViewToolbarButton *button1 = [[CNSplitViewToolbarButton alloc] init];
    button1.toolbarButtonType = CNSplitViewToolbarButtonTypeAdd;
    button1.keyEquivalent = @"n";
    button1.keyEquivalentModifierMask = NSCommandKeyMask;

    CNSplitViewToolbarButton *button2 = [[CNSplitViewToolbarButton alloc] init];
    button2.toolbarButtonType = CNSplitViewToolbarButtonTypeRemove;

    CNSplitViewToolbarButton *button3 = [[CNSplitViewToolbarButton alloc] init];
    button3.toolbarButtonAlign = CNSplitViewToolbarButtonAlignRight;
    button3.toolbarButtonType = CNSplitViewToolbarButtonTypeLockUnlocked;

    CNSplitViewToolbarButton *button4 = [[CNSplitViewToolbarButton alloc] init];
    button4.toolbarButtonAlign = CNSplitViewToolbarButtonAlignRight;
    button4.toolbarButtonType = CNSplitViewToolbarButtonTypeRefresh;
//    button4.title = @"Refresh";

    [toolbar addButton:button1];
    [toolbar addButton:button2];
    [toolbar addButton:button3];
    [toolbar addButton:button4];

    [self.splitView addToolbar:toolbar besidesSubviewAtIndex:0 onEdge:CNSplitViewToolbarEdgeBottom];
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

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
    return 180;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
    return [[[self window] contentView] bounds].size.width - 180;
}

@end
