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
        [selfObject startQueryRGBW];
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
    NSLog(@"\ndevice removed: %p\ndevice count: %ld", (void *)inIOHIDDeviceRef,USBDeviceCount(inSender));
    
    // TODO: make sure your application doesn't try to do anything with the removed device
}

@interface RGB_ControlAppDelegate () {
    IOHIDManagerRef hidManager;
}

@property (weak) IBOutlet NSWindow *window;

@property IBOutlet NSTextField *rTextField;
@property IBOutlet NSTextField *gTextField;
@property IBOutlet NSTextField *bTextField;

@property IBOutlet NSView *colorView;

@property IBOutlet NSSlider *rSlider;
@property IBOutlet NSSlider *gSlider;
@property IBOutlet NSSlider *bSlider;

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
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    IOHIDManagerClose(self->hidManager, kIOHIDOptionsTypeNone);
}

- (IBAction)rgbwSlider:(NSSlider *)sender {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    BOOL startingDrag = event.type == NSLeftMouseDown;
    BOOL endingDrag = event.type == NSLeftMouseUp;
    //BOOL dragging = event.type == NSLeftMouseDragged;

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
    
    @synchronized (self.isWritingMutex) {
        if(endingDrag) {
            [self setRGBWValue];
            self.isWriting = NO;
        }
    }
}

- (void)startQueryRGBW {
    [self getRGBWValue];
}

- (void)getRGBWValue {
    @synchronized (self) {
        if(self->rgbwHIDDeviceRef == NULL) {
            return;
        }
        
        @synchronized (self.isWritingMutex) {
            if(self.isWriting) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                    [self getRGBWValue];
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
            
            //NSLog(@"R: %d,G: %d,B: %d,W: %d",buffer[4] ,buffer[5],buffer[6],buffer[7]);
            self.rTextField.stringValue = @(buffer[4]).stringValue;
            self.gTextField.stringValue = @(buffer[5]).stringValue;
            self.bTextField.stringValue = @(buffer[6]).stringValue;
            
            self.rSlider.integerValue = buffer[4];
            self.gSlider.integerValue = buffer[5];
            self.bSlider.integerValue = buffer[6];
            
            self.colorView.layer.backgroundColor = [NSColor colorWithCalibratedRed:(float)buffer[4] / 32
                                                                             green:(float)buffer[5] / 32
                                                                              blue:(float)buffer[6] / 32
                                                                             alpha:1.0].CGColor;
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, USEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self getRGBWValue];
        });
    }
}

- (void)setRGBWValue {
    @synchronized (self) {
        if(self->rgbwHIDDeviceRef == NULL) {
            return;
        }
        
        CFIndex returnSize = 9;//sizeof(buffer);
        UInt8 buffer[16] = {0x55,0xAA,0x06,0x04,0,0,0,0,0};
        
        buffer[4] = self.rSlider.integerValue;
        buffer[5] = self.gSlider.integerValue;
        buffer[6] = self.bSlider.integerValue;
        buffer[7] = 0;
        
        buffer[8] = 0;
        for (NSInteger myIndex = 0; myIndex < 8;myIndex++) {
            buffer[8] += buffer[myIndex];
        }
        
        IOReturn err = IOHIDDeviceSetReport(self->rgbwHIDDeviceRef ,kIOHIDReportTypeOutput ,0 ,buffer ,returnSize);
        if(kIOReturnSuccess != err) {
            return;
        }
    }
}

@end
