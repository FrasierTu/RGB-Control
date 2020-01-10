//
//  NumberOnlyTextField.m
//  RGB Control
//
//  Created by frasier on 1/2/20.
//  Copyright © 2020 Frasier. All rights reserved.
//

#import "NumberOnlyTextField.h"
@interface NumberOnlyTextField ()
    
@property (retain) NSString *oldString;

@end

@implementation NumberOnlyTextField

- (void)textDidChange:(NSNotification *)notification {
    //NSLog(@"%s",__func__);
    NSString *stringValue = self.stringValue;
    
    @autoreleasepool {
        NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        NSMutableString *newString = [NSMutableString stringWithString:@""];
        NSString *zeroCharString = @"0";
        NSInteger stringLength = stringValue.length;
        
        unichar aChar;
        for(NSInteger myIndex = 0; myIndex < stringLength; myIndex++) {
            aChar = [stringValue characterAtIndex:myIndex];
            if(NO == [numberSet characterIsMember:aChar]) {
                continue;
            }
            if([zeroCharString isEqualToString:[NSString stringWithFormat:@"%C",aChar]]) {
                if(myIndex == 0 ) {
                    continue;
                }
            }
            [newString appendString:[NSString stringWithFormat:@"%C",aChar]];
        }
        
        if(newString.integerValue > 32) {
            self.stringValue = self.oldString;
        }
        
        if(self.oldString.length < 1 && self.stringValue.integerValue < 1) {
            self.stringValue = @"";
        }
        self.oldString = self.stringValue;
        
        if((self.stringValue.length > 0) && (self.inputDelegate != nil)) {
            [self.inputDelegate inputChange];
        }
    }
}

@end

@implementation RTextField
@end

@implementation GTextField
@end

@implementation BTextField
@end

@implementation WTextField
@end

