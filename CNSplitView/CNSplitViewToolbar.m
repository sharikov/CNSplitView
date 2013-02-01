//
//  CNSplitViewToolBar.m
//
//  Created by cocoa:naut on 27.07.12.
//  Copyright (c) 2012 cocoa:naut. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright © 2012 Frank Gregor, <phranck@cocoanaut.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the “Software”), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */


#import "CNSplitViewToolbar.h"
#import "CNSplitViewToolbarButtonCell.h"


static NSSize       kDefaultDraggingHandleSize;
static CGFloat      kDefaultToolbarHeight = 24.0,
                    kDefaultItemDelimiterWidth = 1.0;
static NSColor      *kDefaultBorderColor,
                    *kDefaultGradientStartColor,
                    *kDefaultGradientEndColor;
static NSGradient   *delimiterLineGradient;
static NSColor      *delimiterGradientEndColor, *delimiterGradientCenterColor;

NSString *kEnableToolbarItemsNotification = @"EnableToolbarItemsNotification";
NSString *kDisableToolbarItemsNotification = @"DisableToolbarItemsNotification";


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CNSplitViewToolbar () {
    NSRect _previousToolbarRect;
    NSMutableArray *_delimiterOffsets;
}
@property (strong) NSMutableArray *buttons;

- (NSRect)rectForDividerDraggingHandle;
- (void)drawItemDelimiter;
- (void)recalculateItemPositions;
@end


@implementation CNSplitViewToolbar
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialzation

+ (void)initialize
{
    kDefaultDraggingHandleSize  = NSMakeSize(20, kDefaultToolbarHeight);
    kDefaultBorderColor         = [NSColor colorWithCalibratedRed:0.50 green:0.50 blue:0.50 alpha:1.0];
    kDefaultGradientStartColor  = [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0];
    kDefaultGradientEndColor    = [NSColor colorWithCalibratedRed:0.95 green:0.95 blue:0.95 alpha:1.0];

    /// button delimiter
    delimiterGradientEndColor = [NSColor colorWithCalibratedRed: 0.75 green: 0.75 blue: 0.75 alpha: 0.1];
    delimiterGradientCenterColor = [NSColor colorWithCalibratedRed: 0.42 green: 0.42 blue: 0.42 alpha: 1];
    delimiterLineGradient = [[NSGradient alloc] initWithColorsAndLocations:
                             delimiterGradientEndColor, 0.0,
                             [NSColor colorWithCalibratedRed: 0.78 green: 0.78 blue: 0.78 alpha: 0.5], 0.10,
                             delimiterGradientCenterColor, 0.50,
                             [NSColor colorWithCalibratedRed: 0.78 green: 0.78 blue: 0.78 alpha: 0.5], 0.90,
                             delimiterGradientEndColor, 1.0, nil];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self commonConfiguration];
    }
    return self;
}

- (void)commonConfiguration
{
    _frame = NSZeroRect;
    _height = kDefaultToolbarHeight;
    _itemDelimiterEnabled = YES;
    _draggingHandleEnabled = YES;
    _contentAlign = CNSplitViewToolbarContentAlignItemDirected;
    _backgroundGradientStartColor = kDefaultGradientStartColor;
    _backgroundGradientEndColor = kDefaultGradientEndColor;
    _borderColor = kDefaultBorderColor;

    _buttons = [[NSMutableArray alloc] init];
    _previousToolbarRect = NSZeroRect;
    _delimiterOffsets = [NSMutableArray array];
    _anchoredEdge = CNSplitViewToolbarEdgeUndefined;
    [self setAnchoredEdge:CNSplitViewToolbarEdgeBottom];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public API

- (void)addButton:(CNSplitViewToolbarButton *)aButton
{
    if (!self.buttons)
        self.buttons = [[NSMutableArray alloc] init];

    /// calculate or set the correct button width
    NSSize buttonSize = NSZeroSize;
    NSSize imageSize = (aButton.image ? aButton.image.size : NSMakeSize(0, 0));
    NSSize textSize = (aButton.attributedTitle ? aButton.attributedTitle.size : NSMakeSize(0, 0));

    CGFloat buttonWidth = aButton.toolbarButtonWidth;
    /// text + image
    if (textSize.width > 0 && imageSize.width > 0) {
        buttonWidth = kCNSplitViewToolbarButtonImageInset + imageSize.width + kCNSplitViewToolbarButtonImageToTextDistance + textSize.width + kCNSplitViewToolbarButtonTextInset;
    }
    /// image only
    else if (textSize.width == 0 && imageSize.width > 0) {
        CGFloat width = (kCNSplitViewToolbarButtonImageInset + imageSize.width + kCNSplitViewToolbarButtonImageInset);
        buttonWidth = (aButton.toolbarButtonWidth > width ? aButton.toolbarButtonWidth : width);
    }
    /// text only
    else if (textSize.width > 0 && imageSize.width == 0) {
        buttonWidth = kCNSplitViewToolbarButtonTextInset + textSize.width + kCNSplitViewToolbarButtonTextInset;
    }
    buttonWidth = (buttonWidth < aButton.toolbarButtonWidth ? aButton.toolbarButtonWidth : buttonWidth);
    buttonSize = NSMakeSize(buttonWidth, self.height - 1);

    /// set the correct button alignment
    switch (aButton.toolbarButtonAlign) {
        case CNSplitViewToolbarButtonAlignLeft: aButton.autoresizingMask = NSViewMaxXMargin; break;
        case CNSplitViewToolbarButtonAlignRight: aButton.autoresizingMask = NSViewMinXMargin; break;
    }
    aButton.frame = NSMakeRect(0, 0, buttonSize.width, buttonSize.height);

    [self.buttons addObject:aButton];
    [self addSubview:aButton];
}

- (void)removeButton:(CNSplitViewToolbarButton *)aButton
{
    [self.buttons removeObject:aButton];
    [aButton removeFromSuperview];
}

- (void)removeAllButtons
{
    self.subviews = [NSArray array];
    [self.buttons removeAllObjects];
    [self setNeedsDisplay:YES];
}

- (void)enable
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kEnableToolbarItemsNotification object:nil];
}

- (void)disable
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDisableToolbarItemsNotification object:nil];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSView

- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *buttonBarPath = [NSBezierPath bezierPathWithRect:dirtyRect];
    NSGradient *toolbarGradient = [[NSGradient alloc] initWithStartingColor: self.backgroundGradientStartColor
                                                                endingColor: self.backgroundGradientEndColor];
    [toolbarGradient drawInBezierPath:buttonBarPath angle:90];

    CGFloat posY = (self.anchoredEdge == CNSplitViewToolbarEdgeTop ? 0 : NSHeight(dirtyRect) - 1);
    NSRect borderLineRect = NSMakeRect(0, posY, NSWidth(dirtyRect), 1.0);
    NSBezierPath *borderLinePath = [NSBezierPath bezierPathWithRect:borderLineRect];
    [self.borderColor setFill];
    [borderLinePath fill];

    if (!NSEqualRects(self.bounds, _previousToolbarRect))
        [self recalculateItemPositions];
    _previousToolbarRect = self.bounds;

    [self drawItemDelimiter];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors

- (void)setAnchoredEdge:(CNSplitViewToolbarEdge)anchoredEdge
{
    _anchoredEdge = anchoredEdge;
    [self setAutoresizingMask:NSViewWidthSizable | (_anchoredEdge == CNSplitViewToolbarEdgeBottom ? NSViewMaxYMargin : NSViewMinYMargin)];

    /// In case of the toolbar is on top, we have to draw a 1 pixel wide separator line on the bottom side (origin.y == 0).
    /// For this reason all toolbar buttons have to placed this 1 pixel above that line for not overpainting it.
    if (_anchoredEdge == CNSplitViewToolbarEdgeTop) {
        [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSPoint adjustedOrigin = [(NSView *)obj frame].origin;
            adjustedOrigin.y++;
            [(NSView *)obj setFrameOrigin:adjustedOrigin];
        }];
    }
}

- (void)setBackgroundGradientStartColor:(NSColor *)backgroundGradientStartColor
{
    _backgroundGradientStartColor = backgroundGradientStartColor;
}

- (void)setBackgroundGradientEndColor:(NSColor *)backgroundGradientEndColor
{
    _backgroundGradientEndColor = backgroundGradientEndColor;
}

- (void)setItemDelimiterEnabled:(BOOL)itemDelimiterEnabled
{
    _itemDelimiterEnabled = itemDelimiterEnabled;
    [self setNeedsDisplay:YES];
}

- (void)setContentAlign:(CNSplitViewToolbarContentAlign)contentAlign
{
    _contentAlign = contentAlign;
    _previousToolbarRect = NSZeroRect;
    [self setNeedsDisplay:YES];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Helper

- (NSRect)rectForDividerDraggingHandle
{
    NSRect rectForDividerHandle = NSZeroRect;

//    if (self.isDraggingHandleEnabled) {
//        rectForDividerHandle = NSMakeRect(NSMaxX(self.bounds)-20.0, NSMaxY(self.bounds), 20.0, NSHeight(self.bounds));
//        NSBezierPath *handlePath = [NSBezierPath bezierPathWithRect:rectForDividerHandle];
//        [[NSColor lightGrayColor] set];
//        [handlePath stroke];
//    }
    return rectForDividerHandle;
}

- (void)drawItemDelimiter
{
    if (!self.itemDelimiterEnabled)
        return;

    [_delimiterOffsets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat posX = [(NSNumber *)obj doubleValue];
        NSRect delimiterRect = NSMakeRect(posX, (self.anchoredEdge == CNSplitViewToolbarEdgeBottom ? 0 : 1), kDefaultItemDelimiterWidth, NSHeight(self.bounds) - 1);
        NSBezierPath *delimiterLine = [NSBezierPath bezierPathWithRect:delimiterRect];
        [delimiterLineGradient drawInBezierPath:delimiterLine angle:90];
    }];
}

- (void)recalculateItemPositions
{
    __block CGFloat leftOffset = 0,
                    rightOffset = NSWidth(self.frame)
    ;
    [_delimiterOffsets removeAllObjects];

    switch (self.contentAlign) {
        case CNSplitViewToolbarContentAlignItemDirected: {
            [self.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[CNSplitViewToolbarButton class]]) {
                    CNSplitViewToolbarButton *theButton = (CNSplitViewToolbarButton *)obj;

                    if (theButton.toolbarButtonAlign == CNSplitViewToolbarButtonAlignLeft) {
                        theButton.autoresizingMask = NSViewMaxXMargin;
                        [theButton setFrameOrigin:NSMakePoint(leftOffset, (self.anchoredEdge == CNSplitViewToolbarEdgeBottom ? 0 : 1))];
                        leftOffset += NSWidth(theButton.frame) + (self.isItemDelimiterEnabled ? kDefaultItemDelimiterWidth : 0);
                        [_delimiterOffsets setObject:[NSNumber numberWithDouble:ceil(NSMaxX(theButton.frame))] atIndexedSubscript:idx];

                    } else {
                        theButton.autoresizingMask = NSViewMinXMargin;
                        [theButton setFrameOrigin:NSMakePoint(rightOffset - NSWidth(theButton.frame), (self.anchoredEdge == CNSplitViewToolbarEdgeBottom ? 0 : 1))];
                        rightOffset -= (NSWidth(theButton.frame) + (self.isItemDelimiterEnabled ? kDefaultItemDelimiterWidth : 0));
                        [_delimiterOffsets setObject:[NSNumber numberWithDouble:ceil(NSMinX(theButton.frame))-1] atIndexedSubscript:idx];
                    }
                }
            }];
            break;
        }

        case CNSplitViewToolbarContentAlignCentered: {
            /// calculate the left offset related to all button widths
            leftOffset = NSWidth(self.bounds) / 2 + [self.buttons count] - (self.isItemDelimiterEnabled ? kDefaultItemDelimiterWidth : 0);
            [self.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[CNSplitViewToolbarButton class]]) {
                    CNSplitViewToolbarButton *theButton = (CNSplitViewToolbarButton *)obj;
                    leftOffset -= ceil(NSWidth(theButton.frame) / 2 + (self.isItemDelimiterEnabled ? kDefaultItemDelimiterWidth : 0));
                }
            }];

            /// calculate the button positions
            [self.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[CNSplitViewToolbarButton class]]) {
                    CNSplitViewToolbarButton *theButton = (CNSplitViewToolbarButton *)obj;
                    theButton.autoresizingMask = NSViewNotSizable;
                    [theButton setFrameOrigin:NSMakePoint(leftOffset, (self.anchoredEdge == CNSplitViewToolbarEdgeBottom ? 0 : 1))];
                    leftOffset += ceil(NSWidth(theButton.frame)) + (self.isItemDelimiterEnabled ? kDefaultItemDelimiterWidth : 0);

                    /// As we draw the delimiter always on the right side of an item,
                    /// the first item needs to get space for an additional delimiter on its left side.
                    if (idx == 0)
                        [_delimiterOffsets setObject:[NSNumber numberWithDouble:ceil(NSMinX(theButton.frame))-1] atIndexedSubscript:idx];

                    [_delimiterOffsets setObject:[NSNumber numberWithDouble:ceil(NSMaxX(theButton.frame))] atIndexedSubscript:idx+1];
                }
            }];
            break;
        }
    }
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSSplitView Delegate

- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex
{
    NSRect additionalEffectiveRect = [self rectForDividerDraggingHandle];

    return additionalEffectiveRect;
}


@end
