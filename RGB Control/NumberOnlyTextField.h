//
//  NumberOnlyTextField.h
//  RGB Control
//
//  Created by frasier on 1/2/20.
//  Copyright © 2020 Frasier. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol TextFieldProtocol <NSObject>

- (void)inputChange;//:(NSWindow *)parentWin;

@end


@interface NumberOnlyTextField : NSTextField
@property (nonatomic, weak) id <TextFieldProtocol> inputDelegate;
@end

@interface RTextField : NumberOnlyTextField

@end

@interface GTextField : NumberOnlyTextField

@end

@interface BTextField : NumberOnlyTextField

@end

@interface WTextField : NumberOnlyTextField

@end

