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


@implementation CNAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    CNSplitViewToolbar *toolbar = [[CNSplitViewToolbar alloc] initWithAnchorSplitView:self.splitView anchorToViewAtIndex:0];

    CNSplitViewToolbarButton *button1 = [[CNSplitViewToolbarButton alloc] init];
    button1.toolbarAlign = CNSplitViewToolbarButtonAlignLeft;
    button1.image = [NSImage imageNamed:NSImageNameAddTemplate];
    button1.keyEquivalent = @"n";
    button1.keyEquivalentModifierMask = NSCommandKeyMask;

    CNSplitViewToolbarButton *button2 = [[CNSplitViewToolbarButton alloc] init];
    button2.toolbarAlign = CNSplitViewToolbarButtonAlignLeft;
    button2.image = [NSImage imageNamed:NSImageNameRemoveTemplate];
//    button2.title = @"BlahFasel...";
    [button2 setEnabled:YES];

    CNSplitViewToolbarButton *button3 = [[CNSplitViewToolbarButton alloc] init];
    button3.toolbarAlign = CNSplitViewToolbarButtonAlignRight;
    button3.image = [NSImage imageNamed:NSImageNameRightFacingTriangleTemplate];
//    button3.title = @"Oink";

    CNSplitViewToolbarButton *button4 = [[CNSplitViewToolbarButton alloc] init];
    button4.toolbarAlign = CNSplitViewToolbarButtonAlignRight;
    button4.title = @"ge453 g6";

    [toolbar addButton:button1];
    [toolbar addButton:button2];
    [toolbar addButton:button3];
//    [toolbar addButton:button4];

//    [self.splitView addToolBar:toolbar toDividerAtIndex:0 arranged:CNSplitViewToolBarArrangedBeforeDivider];
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
