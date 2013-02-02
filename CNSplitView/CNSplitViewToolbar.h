//
//  CNSplitViewToolBar.h
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


#import <Cocoa/Cocoa.h>
#import "CNSplitViewDefinitions.h"
#import "CNSplitViewToolbarButton.h"

/**
 `SplitViewButtonBar` is a flexible and easy to use anchored button bar that will be placed on the 
 bottom edge of a given view. It has automatic resize handling. So you can place it to any `NSWindow`,
 `NSView`, `NSSplitView` etc. Resizing is done for you automatically.
 
 
 */



@interface CNSplitViewToolbar : NSView <CNSplitViewDelegate>

/** @name Properties */


/**
 ...
 */
@property (nonatomic, assign) CGFloat height;

/**
 ...
 */
@property (nonatomic, assign) CNSplitViewToolbarEdge anchoredEdge;

/**
 ...
 */
@property (assign, nonatomic, getter = isItemDelimiterEnabled) BOOL itemDelimiterEnabled;

/**
 ...
 */
@property (assign, nonatomic) CNSplitViewToolbarContentAlign contentAlign;



/** @name Initialization */


/** @name Button handling */

/**
 ...
 */
- (void)addButton:(CNSplitViewToolbarButton*)aButton;

/**
 Removes a given `CNAnchoredButton`.
 
 @param button    A present `CNAnchoredButton` object that should be removed.
 */
- (void)removeButton:(CNSplitViewToolbarButton*)aButton;

/**
 Removes all placed buttons.
 */
- (void)removeAllButtons;

/**
 Disable all receiver buttons.
 */
- (void)disable;

/**
 Enable all receiver buttons.
 */
- (void)enable;

@end
