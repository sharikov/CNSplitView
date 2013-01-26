//
//  CNBarButtonCell.m
//  SieveMail
//
//  Created by cocoa:naut on 14.08.12.
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


#import "CNSplitViewToolbarButtonCell.h"


static NSGradient *btnGradient, *btnHighlightGradient;
static NSGradient *delimiterLineGradient;
static NSColor *delimiterGradientEndColor, *delimiterGradientCenterColor;
static NSBezierPath *delimiterLine;


@implementation CNSplitViewToolbarButtonCell
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization

+ (void)initialize
{
    btnGradient = [[NSGradient alloc] initWithStartingColor: [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0]
                                                endingColor: [NSColor colorWithCalibratedRed:0.95 green:0.95 blue:0.95 alpha:1.0]];

    btnHighlightGradient = [[NSGradient alloc] initWithStartingColor: [NSColor colorWithCalibratedRed:0.68 green:0.68 blue:0.68 alpha:1.0]
                                                         endingColor: [NSColor colorWithCalibratedRed:0.90 green:0.90 blue:0.90 alpha:1.0]];

    /// button delimiter
    delimiterGradientEndColor = [NSColor colorWithCalibratedRed: 0.78 green: 0.78 blue: 0.78 alpha: 0.1];
    delimiterGradientCenterColor = [NSColor colorWithCalibratedRed: 0.53 green: 0.53 blue: 0.53 alpha: 1];
    delimiterLineGradient = [[NSGradient alloc] initWithColorsAndLocations:
                             delimiterGradientEndColor, 0.0,
                             [NSColor colorWithCalibratedRed: 0.78 green: 0.78 blue: 0.78 alpha: 0.5], 0.10,
                             delimiterGradientCenterColor, 0.50,
                             [NSColor colorWithCalibratedRed: 0.78 green: 0.78 blue: 0.78 alpha: 0.5], 0.90,
                             delimiterGradientEndColor, 1.0, nil];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Drawing

- (void)drawBezelWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
    NSBezierPath *buttonPath = [NSBezierPath bezierPathWithRect:cellFrame];
    switch (self.isHighlighted) {
        case YES: [btnHighlightGradient drawInRect:[buttonPath bounds] angle:-90]; break;
        case NO: [btnGradient drawInRect:[buttonPath bounds] angle:-90]; break;
    }
    [self drawDelimiterForRect:controlView.frame];
}

- (void)drawDelimiterForRect:(NSRect)rect
{
    CGFloat posX = (self.align == CNSplitViewToolbarButtonAlignLeft ? NSWidth(rect) - 1 : 0);
    NSRect delimiterRect = NSMakeRect(posX, rect.origin.y+1, 1.0, NSHeight(rect) - 2);
    delimiterLine = [NSBezierPath bezierPathWithRect:delimiterRect];
    [delimiterLineGradient drawInBezierPath:delimiterLine angle:90];
}

- (void)drawImage:(NSImage*)image withFrame:(NSRect)frame inView:(NSView*)controlView
{
    NSSize imageSize = image.size;
    NSRect imageRect = NSZeroRect;

    /// calculate the rect with given button title
    if (![self.attributedTitle.string isEqualToString:@""]) {
        switch (self.imagePosition) {
            case NSImageRight: {
                imageRect = NSMakeRect(NSWidth(controlView.frame) - imageSize.width - kImageInset, (NSHeight(controlView.frame) - imageSize.height) / 2, imageSize.width, imageSize.height);
                break;
            }

            case NSImageLeft:
            default: {
                imageRect = NSMakeRect(kImageInset, (NSHeight(controlView.frame) - imageSize.height) / 2, imageSize.width, imageSize.height);
                break;
            }
        }
    }
    /// calculate the rect without a given button title
    else {
        imageRect = NSMakeRect((NSWidth(controlView.frame) - imageSize.width) / 2, (NSHeight(controlView.frame) - imageSize.height) / 2, imageSize.width, imageSize.height);
    }

    /// button is enabled
    if (self.isEnabled) {
        switch (self.isHighlighted) {
            case YES:   [image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.90 respectFlipped:YES hints:nil]; break;
            case NO:    [image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.875 respectFlipped:YES hints:nil]; break;
        }
    }
    /// button is disabled
    else {
        [image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:(self.imageDimsWhenDisabled ? 0.40 : 1.00) respectFlipped:YES hints:nil];
    }
}

- (NSRect)drawTitle:(NSAttributedString*)title withFrame:(NSRect)frame inView:(NSView*)controlView
{
    [title drawWithRect:frame options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading];
    return frame;
}

@end
