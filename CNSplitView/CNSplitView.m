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

NSString *CNSplitViewInjectReferenceNotification    = @"InjectReference";
NSString *CNSplitViewWillShowToolbarNotification    = @"SplitViewWillShowToolbar";
NSString *CNSplitViewDidShowToolbarNotification     = @"SplitViewDidShowToolbar";
NSString *CNSplitViewWillHideToolbarNotification    = @"SplitViewWillHideToolbar";
NSString *CNSplitViewDidHideToolbarNotification     = @"SplitViewDidHideToolbar";

NSString *CNUserInfoToolbarKey = @"toolbar";
NSString *CNUserInfoEdgeKey = @"edge";


@interface CNSplitView () {
    NSMutableArray *_toolbars;
    NSUInteger draggingToolbarIndex;
}
@property (assign, nonatomic) id<NSSplitViewDelegate> secondaryDelegate;
@end

@implementation CNSplitView
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization

+ (void)initialize
{
    kDefaultDeviderColor = [NSColor colorWithCalibratedRed:0.50 green:0.50 blue:0.50 alpha:1.0];
    kDefaultAnimationDuration = 0.10;
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
    
    _toolbars = [NSMutableArray array];
    
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configuring & Handling Toolbars

- (void)attachToolbar:(CNSplitViewToolbar *)theToolbar toSubViewAtIndex:(NSUInteger)dividerIndex onEdge:(CNSplitViewToolbarEdge)anchorEdge
{
    /// via notification we inject a refernce to ourself into the toolbar
    [[NSNotificationCenter defaultCenter] postNotificationName:CNSplitViewInjectReferenceNotification object:self];
    
    NSView *anchoredView = [[self subviews] objectAtIndex:dividerIndex];
    [anchoredView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    /// we need a new container view for our toolbar + anchoredView
    NSView *toolbarContainer = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(anchoredView.frame), NSHeight(anchoredView.frame))];
    [toolbarContainer setWantsLayer:YES];
    [toolbarContainer setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [self replaceSubview:anchoredView with:toolbarContainer];
    
    theToolbar.delegate = self;
    theToolbar.anchorEdge = anchorEdge;
    CGFloat posY = (theToolbar.anchorEdge == CNSplitViewToolbarEdgeBottom ? NSMinY(anchoredView.frame) - theToolbar.height : NSHeight(anchoredView.frame));
    [theToolbar setFrame:NSMakeRect(0, posY, NSWidth(anchoredView.frame), theToolbar.height)];
    
    NSRect anchoredViewRect = NSMakeRect(0, 0, NSWidth(anchoredView.frame), NSHeight(anchoredView.frame));
    anchoredView.frame = anchoredViewRect;
    
    [toolbarContainer addSubview:theToolbar];
    [toolbarContainer addSubview:anchoredView];
    
    theToolbar.attachedSubviewIndex = dividerIndex;
    theToolbar.anchoredView = anchoredView;
    theToolbar.toolbarContainer = toolbarContainer;
    theToolbar.dividerColor = kDefaultDeviderColor;
    theToolbar.draggingHandleEnabled = NO;
    theToolbar.toolbarIsVisible = NO;
    theToolbar.shouldAnimate = NO;
    theToolbar.animationIsRunning = NO;
    theToolbar.toolbarIndex = _toolbars.count;
    theToolbar.dividerIndex = dividerIndex;
    
    [_toolbars addObject:theToolbar];
    
}

- (void)showToolbarAnimated:(BOOL)animated forToolbar:(CNSplitViewToolbar *)theToolbar
{
    
    if (theToolbar.animationIsRunning)
        return;
    
    __block CGFloat posY;
    theToolbar.animationIsRunning = YES;
    
    /// inform the delegate
    [self splitView:self willShowToolbar:theToolbar onEdge:theToolbar.anchorEdge];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = (animated ? kDefaultAnimationDuration : 0.01);
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        NSUInteger toolbarCount = [self numberOfToolbarsForView:theToolbar.attachedSubviewIndex];
        
        posY = (theToolbar.anchorEdge == CNSplitViewToolbarEdgeBottom ? NSMinY(theToolbar.anchoredView.frame) + theToolbar.height : 0);
        NSRect adjustedAnchoredViewRect = NSMakeRect(NSMinX(theToolbar.anchoredView.frame),
                                                     posY,
                                                     NSWidth(theToolbar.anchoredView.frame),
                                                     NSHeight(theToolbar.anchoredView.frame) - theToolbar.height * toolbarCount);
        [[theToolbar.anchoredView animator] setFrame:adjustedAnchoredViewRect];
        
        /// place the toolbar
        posY = (theToolbar.anchorEdge == CNSplitViewToolbarEdgeBottom ? 0 : NSHeight(theToolbar.anchoredView.superview.frame) - theToolbar.height);
        NSPoint adjustedToolbarOrigin = NSMakePoint(NSMinX(theToolbar.frame), posY);
        
        NSLog(@"BEFORE: %f  AFTER: %f  DIFFERENCE: %f:",theToolbar.anchoredView.frame.size.height, adjustedAnchoredViewRect.size.height, theToolbar.anchoredView.frame.size.height - adjustedAnchoredViewRect.size.height );
        [[theToolbar animator] setFrameOrigin:adjustedToolbarOrigin];
        
    } completionHandler:^{
        theToolbar.toolbarIsVisible = YES;
        theToolbar.animationIsRunning = NO;
        
        
        /// inform the delegate
        [self splitView:self didShowToolbar:theToolbar onEdge:theToolbar.anchorEdge];
    }];
}

- (void)showHideToolbarsAnimated:(BOOL)animated show:(BOOL)showing forSubViewAtIndex:(NSUInteger)dividerIndex
{
    
    NSArray *toolbars = [self retrieveToolbarsForIndex:dividerIndex];
    
    if (toolbars.count == 0) {
        return;
    }
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = (animated ? kDefaultAnimationDuration : 0.01);
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        float posY = 0;
        NSRect adjustedAnchoredViewRect;
        
        CNSplitViewToolbar *mainToolbar = toolbars[0];
        float toolbarHeight = mainToolbar.height;
        
        for (CNSplitViewToolbar *toolbar in toolbars) {
            
            toolbar.animationIsRunning = YES;
            
            float toolbarPosY = 0;
            if (toolbar.anchorEdge == CNSplitViewToolbarEdgeBottom) {
                
                posY =  (showing) ? NSMinY(toolbar.anchoredView.frame) + toolbarHeight : 0;
                toolbarPosY = (showing) ? NSMinY(toolbar.anchoredView.frame) : NSMinY(toolbar.anchoredView.frame) - (toolbarHeight * toolbars.count);
                
            } else {
                
                toolbarPosY = (showing) ? NSHeight(toolbar.anchoredView.superview.frame) - toolbarHeight : NSHeight(toolbar.anchoredView.superview.frame) + toolbarHeight;
                
            }
            
            NSPoint adjustedToolbarOrigin = NSMakePoint(NSMinX(toolbar.frame), toolbarPosY);
            
            [[toolbar animator] setFrameOrigin:adjustedToolbarOrigin];
            
        }
                
        float anchoredViewHeight = (showing) ? NSHeight(mainToolbar.anchoredView.frame) - (toolbarHeight * toolbars.count) : NSHeight(mainToolbar.anchoredView.superview.frame);
        adjustedAnchoredViewRect = NSMakeRect(NSMinX(mainToolbar.anchoredView.frame),
                                              posY,
                                              NSWidth(mainToolbar.anchoredView.frame),
                                              anchoredViewHeight);
        
        [[mainToolbar.anchoredView animator] setFrame:adjustedAnchoredViewRect];
        
        
    } completionHandler:^{
        
        for (CNSplitViewToolbar *toolbar in toolbars) {
            
            toolbar.toolbarIsVisible = YES;
            toolbar.animationIsRunning = NO;
            
            /// inform the delegate
            [self splitView:self didShowToolbar:toolbar onEdge:toolbar.anchorEdge];
        }
        
        
        
    }];
    
    
}

- (NSArray *) retrieveToolbarsForIndex:(NSUInteger)index
{
    
    __block NSMutableArray *toolbars = [NSMutableArray array];
    
    [_toolbars enumerateObjectsUsingBlock:^(CNSplitViewToolbar *toolbar, NSUInteger idx, BOOL *stop){
        
        if (toolbar.attachedSubviewIndex == index) {
            
            [toolbars addObject:toolbar];
            
        }
        
        
    }];
    
    return toolbars;
    
}

- (void)hideToolbarAnimated:(BOOL)animated forToolbar:(CNSplitViewToolbar *)theToolbar
{
    
    if (theToolbar.animationIsRunning)
        return;
    
    __block CGFloat posY;
    theToolbar.animationIsRunning = YES;
    
    /// inform the delegate
    [self splitView:self willHideToolbar:theToolbar onEdge:theToolbar.anchorEdge];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = (animated ? kDefaultAnimationDuration : 0.01);
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        NSUInteger toolbarCount = [self numberOfToolbarsForView:theToolbar.attachedSubviewIndex];
        
        posY = (theToolbar.anchorEdge == CNSplitViewToolbarEdgeBottom ? NSMinY(theToolbar.anchoredView.frame) - theToolbar.height : 0);
        NSRect adjustedAnchoredViewRect = NSMakeRect(NSMinX(theToolbar.anchoredView.frame),
                                                     posY,
                                                     NSWidth(theToolbar.anchoredView.frame),
                                                     NSHeight(theToolbar.anchoredView.frame) + theToolbar.height * toolbarCount);
        [[theToolbar.anchoredView animator] setFrame:adjustedAnchoredViewRect];
        
        /// place the toolbar
        posY = (theToolbar.anchorEdge == CNSplitViewToolbarEdgeBottom ? - theToolbar.height : NSHeight(theToolbar.anchoredView.frame) + theToolbar.height);
        NSPoint adjustedToolbarOrigin = NSMakePoint(NSMinX(theToolbar.frame), posY);
        [[theToolbar animator] setFrameOrigin:adjustedToolbarOrigin];
        
    } completionHandler:^{
        theToolbar.toolbarIsVisible = NO;
        theToolbar.animationIsRunning = NO;
        
        /// inform the delegate
        [self splitView:self didHideToolbar:theToolbar onEdge:theToolbar.anchorEdge];
    }];
}

- (void)toggleToolbarAnimated:(BOOL)animated forToolbar:(CNSplitViewToolbar *)theToolbar
{
    
    if (theToolbar.toolbarIsVisible) {
        [self hideToolbarAnimated:animated forToolbar:theToolbar];
    } else {
        [self showToolbarAnimated:animated forToolbar:theToolbar];
    }
}

- (NSUInteger) numberOfToolbarsForView:(NSUInteger)subviewIndex
{
    
    __block NSUInteger toolbarCount = 0;
    
    [_toolbars enumerateObjectsUsingBlock:^(CNSplitViewToolbar *toolbarItem, NSUInteger idx, BOOL *stop){
        
        if (toolbarItem.attachedSubviewIndex == subviewIndex) {
            
            toolbarCount++;
            
        }
        
    }];
    
    return toolbarCount;
    
    
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors

- (void)setDeviderColor:(NSColor *)theColor forToolbar:(CNSplitViewToolbar *)theToolbar
{
    
    theToolbar.dividerColor = theColor;
    
}

- (void)setDraggingHandleEnabledForToolbar:(CNSplitViewToolbar *)theToolbar enabled:(BOOL)draggingHandleEnabled
{
    
    _draggingHandleEnabled = draggingHandleEnabled;
    draggingToolbarIndex = theToolbar.toolbarIndex;
    [theToolbar setDraggingHandleEnabled:draggingHandleEnabled];
    
    
}

- (void)setVertical:(BOOL)flag
{
    [super setVertical:flag];
    [self adjustSubviews];
    [_toolbars[draggingToolbarIndex] setDraggingHandleEnabled:_draggingHandleEnabled];
}

- (void)setDelegate:(id<NSSplitViewDelegate>)delegate
{
    _secondaryDelegate = delegate;
    [super setDelegate:self];
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

//- (NSColor *)dividerColor
//{
//    return _dividerColor;
//}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSSplitView Delegate

- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex
{
    
    return [_toolbars[draggingToolbarIndex] splitView:splitView additionalEffectiveRectOfDividerAtIndex:dividerIndex];
    
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
    if ([self.secondaryDelegate respondsToSelector:_cmd]) {
        return [self.secondaryDelegate splitView:splitView constrainMinCoordinate:proposedMin ofSubviewAt:dividerIndex];
    }
    return proposedMin;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
    if ([self.secondaryDelegate respondsToSelector:_cmd]) {
        return [self.secondaryDelegate splitView:splitView constrainMaxCoordinate:proposedMax ofSubviewAt:dividerIndex];
    }
    return proposedMax;
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    if ([self.secondaryDelegate respondsToSelector:_cmd]) {
        return [self.secondaryDelegate splitView:splitView canCollapseSubview:subview];
    }
    return NO;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
    if ([self.secondaryDelegate respondsToSelector:_cmd]) {
        return [self.secondaryDelegate splitView:splitView shouldCollapseSubview:subview forDoubleClickOnDividerAtIndex:dividerIndex];
    }
    return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex
{
    if ([self.secondaryDelegate respondsToSelector:_cmd]) {
        return [self.secondaryDelegate splitView:splitView constrainSplitPosition:proposedPosition ofSubviewAt:dividerIndex];
    }
    return proposedPosition;
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
    if ([self.secondaryDelegate respondsToSelector:_cmd]) {
        [self.secondaryDelegate splitView:splitView resizeSubviewsWithOldSize:oldSize];
    }
    else {
        [self adjustSubviews];
    }
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
{
    if ([self.secondaryDelegate respondsToSelector:_cmd]) {
        return [self.secondaryDelegate splitView:splitView shouldAdjustSizeOfSubview:view];
    }
    return YES;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
    if ([self.secondaryDelegate respondsToSelector:_cmd]) {
        return [self.secondaryDelegate splitView:splitView shouldHideDividerAtIndex:dividerIndex];
    }
    return NO;
}

- (NSRect)splitView:(NSSplitView *)splitView effectiveRect:(NSRect)proposedEffectiveRect forDrawnRect:(NSRect)drawnRect ofDividerAtIndex:(NSInteger)dividerIndex
{
    if ([self.secondaryDelegate respondsToSelector:_cmd]) {
        return [self.secondaryDelegate splitView:splitView effectiveRect:proposedEffectiveRect forDrawnRect:drawnRect ofDividerAtIndex:dividerIndex];
    }
    return proposedEffectiveRect;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CNSplitView Delegate

- (void)splitView:(CNSplitView *)theSplitView willShowToolbar:(CNSplitViewToolbar *)theToolbar onEdge:(CNSplitViewToolbarEdge)theEdge
{
    NSDictionary *userInfo = @{ CNUserInfoToolbarKey: theToolbar, CNUserInfoEdgeKey: [NSNumber numberWithInteger:theEdge] };
    [[NSNotificationCenter defaultCenter] postNotificationName:CNSplitViewWillShowToolbarNotification object:self userInfo:userInfo];
    
    if ([self.toolbarDelegate respondsToSelector:_cmd]) {
        [self.toolbarDelegate splitView:theSplitView willShowToolbar:theToolbar onEdge:theEdge];
    }
}

- (void)splitView:(CNSplitView *)theSplitView didShowToolbar:(CNSplitViewToolbar *)theToolbar onEdge:(CNSplitViewToolbarEdge)theEdge
{
    NSDictionary *userInfo = @{ CNUserInfoToolbarKey: theToolbar, CNUserInfoEdgeKey: [NSNumber numberWithInteger:theEdge] };
    [[NSNotificationCenter defaultCenter] postNotificationName:CNSplitViewDidShowToolbarNotification object:self userInfo:userInfo];
    
    if ([self.toolbarDelegate respondsToSelector:_cmd]) {
        [self.toolbarDelegate splitView:theSplitView didShowToolbar:theToolbar onEdge:theEdge];
    }
}

- (void)splitView:(CNSplitView *)theSplitView willHideToolbar:(CNSplitViewToolbar *)theToolbar onEdge:(CNSplitViewToolbarEdge)theEdge
{
    NSDictionary *userInfo = @{ CNUserInfoToolbarKey: theToolbar, CNUserInfoEdgeKey: [NSNumber numberWithInteger:theEdge] };
    [[NSNotificationCenter defaultCenter] postNotificationName:CNSplitViewWillHideToolbarNotification object:self userInfo:userInfo];
    
    if ([self.toolbarDelegate respondsToSelector:_cmd]) {
        [self.toolbarDelegate splitView:theSplitView willHideToolbar:theToolbar onEdge:theEdge];
    }
}

- (void)splitView:(CNSplitView *)theSplitView didHideToolbar:(CNSplitViewToolbar *)theToolbar onEdge:(CNSplitViewToolbarEdge)theEdge
{
    NSDictionary *userInfo = @{ CNUserInfoToolbarKey: theToolbar, CNUserInfoEdgeKey: [NSNumber numberWithInteger:theEdge] };
    [[NSNotificationCenter defaultCenter] postNotificationName:CNSplitViewDidHideToolbarNotification object:self userInfo:userInfo];
    
    if ([self.toolbarDelegate respondsToSelector:_cmd]) {
        [self.toolbarDelegate splitView:theSplitView didHideToolbar:theToolbar onEdge:theEdge];
    }
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CNToolbar Delegate

- (NSUInteger)toolbarAttachedSubviewIndex:(CNSplitViewToolbar *)theToolbar
{
    
    return theToolbar.attachedSubviewIndex;
    
}



@end
