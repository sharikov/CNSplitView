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
    self.secondView.text = @"A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart.";
    self.secondView.textBoxWidth = 380;
    self.secondView.icon = [NSImage imageNamed:@"SplitLeaf-Icon"];
    self.secondView.iconVerticalOffset = 70;

    CNSplitViewToolbar *toolbar = [[CNSplitViewToolbar alloc] init];

    CNSplitViewToolbarButton *button1 = [[CNSplitViewToolbarButton alloc] init];
    button1.toolbarButtonType = CNSplitViewToolbarButtonTypeAdd;
    button1.keyEquivalent = @"n";
    button1.keyEquivalentModifierMask = NSCommandKeyMask;

    CNSplitViewToolbarButton *button2 = [[CNSplitViewToolbarButton alloc] init];
    button2.toolbarButtonType = CNSplitViewToolbarButtonTypeRemove;

    CNSplitViewToolbarButton *button3 = [[CNSplitViewToolbarButton alloc] init];
    button3.toolbarAlign = CNSplitViewToolbarButtonAlignRight;
    button3.toolbarButtonType = CNSplitViewToolbarButtonTypeLockUnlocked;

    CNSplitViewToolbarButton *button4 = [[CNSplitViewToolbarButton alloc] init];
    button4.toolbarAlign = CNSplitViewToolbarButtonAlignRight;
    button4.toolbarButtonType = CNSplitViewToolbarButtonTypeRefresh;
    button4.title = @"Refresh";

    [toolbar addButton:button1];
    [toolbar addButton:button2];
    [toolbar addButton:button3];
    [toolbar addButton:button4];

    [self.splitView addToolbar:toolbar besidesSubviewAtIndex:0 onEdge:CNSplitViewToolbarEdgeBottom];
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
