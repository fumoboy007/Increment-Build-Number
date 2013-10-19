//
//  AppleStyleBuildNumber.m
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

#import "AppleStyleBuildNumber.h"


@interface AppleStyleBuildNumber ()

@property (nonatomic) NSInteger buildNumber;

@end


@implementation AppleStyleBuildNumber

- (id)initWithVersionNumber:(VersionNumber *)versionNumber {
	if (![AppleStyleBuildNumber isValidVersionNumber:versionNumber]) return nil;
	
	self = [super init];
	
	if (self) {
		_majorVersionNumber = versionNumber.majorVersionNumber;
		_minorVersionNumber = versionNumber.minorVersionNumber;
		_buildNumber = 0;
	}
	
	return self;
}

+ (BOOL)isValidVersionNumber:(VersionNumber *)versionNumber {
	return versionNumber.minorVersionNumber <= 'Z' - 'A';
}

- (id)initWithBuildNumberString:(NSString *)string {
	self = [super initWithBuildNumberString:string];
	
	if (self) {
		_majorVersionNumber = [AppleStyleBuildNumber majorVersionNumberFromBuildNumberString:string];
		_minorVersionNumber = [AppleStyleBuildNumber minorVersionNumberFromBuildNumberString:string];
		_buildNumber = [AppleStyleBuildNumber buildNumberFromBuildNumberString:string];
	}
	
	return self;
}

+ (BOOL)isValidString:(NSString *)string {
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d+[a-z]\\d+$" options:NSRegularExpressionCaseInsensitive error:NULL];
	
	return [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] == 1;
}

+ (NSInteger)majorVersionNumberFromBuildNumberString:(NSString *)buildNumberString {
	NSUInteger idx = [buildNumberString rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet] options:0].location;
	
	return [[buildNumberString substringToIndex:idx] integerValue];
}

+ (uint8_t)minorVersionNumberFromBuildNumberString:(NSString *)buildNumberString {
	NSUInteger idx = [buildNumberString rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet] options:0].location;
	
	return [buildNumberString characterAtIndex:idx] - 'A';
}

+ (NSInteger)buildNumberFromBuildNumberString:(NSString *)buildNumberString {
	NSUInteger idx = [buildNumberString rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet] options:NSBackwardsSearch].location;
	
	return [[buildNumberString substringFromIndex:(idx + 1)] integerValue];
}

- (void)increment {
	self.buildNumber++;
}

- (NSString *)stringValue {
	return [NSString stringWithFormat:@"%ld%c%ld", (long)self.majorVersionNumber, 'A' + self.minorVersionNumber, (long)self.buildNumber];
}

@end
