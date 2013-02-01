//
//  CNSplitView.m
//
//  Created by cocoa:naut on 29.07.12.
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

#import <QuartzCore/QuartzCore.h>
#import "CNSplitView.h"


static NSColor *kDefaultDeviderColor;
static CGFloat kDefaultAnimationDuration;
NSString *CNSplitViewInjectReferenceNotification = @"InjectReferenceNotification";

@interface CNSplitView () {
    NSColor *_dividerColor;
    NSView *_toolbarContainer;
    NSView *_anchoredView;
    CNSplitViewToolbar *_toolbar;
    BOOL _toolbarIsVisible;
}
@end

@implementation CNSplitView
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization

+ (void)initialize
{
    kDefaultDeviderColor = [NSColor colorWithCalibratedRed:0.50 green:0.50 blue:0.50 alpha:1.0];
    kDefaultAnimationDuration = 0.21;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self commonConfiguration];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonConfiguration];
    }
    return self;
}

- (void)commonConfiguration
{
    _dividerColor = kDefaultDeviderColor;
    _draggingHandleEnabled = NO;
    _toolbarContainer = nil;
    _anchoredView = nil;
    _toolbar = nil;
    _toolbarIsVisible = NO;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configuring & Handling Toolbars

- (void)addToolbar:(CNSplitViewToolbar *)theToolbar besidesSubviewAtIndex:(NSUInteger)theSubviewIndex onEdge:(CNSplitViewToolbarEdge)theEdge
{
    /// via notification we inject a refernce to ourself into the toolbar
    [[NSNotificationCenter defaultCenter] postNotificationName:CNSplitViewInjectReferenceNotification object:self];

    _anchoredView = [[self subviews] objectAtIndex:theSubviewIndex];
    [_anchoredView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    /// we need a new container view for our toolbar + anchoredView
    _toolbarContainer = [[NSView alloc] initWithFrame:_anchoredView.frame];
    [_toolbarContainer setWantsLayer:YES];
    [_toolbarContainer setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    [self replaceSubview:_anchoredView with:_toolbarContainer];
    [self adjustSubviews];

    _toolbar = theToolbar;
    _toolbar.anchoredEdge = theEdge;
    [_toolbar setFrame:NSMakeRect(NSMinX(_anchoredView.frame),
                                  NSMinY(_anchoredView.frame) - _toolbar.height,
                                  NSWidth(_anchoredView.frame),
                                  _toolbar.height)];
    [self setDelegate:_toolbar];

    [_toolbarContainer addSubview:_toolbar];
    [_toolbarContainer addSubview:_anchoredView];
}

- (void)showToolbarAnimated:(BOOL)animated
{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = (animated ? kDefaultAnimationDuration : 0);
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

        NSRect adjustedAnchoredViewRect = NSMakeRect(NSMinX(_anchoredView.frame),
                                                     NSMinY(_anchoredView.frame) + _toolbar.height,
                                                     NSWidth(_anchoredView.frame),
                                                     NSHeight(_anchoredView.frame) - _toolbar.height);
        [[_anchoredView animator] setFrame:adjustedAnchoredViewRect];

        /// place the toolbar
        NSPoint adjustedToolbarOrigin = NSMakePoint(NSMinX(_toolbar.frame),
                                                    (_toolbar.anchoredEdge == CNSplitViewToolbarEdgeBottom ? 0 : NSMinY(_anchoredView.frame)));
        [[_toolbar animator] setFrameOrigin:adjustedToolbarOrigin];

    } completionHandler:^{
        _toolbarIsVisible = YES;
    }];
}

- (void)hideToolbarAnimated:(BOOL)animated
{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = (animated ? kDefaultAnimationDuration : 0);
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

        NSRect adjustedAnchoredViewRect = NSMakeRect(NSMinX(_anchoredView.frame),
                                                     NSMinY(_anchoredView.frame) - _toolbar.height,
                                                     NSWidth(_anchoredView.frame),
                                                     NSHeight(_anchoredView.frame) + _toolbar.height);
        [[_anchoredView animator] setFrame:adjustedAnchoredViewRect];

        /// place the toolbar
        NSPoint adjustedToolbarOrigin = NSMakePoint(NSMinX(_toolbar.frame),
                                                    (_toolbar.anchoredEdge == CNSplitViewToolbarEdgeBottom ? -_toolbar.height : NSMinY(_anchoredView.frame)));
        [[_toolbar animator] setFrameOrigin:adjustedToolbarOrigin];

    } completionHandler:^{
        _toolbarIsVisible = NO;
    }];
}

- (void)toggleToolbarVisibilityAnimated:(BOOL)animated
{
    if (_toolbarIsVisible) {
        [self hideToolbarAnimated:animated];
    } else {
        [self showToolbarAnimated:animated];
    }
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors

- (void)setDeviderColor:(NSColor *)theColor
{
    _dividerColor = theColor;
}

- (void)setDraggingHandleEnabled:(BOOL)draggingHandleEnabled
{
    _draggingHandleEnabled = draggingHandleEnabled;
    [[NSNotificationCenter defaultCenter] postNotificationName:CNSplitViewDraggingHandleEnableDisableNotification object:[NSNumber numberWithBool:_draggingHandleEnabled]];
}

- (void)setVertical:(BOOL)flag
{
    [super setVertical:flag];
    [self adjustSubviews];
    [[NSNotificationCenter defaultCenter] postNotificationName:CNSplitViewDraggingHandleEnableDisableNotification object:[NSNumber numberWithBool:self.draggingHandleEnabled]];
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


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSSplitView

- (NSColor *)dividerColor
{
    return _dividerColor;
}


@end
