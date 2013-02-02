//
//  CNAppDelegate.h
//  CNSplitView Example
//
//  Created by Frank Gregor on 03.01.13.
//  Copyright (c) 2013 cocoa:naut. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CNBaseView.h"
#import "CNSplitView.h"

@interface CNAppDelegate : NSObject <NSApplicationDelegate, CNSplitViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet CNSplitView *splitView;

@property (assign, nonatomic) IBOutlet CNBaseView *firstView;
@property (assign, nonatomic) IBOutlet CNBaseView *secondView;

@property (assign) IBOutlet NSButton *showHideToolbarCheckbox;
@property (assign) IBOutlet NSButton *useAnimationsCheckbox;
@property (assign) IBOutlet NSButton *enableDisableToolbarItemsCheckbox;
@property (assign) IBOutlet NSButton *enableDisableToolbarItemsDelimiterCheckbox;
@property (assign) IBOutlet NSButton *centerToolbarItemsCheckbox;
@property (assign) IBOutlet NSButton *draggingHandleEnabledCheckbox;
@property (assign) IBOutlet NSPopUpButton *splitViewOrientationPopUp;


- (IBAction)showHideToolbarAction:(id)sender;
- (IBAction)useAnimationsAction:(id)sender;
- (IBAction)enableDisableToolbarItemsAction:(id)sender;
- (IBAction)enableDisableToolbarItemsDelimiterAction:(id)sender;
- (IBAction)centerToolbarItemsAction:(id)sender;
- (IBAction)draggingHandleEnabledAction:(id)sender;
- (IBAction)splitViewOrientationAction:(id)sender;
@end
