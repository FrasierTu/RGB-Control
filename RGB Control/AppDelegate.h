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

@interface RGB_ControlAppDelegate : NSObject <NSApplicationDelegate> {
@public
    IOHIDDeviceRef rgbwHIDDeviceRef;
}

- (void)startQueryRGBW;
- (IBAction)rgbwSlider:(id)sender;
@end

