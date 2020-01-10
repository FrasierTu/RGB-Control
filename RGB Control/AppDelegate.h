//
//  AppDelegate.h
//  RGB Control
//
//  Created by frasier on 12/25/19.
//  Copyright © 2019 Frasier. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hid/IOHIDManager.h>
#include <IOKit/usb/IOUSBLib.h>

#import "NumberOnlyTextField.h"

@interface RGB_ControlAppDelegate : NSObject <NSApplicationDelegate> {
@public
    IOHIDDeviceRef rgbwHIDDeviceRef;
}
@property IBOutlet RTextField *rTextField;
@property IBOutlet GTextField *gTextField;
@property IBOutlet BTextField *bTextField;
@property IBOutlet WTextField *wTextField;

@property IBOutlet NSView *colorView;

@property IBOutlet NSSlider *rSlider;
@property IBOutlet NSSlider *gSlider;
@property IBOutlet NSSlider *bSlider;
@property IBOutlet NSSlider *wSlider;

@property IBOutlet NSButton *addButton;
@property IBOutlet NSButton *deleteButton;

@property IBOutlet NSArrayController *rgbwDataArray;

@property IBOutlet NSTableView *rgbwTableView;

- (void)startQueryRGBW:(BOOL)reconnected;
- (IBAction)rgbwSlider:(id)sender;
- (IBAction)openAction:(id)sender;
- (IBAction)addAction:(id)sender;
- (IBAction)deleteAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end

