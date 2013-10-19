//
//  VersionNumber.m
//  Increment Build Number
//
//
// The MIT License (MIT)
//
// Copyright (c) 2013 Darren Mo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "VersionNumber.h"


@interface VersionNumber ()

@property (copy, nonatomic) NSString *versionNumberString;

@end


@implementation VersionNumber

- (id)initWithVersionNumberString:(NSString *)string {
	if (![VersionNumber isValidString:string]) return nil;
	
	self = [super init];
	
	if (self) {
		_versionNumberString = [string copy];
		
		
		NSArray *components = [_versionNumberString componentsSeparatedByString:@"."];
		
		_majorVersionNumber = [components[0] integerValue];
		_minorVersionNumber = [components[1] integerValue];
	}
	
	return self;
}

+ (BOOL)isValidString:(NSString *)string {
	NSArray *components = [string componentsSeparatedByString:@"."];
	
	if ([components count] < 2) return NO;
	
	for (NSString *component in components) {
		if ([component length] == 0) return NO;
		if ([component rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound) return NO;
	}
	
	return YES;
}

- (NSString *)stringValue {
	return self.versionNumberString;
}

@end
