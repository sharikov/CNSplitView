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


typedef enum {
    CNAnchoredButtonBarSubviewFirst = 0,
    CNAnchoredButtonBarSubviewSecond
} CNAnchoredButtonBarSubview;

@interface CNSplitViewToolbar : NSView

/** @name Properties */

@property (nonatomic, assign) CNSplitViewToolbarEdge anchoredEdge;

///**
// Boolean value that indicates whether the button bar should draw a top border line.
// 
// @param YES     Will draw a border line on the top edge.
// @param NO      Don't draw any border line on the top edge.
// */
//@property (nonatomic, assign, getter = hasTopBorder) BOOL topBorder;
//
///**
// Boolean value that indicates whether the button bar should draw a right border line.
// 
// @param YES     Will draw a border line on the right edge.
// @param NO      Don't draw any border line on the right edge.
// */
//@property (nonatomic, assign, getter = hasRightBorder) BOOL rightBorder;
//
///**
// Boolean value that indicates whether the button bar should draw a bottom border line.
// 
// @param YES     Will draw a border line on the bottom edge.
// @param NO      Don't draw any border line on the bottom edge.
// */
//@property (nonatomic, assign, getter = hasBottomBorder) BOOL bottomBorder;
//
///**
// Boolean value that indicates whether the button bar should draw a left border line.
// 
// @param YES     Will draw a border line on the left edge.
// @param NO      Don't draw any border line on the left edge.
// */
//@property (nonatomic, assign, getter = hasLeftBorder) BOOL leftBorder;

///**
// The color of the top border line.
// 
// The default value is:
// 
//    [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0];
// 
// @param topBorderColor  An object of type `NSColor`.
// */
//@property (nonatomic, strong) NSColor *topBorderColor;
//
///**
// The color of the right border line.
// 
// The default value is:
// 
//    [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0];
// 
// @param rightBorderColor  An object of type `NSColor`.
// */
//@property (nonatomic, strong) NSColor *rightBorderColor;
//
///**
// The color of the bottom border line.
// 
// The default value is:
// 
//    [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0];
// 
// @param bottomBorderColor  An object of type `NSColor`.
// */
//@property (nonatomic, strong) NSColor *bottomBorderColor;
//
///**
// The color of the left border line.
// 
// The default value is:
// 
//    [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0];
// 
// @param leftBorderColor  An object of type `NSColor`.
// */
//@property (nonatomic, strong) NSColor *leftBorderColor;



/** @name Initialization */

/**
 Creates and returns an initialized object of an anchored button bar.
 
 By default, the returned buttonbar will be anchored to the **bottom edge** of `anchorSplitView's` subview with given `viewIndex`.
 
 @param anchorSplitView     An object that is inherited by any instance of `NSView`.
 @param viewIndex           The index of anchorSplitView's subview the buttonbar should be anchored to.
*/
- (id)initWithAnchorSplitView:(id)anchorSplitView anchorToViewAtIndex:(NSUInteger)viewIndex;

/**
 ...
 */
- (id)initWithAnchorSplitView:(id)anchorSplitView anchorToViewAtIndex:(NSUInteger)viewIndex onAnchoredEdge:(CNSplitViewToolbarEdge)anchoredEdge;


/** @name Button handling */

/**
 ...
 */
- (void)addButton:(CNSplitViewToolbarButton*)aButton;

/**
 Removes a given `CNAnchoredButton`.
 
 @param button    A present `CNAnchoredButton` object that should be removed.
 */
- (void)removeButton:(CNSplitViewToolbarButton*)button;

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
