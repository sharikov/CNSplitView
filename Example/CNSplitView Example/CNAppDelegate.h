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

@interface CNAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet CNSplitView *splitView;

@property (strong, nonatomic) IBOutlet CNBaseView *firstView;
@property (strong, nonatomic) IBOutlet CNBaseView *secondView;

@property (strong) IBOutlet NSButton *enableDisableToolbarItemsCheckbox;
@property (strong) IBOutlet NSButton *enableDisableToolbarItemsDelimiterCheckbox;
@property (strong) IBOutlet NSButton *centerToolbarItemsCheckbox;


- (IBAction)enableDisableToolbarItemsAction:(id)sender;
- (IBAction)enableDisableToolbarItemsDelimiterAction:(id)sender;
- (IBAction)centerToolbarItemsAction:(id)sender;
@end
