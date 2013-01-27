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


static CGFloat kDefaultToolbarHeight = 24.0;
static NSColor *topBorderDefaultColor, *bottomBorderDefaultColor;
static NSGradient *buttonBarGradient;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CNSplitViewToolbar () {
    CGFloat offsetLeft;
    CGFloat offsetRight;
    CGFloat _buttonBarInteriorWidth;
    CGFloat _buttonBarInteriorHeight;
}
@property (strong) NSMutableArray *buttons;
@property (strong) id neighbourView;
@property (strong) id anchorViewsFirstSubview;

- (CGFloat)buttonBarInteriorWidth;
- (CGFloat)buttonBarInteriorHeight;
@end


@implementation CNSplitViewToolbar
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialzation

+ (void)initialize
{
    topBorderDefaultColor       = [NSColor colorWithCalibratedRed:0.50 green:0.50 blue:0.50 alpha:1.0];
    bottomBorderDefaultColor    = [NSColor colorWithCalibratedRed:0.50 green:0.50 blue:0.50 alpha:1.0];
    buttonBarGradient           = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0]
                                                                endingColor:[NSColor colorWithCalibratedRed:0.95 green:0.95 blue:0.95 alpha:1.0]];

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
    _buttonBarInteriorHeight = _height - 1;     // 1 means the thickness of the top or bottom border line

    _buttons = [[NSMutableArray alloc] init];
    _neighbourView = nil;
    offsetLeft = 0;
    offsetRight = 0;
    _anchoredEdge = CNSplitViewToolbarEdgeUndefined;
    [self setAnchoredEdge:CNSplitViewToolbarEdgeBottom];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *buttonBarPath = [NSBezierPath bezierPathWithRect:dirtyRect];
    [buttonBarGradient drawInBezierPath:buttonBarPath angle:90];

    NSRect borderLineRect = NSMakeRect(0, (self.anchoredEdge == CNSplitViewToolbarEdgeTop ? 0 : NSHeight(dirtyRect) - 1),
                                       NSWidth(dirtyRect), 1.0f);
    NSBezierPath *borderLinePath = [NSBezierPath bezierPathWithRect:borderLineRect];
    [(self.anchoredEdge == CNSplitViewToolbarEdgeTop ? bottomBorderDefaultColor : topBorderDefaultColor) setFill];
    [borderLinePath fill];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors

- (void)setAnchoredEdge:(CNSplitViewToolbarEdge)anchoredEdge
{
    _anchoredEdge = anchoredEdge;
    CNLog(@"_anchoredEdge: %i", _anchoredEdge);
    [self setAutoresizingMask:NSViewWidthSizable | (_anchoredEdge == CNSplitViewToolbarEdgeBottom ? NSViewMaxYMargin : NSViewMinYMargin)];

    if (_anchoredEdge == CNSplitViewToolbarEdgeTop) {
        [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSPoint adjustedOrigin = [(NSView *)obj frame].origin;
            adjustedOrigin.y++;
            [(NSView *)obj setFrameOrigin:adjustedOrigin];
        }];
    }
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Helper

- (CGFloat)buttonBarInteriorWidth
{
    return self.frame.size.width;
}

- (CGFloat)buttonBarInteriorHeight
{
    _buttonBarInteriorHeight = self.height - 1;
    return _buttonBarInteriorHeight;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public API

- (void)addButton:(CNSplitViewToolbarButton *)aButton
{
    if (!self.buttons)
        self.buttons = [[NSMutableArray alloc] init];
    [self.buttons addObject:aButton];

    /// calculate or set the correct button width
    NSSize buttonSize = NSZeroSize;
    NSSize imageSize = (aButton.image ? aButton.image.size : NSMakeSize(0, 0));
    NSSize textSize = (aButton.attributedTitle ? aButton.attributedTitle.size : NSMakeSize(0, 0));

    CGFloat buttonWidth = aButton.toolbarButtonWidth;
    /// text + image
    if (textSize.width > 0 && imageSize.width > 0) {
        buttonWidth = kCNSplitViewToolbarButtonImageInset + imageSize.width + kCNSplitViewToolbarButtonImageTextDistance + textSize.width + kCNSplitViewToolbarButtonTextInset;
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
    switch (aButton.toolbarAlign) {
        case CNSplitViewToolbarButtonAlignLeft: {
            aButton.autoresizingMask = NSViewMaxXMargin;
            aButton.frame = NSMakeRect(offsetLeft, (self.anchoredEdge == CNSplitViewToolbarEdgeBottom ? 0 : 1), buttonSize.width, buttonSize.height);
            offsetLeft += NSWidth(aButton.frame);
            break;
        }

        case CNSplitViewToolbarButtonAlignRight: {
            aButton.autoresizingMask = NSViewMinXMargin;
            aButton.frame = NSMakeRect(offsetRight - buttonSize.width, (self.anchoredEdge == CNSplitViewToolbarEdgeBottom ? 0 : 1), buttonSize.width, buttonSize.height);
            offsetRight -= buttonSize.width;
            break;
        }
    }
    CNLogForRect(aButton.frame);
    [self addSubview:aButton];
}

- (void)removeButton:(CNSplitViewToolbarButton *)button
{
    [self.buttons removeObject:button];
    [button removeFromSuperview];
}

- (void)removeAllButtons
{
    self.subviews = [NSArray array];
    [self.buttons removeAllObjects];
    [self setNeedsDisplay:YES];
}

- (void)disable
{
    [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(NSControl *)obj setEnabled:NO];
    }];
}

- (void)enable
{
    [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(NSControl *)obj setEnabled:YES];
    }];
}


@end
