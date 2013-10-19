//
//  BasicBuildNumber.m
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

#import "BasicBuildNumber.h"


@interface BasicBuildNumber ()

@property (nonatomic) NSInteger buildNumber;

@end


@implementation BasicBuildNumber

- (id)init {
	self = [super init];
	
	if (self) {
		_buildNumber = 0;
	}
	
	return self;
}

- (id)initWithBuildNumberString:(NSString *)string {
	self = [super initWithBuildNumberString:string];
	
	if (self) {
		_buildNumber = [string integerValue];
	}
	
	return self;
}

+ (BOOL)isValidString:(NSString *)string {
	if ([string length] == 0) return NO;
	
	return [string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound;
}

- (void)increment {
	self.buildNumber++;
}

- (NSString *)stringValue {
	return [NSString stringWithFormat:@"%ld", (long)self.buildNumber];
}

@end
