//
//  Incrementer.h
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

#import <Foundation/Foundation.h>


typedef NS_ENUM(uint8_t, BuildNumberFormat) {
	InvalidBuildNumberFormat = 0,
	BasicBuildNumberFormat,
	AppleStyleBuildNumberFormat
};

FOUNDATION_EXPORT NSString *const IncrementerReadWriteException;
FOUNDATION_EXPORT NSString *const IncrementerReadWriteExceptionStdoutKey;
FOUNDATION_EXPORT NSString *const IncrementerReadWriteExceptionStderrKey;

FOUNDATION_EXPORT NSString *const IncrementerUnknownFormatException;
FOUNDATION_EXPORT NSString *const IncrementerUnknownFormatExceptionStringKey;


@interface Incrementer : NSObject

- (id)initWithFormat:(BuildNumberFormat)format pathToInfoPlist:(NSString *)pathToInfoPlist startOverOnNewMajorVersion:(BOOL)startOverOnNewMajorVersion;

@property (readonly, copy, nonatomic) NSString *pathToInfoPlist;
@property (readonly, nonatomic) BuildNumberFormat format;
@property (readonly, nonatomic) BOOL startOverOnNewMajorVersion;

- (void)incrementBuildNumber;

@end
