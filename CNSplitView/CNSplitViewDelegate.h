//
//  CNSplitViewDelegate.h
//
//  Created by Frank Gregor on 02.02.13.
//  Copyright (c) 2013 cocoa:naut. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CNSplitView, CNSplitViewToolbar;

@protocol CNSplitViewDelegate <NSSplitViewDelegate>
@optional

/**
 ...
 */
- (void)splitView:(CNSplitView *)theSplitView willShowToolbar:(CNSplitViewToolbar *)theToolbar onEdge:(CNSplitViewToolbarEdge)theEdge;

/**
 ...
 */
- (void)splitView:(CNSplitView *)theSplitView didShowToolbar:(CNSplitViewToolbar *)theToolbar onEdge:(CNSplitViewToolbarEdge)theEdge;

/**
 ...
 */
- (void)splitView:(CNSplitView *)theSplitView willHideToolbar:(CNSplitViewToolbar *)theToolbar onEdge:(CNSplitViewToolbarEdge)theEdge;

/**
 ...
 */
- (void)splitView:(CNSplitView *)theSplitView didHideToolbar:(CNSplitViewToolbar *)theToolbar onEdge:(CNSplitViewToolbarEdge)theEdge;

@end
