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


static CGFloat kAnchoredButtonBarHeight = 24.0;


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
@property (strong) NSColor *topBorderDefaultColor;
@property (strong) NSColor *rightBorderDefaultColor;
@property (strong) NSColor *bottomBorderDefaultColor;
@property (strong) NSColor *leftBorderDefaultColor;
@property (strong) NSGradient *buttonBarGradient;

- (void)adjustRectForNeighbourView:(id)neighbourView withButtonBarHeight:(CGFloat)barHeight onAnchoredEdge:(CNSplitViewToolbarEdge)anchoredEdge;
- (CGFloat)buttonBarInteriorWidth;
- (CGFloat)buttonBarInteriorHeight;
- (NSSplitView*)embeddingSplitView;
@end


@implementation CNSplitViewToolbar
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialzation

- (id)init
{
    self = [super init];
    if (self) {
        _topBorderDefaultColor      = [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0];
        _rightBorderDefaultColor    = [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0];
        _bottomBorderDefaultColor   = [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0];
        _leftBorderDefaultColor     = [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0];
        _buttonBarGradient          = [[NSGradient alloc] initWithStartingColor: [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0]
                                                                    endingColor: [NSColor colorWithCalibratedRed:0.95 green:0.95 blue:0.95 alpha:1.0]];

        _frame = NSZeroRect;
        _anchoredEdge = CNSplitViewToolbarEdgeBottom;
        _buttonBarInteriorHeight = kAnchoredButtonBarHeight - 1;

        _buttons = [[NSMutableArray alloc] init];
        _neighbourView = nil;
        offsetLeft = 0;
        offsetRight = 0;
    }
    return self;
}

- (id)initWithAnchorSplitView:(id)anchorSplitView anchorToViewAtIndex:(NSUInteger)viewIndex
{
    return [self initWithAnchorSplitView:anchorSplitView anchorToViewAtIndex:viewIndex onAnchoredEdge:_anchoredEdge];
}

- (id)initWithAnchorSplitView:(id)anchorSplitView anchorToViewAtIndex:(NSUInteger)viewIndex onAnchoredEdge:(CNSplitViewToolbarEdge)anchoredEdge
{
    self = [self init];
    if (self) {

        @try {
            NSException *ex = [NSException exceptionWithName:@"CNWrongAnchorView"
                                                      reason:[NSString stringWithFormat:@"A class of kind NSSplitView expected, but got %@ instead.", anchorSplitView]
                                                    userInfo:nil];

            if ([anchorSplitView isKindOfClass:[NSSplitView class]]) {
                self.anchoredEdge = anchoredEdge;
                self.neighbourView = [[anchorSplitView subviews] objectAtIndex:viewIndex];

                /// inject the button bar into the anchored views superview
                if ([[self.neighbourView subviews] count] > 0) {
                    self.anchorViewsFirstSubview = [[self.neighbourView subviews] objectAtIndex:0];
                } else {
                    self.anchorViewsFirstSubview = self.neighbourView;
                }

                /// rebuild the rect for the anchor view
                [self adjustRectForNeighbourView:self.anchorViewsFirstSubview
                             withButtonBarHeight:kAnchoredButtonBarHeight
                                  onAnchoredEdge:self.anchoredEdge];

                self = [super initWithFrame:[self buttonBarRectWithHeight:kAnchoredButtonBarHeight
                                                           onAnchoredEdge:self.anchoredEdge]];
                if (self) {
                    [self setAutoresizingMask:NSViewWidthSizable | (self.anchoredEdge == CNSplitViewToolbarEdgeBottom ? NSViewMaxYMargin : NSViewMinYMargin)];
                    offsetRight = NSWidth(self.frame);
                    [self.neighbourView addSubview:self];
                }

            } else {
                @throw ex;
            }
        }
        @catch (NSException *ex) {
            @throw;
        }
    }
    return self;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *buttonBarPath = [NSBezierPath bezierPathWithRect:dirtyRect];
    [self.buttonBarGradient drawInBezierPath:buttonBarPath angle:90];

    /// the top border line
    NSBezierPath *topLinePath = [NSBezierPath bezierPathWithRect:NSMakeRect(0, NSHeight(dirtyRect) - 1, NSWidth(dirtyRect), 1.0)];
    [[NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0] setFill];
    [topLinePath fill];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Helper

- (void)adjustRectForNeighbourView:(id)neighbourView withButtonBarHeight:(CGFloat)barHeight onAnchoredEdge:(CNSplitViewToolbarEdge)anchoredEdge
{
    NSRect neighbourViewRect = [neighbourView frame];
    NSRect adjustedRect = NSMakeRect(neighbourViewRect.origin.x,
                                     (anchoredEdge == CNSplitViewToolbarEdgeBottom ? neighbourViewRect.origin.y + barHeight : neighbourViewRect.origin.y),
                                     neighbourViewRect.size.width,
                                     neighbourViewRect.size.height - barHeight);
    [neighbourView setFrame:adjustedRect];
}

- (NSRect)buttonBarRectWithHeight:(CGFloat)barHeight onAnchoredEdge:(CNSplitViewToolbarEdge)anchoredEdge
{
    CGFloat anchorViewWidth  = NSWidth([[self neighbourView] frame]);
    CGFloat anchorViewHeight = NSHeight([[self neighbourView] frame]);
    NSRect buttonBarRect = NSMakeRect(0, (anchoredEdge == CNSplitViewToolbarEdgeTop ? anchorViewHeight : 0),
                                      anchorViewWidth,
                                      kAnchoredButtonBarHeight);
    return buttonBarRect;
}

- (CGFloat)buttonBarInteriorWidth
{
    return self.frame.size.width;
}

- (CGFloat)buttonBarInteriorHeight
{
    _buttonBarInteriorHeight = kAnchoredButtonBarHeight - 1;
    return _buttonBarInteriorHeight;
}

- (NSSplitView*)embeddingSplitView
{
	NSSplitView *embeddingSplitView = nil;
	id currentView = self;

	while (![currentView isKindOfClass:[NSSplitView class]] && currentView != nil)
	{
		currentView = [currentView superview];
		if ([currentView isKindOfClass:[NSSplitView class]])
			embeddingSplitView = currentView;
	}

	return embeddingSplitView;
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
        buttonWidth = kImageInset + imageSize.width + kImageTextDistance + textSize.width + kTextInset;
    }
    /// image only
    else if (textSize.width == 0 && imageSize.width > 0) {
        CGFloat width = (kImageInset + imageSize.width + kImageInset);
        buttonWidth = (aButton.toolbarButtonWidth > width ? aButton.toolbarButtonWidth : width);
    }
    /// text only
    else if (textSize.width > 0 && imageSize.width == 0) {
        buttonWidth = kTextInset + textSize.width + kTextInset;
    }
    buttonWidth = (buttonWidth < aButton.toolbarButtonWidth ? aButton.toolbarButtonWidth : buttonWidth);
    buttonSize = NSMakeSize(buttonWidth, [self buttonBarInteriorHeight]);


    /// set the correct button alignment
    switch (aButton.toolbarAlign) {
        case CNSplitViewToolbarButtonAlignLeft: {
            aButton.autoresizingMask = NSViewMaxXMargin;
//            aButton.frame = NSMakeRect(offsetLeft, (self.hasBottomBorder ? 1 : 0), buttonSize.width, buttonSize.height);
            aButton.frame = NSMakeRect(offsetLeft, 0, buttonSize.width, buttonSize.height);
            offsetLeft += NSWidth(aButton.frame);
            break;
        }

        case CNSplitViewToolbarButtonAlignRight: {
            aButton.autoresizingMask = NSViewMinXMargin;
//            aButton.frame = NSMakeRect(offsetRight - buttonSize.width, (self.hasBottomBorder ? 1 : 0), buttonSize.width, buttonSize.height);
            aButton.frame = NSMakeRect(offsetRight - buttonSize.width, 0, buttonSize.width, buttonSize.height);
            offsetRight -= buttonSize.width;
            break;
        }
    }
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
