//
//  Incrementer.m
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

#import "Incrementer.h"
#import "VersionNumber.h"
#import "BuildNumber.h"
#import "BasicBuildNumber.h"
#import "AppleStyleBuildNumber.h"


NSString *const IncrementerReadWriteException = @"IncrementerReadWriteException";
NSString *const IncrementerReadWriteExceptionStdoutKey = @"stdout";
NSString *const IncrementerReadWriteExceptionStderrKey = @"stderr";

NSString *const IncrementerUnknownFormatException = @"IncrementerUnknownFormatException";
NSString *const IncrementerUnknownFormatExceptionStringKey = @"string";


@interface Incrementer ()

@property (copy, nonatomic) NSString *pathToInfoPlist;
@property (nonatomic) BuildNumberFormat format;
@property (nonatomic) BOOL startOverOnNewMajorVersion;

@property (strong, nonatomic) VersionNumber *versionNumber;
@property (strong, nonatomic) BuildNumber *buildNumber;

@end


@implementation Incrementer

- (id)initWithFormat:(BuildNumberFormat)format pathToInfoPlist:(NSString *)pathToInfoPlist startOverOnNewMajorVersion:(BOOL)startOverOnNewMajorVersion {
	self = [super init];
	
	if (self) {
		_pathToInfoPlist = [pathToInfoPlist copy];
		_format = format;
		_startOverOnNewMajorVersion = startOverOnNewMajorVersion;
		
		[self retrieveExistingVersion];
		[self retrieveExistingBuildNumber];
	}
	
	return self;
}

#pragma mark - Retrieving/verifying existing values

- (void)retrieveExistingVersion {
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:@"/usr/libexec/PlistBuddy"];
	[task setArguments:@[@"-c", @"Print :CFBundleShortVersionString", self.pathToInfoPlist]];
	
	NSPipe *outputPipe = [[NSPipe alloc] init];
	[task setStandardOutput:outputPipe];
	
	NSPipe *errorPipe = [[NSPipe alloc] init];
	[task setStandardError:errorPipe];
	
	[task launch];
	[task waitUntilExit];
	
	
	NSFileHandle *outputFileHandle = [outputPipe fileHandleForReading];
	NSString *output = [[NSString alloc] initWithData:[outputFileHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	
	if ([task terminationStatus] != 0) {
		NSFileHandle *errorFileHandle = [errorPipe fileHandleForReading];
		NSString *errorOutput = [[NSString alloc] initWithData:[errorFileHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
		
		NSString *reason = [NSString stringWithFormat:@"PlistBuddy returned %i while trying to read CFBundleShortVersionString.", [task terminationStatus]];
		NSDictionary *userInfo = @{IncrementerReadWriteExceptionStdoutKey: output, IncrementerReadWriteExceptionStderrKey: errorOutput};
		
		@throw [NSException exceptionWithName:IncrementerReadWriteException reason:reason userInfo:userInfo];
	}
	
	output = [output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	
	self.versionNumber = [[VersionNumber alloc] initWithVersionNumberString:output];
	
	if (!self.versionNumber) {
		NSString *reason = @"Unknown format for existing version string.";
		NSDictionary *userInfo = @{IncrementerUnknownFormatExceptionStringKey: output};
		
		@throw [NSException exceptionWithName:IncrementerUnknownFormatException reason:reason userInfo:userInfo];
	}
}

- (void)retrieveExistingBuildNumber {
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:@"/usr/libexec/PlistBuddy"];
	[task setArguments:@[@"-c", @"Print :CFBundleVersion", self.pathToInfoPlist]];
	
	NSPipe *outputPipe = [[NSPipe alloc] init];
	[task setStandardOutput:outputPipe];
	
	NSPipe *errorPipe = [[NSPipe alloc] init];
	[task setStandardError:errorPipe];
	
	[task launch];
	[task waitUntilExit];
	
	
	NSFileHandle *outputFileHandle = [outputPipe fileHandleForReading];
	NSString *output = [[NSString alloc] initWithData:[outputFileHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	
	if ([task terminationStatus] != 0) {
		NSFileHandle *errorFileHandle = [errorPipe fileHandleForReading];
		NSString *errorOutput = [[NSString alloc] initWithData:[errorFileHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
		
		NSString *reason = [NSString stringWithFormat:@"PlistBuddy returned %i while trying to read CFBundleVersion.", [task terminationStatus]];
		NSDictionary *userInfo = @{IncrementerReadWriteExceptionStdoutKey: output, IncrementerReadWriteExceptionStderrKey: errorOutput};
		
		@throw [NSException exceptionWithName:IncrementerReadWriteException reason:reason userInfo:userInfo];
	}
	
	output = [output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	
	BuildNumberFormat format = InvalidBuildNumberFormat;
	
	if ([BasicBuildNumber isValidString:output]) {
		format = BasicBuildNumberFormat;
	} else if ([AppleStyleBuildNumber isValidString:output]) {
		format = AppleStyleBuildNumberFormat;
		
		if (![AppleStyleBuildNumber isValidVersionNumber:self.versionNumber]) {
			NSString *reason = @"Existing version number invalid for an Apple style build number.";
			NSDictionary *userInfo = @{IncrementerUnknownFormatExceptionStringKey: [self.versionNumber stringValue]};
			
			@throw [NSException exceptionWithName:IncrementerUnknownFormatException reason:reason userInfo:userInfo];
		}
	}
	
	if (format == InvalidBuildNumberFormat && self.format == InvalidBuildNumberFormat) {
		NSString *reason = @"Unknown format for existing build number string.";
		NSDictionary *userInfo = @{IncrementerUnknownFormatExceptionStringKey: output};
		
		@throw [NSException exceptionWithName:IncrementerUnknownFormatException reason:reason userInfo:userInfo];
	}
	
	
	if (self.format == InvalidBuildNumberFormat) self.format = format;
	
	if (self.format != format) {
		switch (self.format) {
			case BasicBuildNumberFormat:
				self.buildNumber = [[BasicBuildNumber alloc] init];
				break;
				
			case AppleStyleBuildNumberFormat:
				self.buildNumber = [[AppleStyleBuildNumber alloc] initWithVersionNumber:self.versionNumber];
				break;
				
			default:
				@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unhandled format." userInfo:nil];
		}
	} else {
		switch (self.format) {
			case BasicBuildNumberFormat:
				self.buildNumber = [[BasicBuildNumber alloc] initWithBuildNumberString:output];
				break;
				
			case AppleStyleBuildNumberFormat: {
				AppleStyleBuildNumber *buildNumber = [[AppleStyleBuildNumber alloc] initWithBuildNumberString:output];
				
				if (self.startOverOnNewMajorVersion && buildNumber.majorVersionNumber != self.versionNumber.majorVersionNumber)
					buildNumber = [[AppleStyleBuildNumber alloc] initWithVersionNumber:self.versionNumber];
				
				self.buildNumber = buildNumber;
				
				break;
			}
				
			default:
				@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unhandled format." userInfo:nil];
		}
	}
}

#pragma mark - Incrementing

- (void)incrementBuildNumber {
	[self.buildNumber increment];
	
	
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:@"/usr/libexec/PlistBuddy"];
	[task setArguments:@[@"-c", [@"Set :CFBundleVersion " stringByAppendingString:[self.buildNumber stringValue]], self.pathToInfoPlist]];
	
	NSPipe *outputPipe = [[NSPipe alloc] init];
	[task setStandardOutput:outputPipe];
	
	NSPipe *errorPipe = [[NSPipe alloc] init];
	[task setStandardError:errorPipe];
	
	[task launch];
	[task waitUntilExit];
	
	if ([task terminationStatus] != 0) {
		NSFileHandle *outputFileHandle = [outputPipe fileHandleForReading];
		NSString *output = [[NSString alloc] initWithData:[outputFileHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
		
		NSFileHandle *errorFileHandle = [errorPipe fileHandleForReading];
		NSString *errorOutput = [[NSString alloc] initWithData:[errorFileHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
		
		NSString *reason = [NSString stringWithFormat:@"PlistBuddy returned %i while trying to write CFBundleVersion.", [task terminationStatus]];
		NSDictionary *userInfo = @{IncrementerReadWriteExceptionStdoutKey: output, IncrementerReadWriteExceptionStderrKey: errorOutput};
		
		@throw [NSException exceptionWithName:IncrementerReadWriteException reason:reason userInfo:userInfo];
	}
}

@end
