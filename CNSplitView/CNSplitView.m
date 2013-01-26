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

#import "CNSplitView.h"



@interface CNSplitView () {
    NSColor *_dividerColor;
}

- (NSRect)rectForDividerDraggingHandle;
@end

@implementation CNSplitView

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization

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
    _dividerColor = [NSColor lightGrayColor];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configuring & Handling Toolbars

- (void)addToolBar:(CNSplitViewToolbar *)theToolBar besidesSubviewAtIndex:(NSUInteger)theSubviewIndex onEdge:(CNSplitViewToolbarEdge)theEdge
{

}

- (void)addToolBar:(CNSplitViewToolbar *)theToolBar besidesSubviewAtIndex:(NSUInteger)theSubviewIndex onEdge:(CNSplitViewToolbarEdge)theEdge animated:(BOOL)animated
{
    
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors

- (void)setDeviderColor:(NSColor *)theColor
{
    _dividerColor = theColor;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Helper

- (NSRect)rectForDividerDraggingHandle
{
    NSRect rectForDividerHandle = NSZeroRect;

    return rectForDividerHandle;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSSplitView

- (NSColor *)dividerColor
{
    return _dividerColor;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSSplitView Delegate

- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex
{
    NSRect additionalEffectiveRect = NSZeroRect;
    if ([self.delegate respondsToSelector:_cmd])
        additionalEffectiveRect = [self.delegate splitView:splitView additionalEffectiveRectOfDividerAtIndex:dividerIndex];
    else
        additionalEffectiveRect = [self rectForDividerDraggingHandle];

    return additionalEffectiveRect;
}


@end
