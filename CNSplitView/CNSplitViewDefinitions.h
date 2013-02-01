//
//  CNSplitViewDefinitions.h
//
//  Created by cocoa:naut on 01.09.12.
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


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// SplitView related parameter
typedef enum {
    CNSplitViewDeviderOrientationVertical = 0,
    CNSplitViewDeviderOrientationHorizontal
} CNSplitViewDeviderOrientation;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Toolbar related parameter
typedef enum {
    CNSplitViewToolbarEdgeUndefined = 0,
    CNSplitViewToolbarEdgeBottom,
    CNSplitViewToolbarEdgeTop
} CNSplitViewToolbarEdge;

typedef enum {
    CNSplitViewToolbarVisibilityHidden = 0,
    CNSplitViewToolbarVisibilityVisible
} CNSplitViewToolbarVisibility;

typedef enum {
    CNSplitViewToolbarContentAlignItemDirected = 0,
    CNSplitViewToolbarContentAlignCentered
} CNSplitViewToolbarContentAlign;

typedef enum {
    CNSplitViewToolbarButtonAlignLeft = 0,
    CNSplitViewToolbarButtonAlignRight
} CNSplitViewToolbarButtonAlign;

/// Notifications
extern NSString *CNSplitViewInjectReferenceNotification;
extern NSString *CNSplitViewToolbarItemsEnableNotification;
extern NSString *CNSplitViewToolbarItemsDisableNotification;
extern NSString *CNSplitViewDraggingHandleEnableDisableNotification;
extern NSString *CNSplitViewShowHideToolbarNotification;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Toolbar button related parameter
/// @see http://developer.apple.com/library/mac/#documentation/userexperience/conceptual/applehiguidelines/SystemProvidedIcons/SystemProvidedIcons.html
typedef enum {
    CNSplitViewToolbarButtonImagePlain = 0,
    CNSplitViewToolbarButtonImageAdd,
    CNSplitViewToolbarButtonImageRemove,
    CNSplitViewToolbarButtonImageQuickLook,
    CNSplitViewToolbarButtonImageAction,
    CNSplitViewToolbarButtonImageShare,
    CNSplitViewToolbarButtonImageIconView,
    CNSplitViewToolbarButtonImageListView,
    CNSplitViewToolbarButtonImageLockLocked,
    CNSplitViewToolbarButtonImageLockUnlocked,
    CNSplitViewToolbarButtonImageGoRight,
    CNSplitViewToolbarButtonImageGoLeft,
    CNSplitViewToolbarButtonImageStopProgress,
    CNSplitViewToolbarButtonImageRefresh,
} CNSplitViewToolbarButtonImage;

static CGFloat kCNSplitViewToolbarButtonTextInset = 10.0;
static CGFloat kCNSplitViewToolbarButtonImageInset = 10.0;
static CGFloat kCNSplitViewToolbarButtonImageToTextDistance = 10.0;

static CGFloat kDefaultColorHighlightLevel = 0.42;

#pragma clang diagnostic pop
