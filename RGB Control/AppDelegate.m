//
//  AppDelegate.m
//  RGB Control
//
//  Created by frasier on 12/25/19.
//  Copyright © 2019 Frasier. All rights reserved.
//

#import "AppDelegate.h"
#include <wchar.h>


static int get_string_property(IOHIDDeviceRef device, CFStringRef prop, wchar_t *buf, size_t len)
{
    CFStringRef str;
    
    if (!len)
        return 0;
    
    str = IOHIDDeviceGetProperty(device, prop);
    
    buf[0] = 0;
    
    if (str) {
        CFIndex str_len = CFStringGetLength(str);
        CFRange range;
        CFIndex used_buf_len;
        CFIndex chars_copied;
        
        len --;
        
        range.location = 0;
        range.length = ((size_t)str_len > len)? len: (size_t)str_len;
        chars_copied = CFStringGetBytes(str,
                                        range,
                                        kCFStringEncodingUTF32LE,
                                        (char)'?',
                                        FALSE,
                                        (UInt8*)buf,
                                        len * sizeof(wchar_t),
                                        &used_buf_len);
        
        if (chars_copied == len)
            buf[len] = 0; /* len is decremented above */
        else
            buf[chars_copied] = 0;
        
        return 0;
    }
    else
        return -1;
    
}

static long USBDeviceCount(IOHIDManagerRef HIDManager){
    
    // The device set includes all USB devices that match our matching dictionary. Fetch it.
    CFSetRef devSet = IOHIDManagerCopyDevices(HIDManager);
    
    // The devSet will be NULL if there are 0 devices, so only try to count the devices if devSet exists
    if(devSet) return CFSetGetCount(devSet);
    
    // There were no matching devices (devSet was NULL), so return a count of 0
    return 0;
}

#if 1
static void ValueCallback(
                          void *context,
                          IOReturn result,
                          void *sender,
                          IOHIDValueRef value )
{
    IOHIDElementRef theElement = IOHIDValueGetElement( value );
    uint32_t usagePage = IOHIDElementGetUsagePage( theElement );
    uint32_t usage = IOHIDElementGetUsage( theElement );
    IOHIDElementCookie cookie = IOHIDElementGetCookie( theElement );
    IOHIDElementType typeCode = IOHIDElementGetType( theElement );
    
    CFIndex intValue = IOHIDValueGetIntegerValue( value );
    double physValue = IOHIDValueGetScaledValue( value,
                                                kIOHIDValueScaleTypePhysical );
    double calibratedValue = IOHIDValueGetScaledValue( value,
                                                      kIOHIDValueScaleTypeCalibrated );
    
    NSLog(@"Element %@ (0x%X, 0x%X, %p, type %d) changed to %d (%f, %f)",
          theElement, (int)usagePage, (int)usage, cookie, (int) typeCode,
          (int)intValue, physValue, calibratedValue );
}

void Handle_DeviceOutgoingData(void* context, IOReturn result, void* sender, IOHIDReportType type, uint32_t reportID, uint8_t *report,CFIndex reportLength) {
    NSLog(@"Handle_DeviceOutgoingData");
}

static void Handle_DeviceMatchingCallback(void *context,
                                          IOReturn inResult,
                                          void *inSender,
                                          IOHIDDeviceRef inIOHIDDeviceRef) {
    NSLog(@"Handle_DeviceMatchingCallback");

#if 0
    IOReturn ret = IOHIDDeviceOpen(inIOHIDDeviceRef, 0L);
    if (ret == kIOReturnSuccess) {
        IOHIDDeviceScheduleWithRunLoop( inIOHIDDeviceRef, CFRunLoopGetMain(),kCFRunLoopDefaultMode );
        char *inputbuffer = malloc(64);
        //IOHIDDeviceGetReportWithCallback(inIOHIDDeviceRef, (uint8_t*)inputbuffer, 64, Handle_DeviceOutgoingData, NULL);
    }
#endif
    
#if 1
    //IOHIDDeviceScheduleWithRunLoop( inIOHIDDeviceRef, CFRunLoopGetMain(),kCFRunLoopDefaultMode );
    IOReturn err = IOHIDDeviceOpen( inIOHIDDeviceRef, kIOHIDOptionsTypeNone );
    NSLog(@"IOHIDDeviceOpen result 0x%08X", err );
    //IOHIDDeviceRegisterInputValueCallback( device, ValueCallback, context );
    
    RGB_ControlAppDelegate *selfObject = (__bridge RGB_ControlAppDelegate *) context;
    
    if (selfObject != nil) {
        selfObject->rgbwHIDDeviceRef = inIOHIDDeviceRef;

        [selfObject.rSlider setEnabled:YES];
        [selfObject.gSlider setEnabled:YES];
        [selfObject.bSlider setEnabled:YES];
        [selfObject.wSlider setEnabled:YES];
        
        [selfObject.rTextField setEnabled:YES];
        [selfObject.gTextField setEnabled:YES];
        [selfObject.bTextField setEnabled:YES];
        [selfObject.wTextField setEnabled:YES];
        
        [selfObject.addButton setEnabled:YES];
        //[selfObject.deleteButton setEnabled:YES];
        
        [selfObject.rgbwTableView deselectAll:nil];

        [selfObject startQueryRGBW: YES];
        
    }
    return;
    UInt8 buffer[16];
    //unsigned long reportSize;
    
    CFIndex returnSize = sizeof(buffer);
    err = IOHIDDeviceGetReport(inIOHIDDeviceRef ,kIOHIDReportTypeFeature ,0 ,buffer ,&returnSize);

    // Let's see if I can get elements and values.
    CFArrayRef elementArray = IOHIDDeviceCopyMatchingElements( inIOHIDDeviceRef,NULL, 0 );
    if ( elementArray != NULL )
    {
        int counter;
        NSArray* elArray = (__bridge NSArray *)elementArray;
        
        counter = 0;
        for (id oneEl in elArray)
        {
            IOHIDElementRef anElement = (__bridge IOHIDElementRef) oneEl;

            uint32_t usage = IOHIDElementGetUsage( anElement );
            IOHIDElementType elType = IOHIDElementGetType( anElement );
            NSLog(@"Element type %d ,usage  %d", (int)elType ,usage);
            /*
            if ( (elType == 1) || (elType == 2) || (elType == 3) )
            {
                IOHIDElementCookie theCookie =
                IOHIDElementGetCookie( anElement );
                CFIndex val = -1;
                IOHIDValueRef valueRef = NULL;
                err = IOHIDDeviceGetValue( inIOHIDDeviceRef, anElement, &valueRef );
                if (err == kIOReturnSuccess)
                {
                    val = IOHIDValueGetIntegerValue( valueRef );
                    NSLog(@"  cookie %p, value %ld", theCookie, val );
                }
                else
                {
                    NSLog(@"  cookie %p, error getting value 0x%08X",
                          theCookie, err );
                }
            }
             */
            if (elType == 257){
                uint32_t reportID = IOHIDElementGetReportID(anElement);
                uint32_t reportSize = IOHIDElementGetReportSize(anElement);
                uint32_t reportCount = IOHIDElementGetReportCount(anElement);
                NSLog(@"report: { ID: %u, Size: %u, Count: %u }, ",reportID, reportSize, reportCount);

                UInt8 buffer[16];
                //unsigned long reportSize;
                
                CFIndex returnSize = sizeof(buffer);
                err = IOHIDDeviceGetReport(inIOHIDDeviceRef ,kIOHIDReportTypeFeature ,0 ,buffer ,&returnSize);
                counter++;
                err = IOHIDDeviceGetReport(inIOHIDDeviceRef ,kIOHIDReportTypeFeature ,0 ,buffer ,&returnSize);
                counter++;
                //IOHIDValueRef tIOHIDValueRef = IOHIDValueCreateWithIntegerValue( kCFAllocatorDefault, tIOHIDElementRef, timestamp, tCFIndex );
                /*
                CFIndex val = -1;
                IOHIDValueRef valueRef = NULL;
                err = IOHIDDeviceGetValue( inIOHIDDeviceRef, anElement, &valueRef );
                if (err == kIOReturnSuccess)
                {
                    val = IOHIDValueGetIntegerValue( valueRef );
                    NSLog(@" value 0x%lx", val );
                }
                else
                {
                }
                err = IOHIDDeviceGetValue( inIOHIDDeviceRef, anElement, &valueRef );
                 */
            }
        }
        NSLog(@" Element type count: 0x0%x", counter );
    }
#endif
}

#else
static void Handle_DeviceMatchingCallback(void *inContext,
                                          IOReturn inResult,
                                          void *inSender,
                                          IOHIDDeviceRef inIOHIDDeviceRef)
    // Log the device ID & device count
    NSLog(@"\nONTRAK device added: %p\nONTRAK device count: %ld",(void *)inIOHIDDeviceRef,USBDeviceCount(inSender));

    int BUF_LEN = 256;
    wchar_t buf[BUF_LEN];
    
    get_string_property(inIOHIDDeviceRef, CFSTR(kIOHIDManufacturerKey), buf, BUF_LEN);
    //NSLog(@"kIOHIDManufacturerKey: %s",buf);
    NSString *string = [[NSString alloc] initWithBytes:buf
                                                length:wcslen(buf)*sizeof(*buf)
                                              encoding:NSUTF32LittleEndianStringEncoding];
    NSLog(@"kIOHIDManufacturerKey: %@",string);
    
    int32_t value;
    CFTypeRef ref = IOHIDDeviceGetProperty(inIOHIDDeviceRef, CFSTR(kIOHIDMaxInputReportSizeKey));
    if (ref) {
        if (CFGetTypeID(ref) == CFNumberGetTypeID()) {
            CFNumberGetValue((CFNumberRef) ref, kCFNumberSInt32Type, &value);
            NSLog(@"kIOHIDMaxInputReportSizeKey: %d",value);
        }
    }
    
    ref = IOHIDDeviceGetProperty(inIOHIDDeviceRef, CFSTR(kIOHIDMaxOutputReportSizeKey));
    if (ref) {
        if (CFGetTypeID(ref) == CFNumberGetTypeID()) {
            CFNumberGetValue((CFNumberRef) ref, kCFNumberSInt32Type, &value);
            NSLog(@"kIOHIDMaxOutputReportSizeKey: %d",value);
        }
    }
    
    //IOHIDElementRef element = IOHIDValueGetElement((IOHIDValueRef)inIOHIDDeviceRef);
    //if(element) {
    //    NSLog(@"IOHIDElementGetType: %d",IOHIDElementGetUsagePage(element));
    //}
}
#endif

static void Handle_DeviceRemovalCallback(void *inContext,
                                         IOReturn inResult,
                                         void *inSender,
                                         IOHIDDeviceRef inIOHIDDeviceRef){
    
    // Log the device ID & device count
    RGB_ControlAppDelegate *selfObject = (__bridge RGB_ControlAppDelegate *) inContext;
    
    @synchronized (selfObject) {
        selfObject->rgbwHIDDeviceRef = NULL;
    }
    //NSLog(@"\ndevice removed: %p\ndevice count: %ld", (void *)inIOHIDDeviceRef,USBDeviceCount(inSender));
    
    // TODO: make sure your application doesn't try to do anything with the removed device
    [selfObject.rSlider setEnabled:NO];
    [selfObject.gSlider setEnabled:NO];
    [selfObject.bSlider setEnabled:NO];
    [selfObject.wSlider setEnabled:NO];
    
    selfObject.rTextField.stringValue = @"";
    selfObject.gTextField.stringValue = @"";
    selfObject.bTextField.stringValue = @"";
    selfObject.wTextField.stringValue = @"";
    
    [selfObject.rTextField setEnabled:NO];
    [selfObject.gTextField setEnabled:NO];
    [selfObject.bTextField setEnabled:NO];
    [selfObject.wTextField setEnabled:NO];
    
    [selfObject.addButton setEnabled:NO];
    [selfObject.deleteButton setEnabled:NO];
    
    [selfObject.rgbwTableView deselectAll:nil];
}

@interface RGB_ControlAppDelegate () <TextFieldProtocol> {
    IOHIDManagerRef hidManager;
}

@property (weak) IBOutlet NSWindow *window;

@property (retain) id isWritingMutex;
@property BOOL isWriting;

@end

@implementation RGB_ControlAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    self.colorView.wantsLayer = YES;
    self->hidManager = IOHIDManagerCreate(kCFAllocatorDefault,kIOHIDOptionsTypeNone);
    
    self.isWriting = NO;
    // Create a Matching Dictionary
    CFMutableDictionaryRef matchDict = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                                 2,
                                                                 &kCFTypeDictionaryKeyCallBacks,
                                                                 &kCFTypeDictionaryValueCallBacks);

    
    int vendorID = 0x04d9;
    int productID = 0x045b;
    
    CFNumberRef cfNumber = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &vendorID);
    if (cfNumber) {
        CFDictionarySetValue(matchDict, CFSTR(kIOHIDVendorIDKey), cfNumber);
        //CFDictionarySetValue(matchDict, CFSTR(kUSBVendorID), cfNumber);
        CFRelease(cfNumber);
    }
    
    cfNumber = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &productID);
    if (cfNumber) {
        CFDictionarySetValue(matchDict, CFSTR(kIOHIDProductIDKey), cfNumber);
        //CFDictionarySetValue(matchDict, CFSTR(kUSBProductID), cfNumber);
        CFRelease(cfNumber);
    }
    
    // Register the Matching Dictionary to the HID Manager
    IOHIDManagerSetDeviceMatching(self->hidManager, matchDict);
    
    // Register a callback for USB device detection with the HID Manager
    IOHIDManagerRegisterDeviceMatchingCallback(self->hidManager, &Handle_DeviceMatchingCallback, (__bridge void *)self);
    // Register a callback fro USB device removal with the HID Manager
    IOHIDManagerRegisterDeviceRemovalCallback(self->hidManager, &Handle_DeviceRemovalCallback, (__bridge void *)self);
    
    //IOHIDManagerRegisterInputReportCallback(self->hidManager, deviceReportCallback, NULL);
    
    //IOHIDManagerRegisterInputValueCallback(self->hidManager, myHIDKeyboardCallback, NULL);
    // Register the HID Manager on our app’s run loop
    IOHIDManagerScheduleWithRunLoop(self->hidManager, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
    
    // Open the HID Manager
    IOReturn IOReturn = IOHIDManagerOpen(self->hidManager, kIOHIDOptionsTypeNone);
    if(IOReturn) NSLog(@"IOHIDManagerOpen failed.");  //  Couldn't open the HID manager! TODO: proper error handling
    
    //[self.rgbwDataArray addObject:@{@"rValue":@(1),@"bValue":@(3)}];
    self.rTextField.inputDelegate = self;
    self.gTextField.inputDelegate = self;
    self.bTextField.inputDelegate = self;
    self.wTextField.inputDelegate = self;
    
    [self.window center];
    
    //
    [self.rSlider setEnabled:NO];
    [self.gSlider setEnabled:NO];
    [self.bSlider setEnabled:NO];
    [self.wSlider setEnabled:NO];

    self.rTextField.stringValue = @"";
    self.gTextField.stringValue = @"";
    self.bTextField.stringValue = @"";
    self.wTextField.stringValue = @"";

    [self.rTextField setEnabled:NO];
    [self.gTextField setEnabled:NO];
    [self.bTextField setEnabled:NO];
    [self.wTextField setEnabled:NO];

    [self.addButton setEnabled:NO];
    [self.deleteButton setEnabled:NO];
    
    [self.rgbwDataArray addObserver:self
                         forKeyPath:@"selectedObjects"
                            options:NSKeyValueObservingOptionNew
                            context:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    IOHIDManagerClose(self->hidManager, kIOHIDOptionsTypeNone);
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"selectedObjects"]) {
        NSArrayController *rgbDataArray = (NSArrayController *)object;
        NSIndexSet *selections = rgbDataArray.selectionIndexes;
        
        if(selections.count < 1) {
            [self.deleteButton setEnabled:NO];
        }
        else {
            [self.deleteButton setEnabled:YES];
        }
    }
}

- (IBAction)rgbwSlider:(NSSlider *)sender {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    BOOL startingDrag = event.type == NSLeftMouseDown;
    BOOL endingDrag = event.type == NSLeftMouseUp;
    //BOOL dragging = event.type == NSLeftMouseDragged;
    if(self->rgbwHIDDeviceRef == NULL) {
        return;
    }
    
    @synchronized (self.isWritingMutex) {
        if(startingDrag) {
            self.isWriting = YES;
        }
    }
    
    if (sender.tag == 1) {
        self.rTextField.stringValue = @(sender.integerValue).stringValue;
        //sender.toolTip = @(sender.integerValue).stringValue;
    }
    if (sender.tag == 2) {
        self.gTextField.stringValue = @(sender.integerValue).stringValue;
    }
    if (sender.tag == 3) {
        self.bTextField.stringValue = @(sender.integerValue).stringValue;
    }
    if (sender.tag == 4) {
        self.wTextField.stringValue = @(sender.integerValue).stringValue;
    }
    
    @synchronized (self.isWritingMutex) {
        if(endingDrag) {
            CFIndex returnSize = 9;//sizeof(buffer);
            UInt8 buffer[16] = {0x55,0xAA,0x06,0x04,0,0,0,0,0};
            
            buffer[4] = self.rSlider.integerValue;
            buffer[5] = self.gSlider.integerValue;
            buffer[6] = self.bSlider.integerValue;
            buffer[7] = self.wSlider.integerValue;
            
            buffer[8] = 0;
            for (NSInteger myIndex = 0; myIndex < 8;myIndex++) {
                buffer[8] += buffer[myIndex];
            }
            
            IOReturn err = IOHIDDeviceSetReport(self->rgbwHIDDeviceRef ,kIOHIDReportTypeOutput ,0 ,buffer ,returnSize);
            if(kIOReturnSuccess != err) {
                return;
            }
            self.isWriting = NO;
        }
    }
}

- (IBAction)openAction:(id)sender {
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    // NSLog(@"Open Panel");
    //set restrictions / allowances...
    [openPanel setAllowsMultipleSelection: NO];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanCreateDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    //only allow images...
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects: @"csv" ,nil ]];
    //open panel as sheet on main window...
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)  {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [[self.rgbwDataArray content] removeAllObjects];
                
                NSString *csvString = [NSString stringWithContentsOfURL:[openPanel URLs].firstObject
                                                               encoding:NSASCIIStringEncoding
                                                                  error:nil];
                NSArray *rgbws = [csvString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
                
                for(NSString *rgbwLine in rgbws) {
                    NSArray *rgbw = [rgbwLine componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
                    NSInteger rValue = ((NSString *)rgbw[0]).intValue;
                    NSInteger gValue = ((NSString *)rgbw[1]).intValue;
                    NSInteger bValue = ((NSString *)rgbw[2]).intValue;
                    NSInteger wValue = ((NSString *)rgbw[3]).intValue;
                    
                    [self.rgbwDataArray addObject:@{@"rValue": @(rValue), @"gValue": @(gValue), @"bValue": @(bValue), @"wValue": @(wValue)}];
                }
            });
        }
    }];
    
}

- (IBAction)addAction:(id)sender {

    NSAlert *alert;
    
    if (self.rTextField.stringValue.length < 1) {
        @autoreleasepool {
            alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Input is not completed"];
            [alert setInformativeText:@"R value"];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)  {
                return;
            }];
        }
    }

    if (self.gTextField.stringValue.length < 1) {
        @autoreleasepool {
            alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Input is not completed"];
            [alert setInformativeText:@"G value"];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)  {
                return;
            }];
        }
    }

    if (self.bTextField.stringValue.length < 1) {
        @autoreleasepool {
            alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Input is not completed"];
            [alert setInformativeText:@"B value"];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)  {
                return;
            }];
        }
    }

    [self.rgbwDataArray addObject:@{@"rValue": @(self.rSlider.integerValue), @"gValue": @(self.gSlider.integerValue), @"bValue": @(self.bSlider.integerValue), @"wValue": @(0)}];
}

- (IBAction)deleteAction:(id)sender {
    NSInteger selection = self.rgbwDataArray.selectionIndex;
    [self.rgbwDataArray removeObjectAtArrangedObjectIndex:selection];
    [self.rgbwTableView deselectAll:nil];
}

- (IBAction)saveAction:(id)sender {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.canCreateDirectories = YES;
    savePanel.showsTagField = NO;
    [savePanel setNameFieldStringValue:@"NewFile.csv"];
    
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)  {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    NSMutableString *csvString = [NSMutableString string];
                    
                    NSArray *rgbwDatas = [self.rgbwDataArray content];
                    for(NSDictionary *rgbw in rgbwDatas) {
                        [csvString appendString:[NSString stringWithFormat:@"%@,%@,%@,%@\n",rgbw[@"rValue"],rgbw[@"gValue"],rgbw[@"bValue"],rgbw[@"wValue"]]];
                    }
                    
                    [csvString writeToURL:savePanel.URL
                               atomically:YES
                                 encoding:NSUTF8StringEncoding
                                    error:nil];
                    
                    [csvString setString:@""];
                }
            });
        }
    }];
    
}

#pragma mark --

- (void)startQueryRGBW:(BOOL)reconnected{
    [self getRGBWValue:reconnected];
}

- (void)getRGBWValue:(BOOL)reconnected {
    @synchronized (self) {
        if(self->rgbwHIDDeviceRef == NULL) {
            return;
        }
        
        if (reconnected) {
            UInt8 buffer[16];
            //unsigned long reportSize;
            
            CFIndex returnSize = sizeof(buffer);
            IOReturn err = IOHIDDeviceGetReport(self->rgbwHIDDeviceRef ,kIOHIDReportTypeFeature ,0 ,buffer ,&returnSize);
            if(kIOReturnSuccess != err) {
                return;
            }
            
            self.rTextField.stringValue = @(buffer[4]).stringValue;
            self.gTextField.stringValue = @(buffer[5]).stringValue;
            self.bTextField.stringValue = @(buffer[6]).stringValue;
            self.wTextField.stringValue = @(buffer[7]).stringValue;
            //NSLog(@"R: %d,G: %d,B: %d,W: %d",buffer[4] ,buffer[5],buffer[6],buffer[7]);
            
            self.rSlider.integerValue = buffer[4];
            self.gSlider.integerValue = buffer[5];
            self.bSlider.integerValue = buffer[6];
            self.wSlider.integerValue = buffer[7];
            
            self.colorView.layer.backgroundColor = [NSColor colorWithCalibratedRed:(float)buffer[4] / 32
                                                                             green:(float)buffer[5] / 32
                                                                              blue:(float)buffer[6] / 32
                                                                             alpha:1.0].CGColor;

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                [self getRGBWValue:NO];
            });
        }
        @synchronized (self.isWritingMutex) {
            if(self.isWriting) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                    [self getRGBWValue:NO];
                });
                return;
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            UInt8 buffer[16];
            //unsigned long reportSize;
            
            CFIndex returnSize = sizeof(buffer);
            IOReturn err = IOHIDDeviceGetReport(self->rgbwHIDDeviceRef ,kIOHIDReportTypeFeature ,0 ,buffer ,&returnSize);
            if(kIOReturnSuccess != err) {
                return;
            }
            
            if(self.rTextField.stringValue.length > 0) {
                self.rTextField.stringValue = @(buffer[4]).stringValue;
            }
            if(self.gTextField.stringValue.length > 0) {
                self.gTextField.stringValue = @(buffer[5]).stringValue;
            }
            if(self.bTextField.stringValue.length > 0) {
                self.bTextField.stringValue = @(buffer[6]).stringValue;
            }
            if(self.wTextField.stringValue.length > 0) {
                //self.wTextField.stringValue = @(buffer[7]).stringValue;
            }
            //NSLog(@"R: %d,G: %d,B: %d,W: %d",buffer[4] ,buffer[5],buffer[6],buffer[7]);
            
            self.rSlider.integerValue = buffer[4];
            self.gSlider.integerValue = buffer[5];
            self.bSlider.integerValue = buffer[6];
            
            self.colorView.layer.backgroundColor = [NSColor colorWithCalibratedRed:(float)buffer[4] / 32
                                                                             green:(float)buffer[5] / 32
                                                                              blue:(float)buffer[6] / 32
                                                                             alpha:1.0].CGColor;
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, USEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self getRGBWValue:NO];;
        });
    }
}

- (void)inputChange {//:(NSWindow *)parentWin;
    if(self->rgbwHIDDeviceRef == NULL) {
        return;
    }
    
    @synchronized (self.isWritingMutex) {
        self.isWriting = YES;
    }
    
    if(self.rTextField.stringValue.length < 1) {
        @synchronized (self.isWritingMutex) {
            self.isWriting = NO;
            return;
        }
    }
    if(self.gTextField.stringValue.length < 1) {
        @synchronized (self.isWritingMutex) {
            self.isWriting = NO;
            return;
        }
    }
    if(self.bTextField.stringValue.length < 1) {
        @synchronized (self.isWritingMutex) {
            self.isWriting = NO;
            return;
        }
    }
    /*
    if(self.wTextField.stringValue.length < 1) {
        @synchronized (self.isWritingMutex) {
            self.isWriting = NO;
            return;
        }
    }
    */
    @synchronized (self.isWritingMutex) {
        CFIndex returnSize = 9;//sizeof(buffer);
        UInt8 buffer[16] = {0x55,0xAA,0x06,0x04,0,0,0,0,0};
        
        buffer[4] = self.rTextField.stringValue.integerValue;
        buffer[5] = self.gTextField.stringValue.integerValue;
        buffer[6] = self.bTextField.stringValue.integerValue;
        buffer[7] = 0;//self.wTextField.stringValue.integerValue;
        
        buffer[8] = 0;
        for (NSInteger myIndex = 0; myIndex < 8;myIndex++) {
            buffer[8] += buffer[myIndex];
        }
        
        IOReturn err = IOHIDDeviceSetReport(self->rgbwHIDDeviceRef ,kIOHIDReportTypeOutput ,0 ,buffer ,returnSize);
        if(kIOReturnSuccess != err) {
            return;
        }
        self.isWriting = NO;
    }

}

@end
