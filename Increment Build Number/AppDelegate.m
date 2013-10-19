//
//  AppDelegate.m
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

#include <stdlib.h>

#import "AppDelegate.h"
#import "Incrementer.h"


@interface AppDelegate ()

@property (copy, nonatomic) NSString *format;
@property (nonatomic) BOOL restartOnMajor;
@property (nonatomic) BOOL help;

@end


@implementation AppDelegate

#pragma mark - Application delegate

- (void)application:(DDCliApplication *)app willParseOptions:(DDGetoptLongParser *)optionParser {
	DDGetoptOption optionTable[] =
	{
		{"format",         'f', DDGetoptRequiredArgument},
		{"restartOnMajor", 'm', DDGetoptNoArgument},
		{"help",           'h', DDGetoptNoArgument},
		{NULL,              0,  0}
	};
	
	[optionParser addOptionsFromTable:optionTable];
}

- (int)application:(DDCliApplication *)app runWithArguments:(NSArray *)arguments {
	if (self.help) {
		[self printUsage];
		
		return EXIT_SUCCESS;
	}
	
	
	BuildNumberFormat format = InvalidBuildNumberFormat;
	
	if (self.format) {
		self.format = [self.format lowercaseString];
		
		if ([self.format isEqualToString:@"basic"]) {
			format = BasicBuildNumberFormat;
		} else if ([self.format isEqualToString:@"apple"]) {
			format = AppleStyleBuildNumberFormat;
		} else {
			[self printUsageAndExit];
		}
	}
	
	
	if ([arguments count] == 0) [self printUsageAndExit];
	
	
	for (NSString *pathToInfoPlist in arguments) {
		@try {
			Incrementer *incrementer = [[Incrementer alloc] initWithFormat:format pathToInfoPlist:pathToInfoPlist startOverOnNewMajorVersion:self.restartOnMajor];
			
			[incrementer incrementBuildNumber];
		}
		@catch (NSException *exception) {
			ddfprintf(stderr, @"Exception thrown.\n"
							  @"Name: %@\n"
					          @"Reason: %@\n"
					          @"User Info: %@\n", [exception name], [exception reason], [exception userInfo]);
		}
	}
	
	
	return EXIT_SUCCESS;
}

#pragma mark - Printing usage

- (void)printUsageAndExit {
	[self printUsage];
	
	exit(EXIT_FAILURE);
}

- (void)printUsage {
	ddfprintf(stderr, @"Increments an Xcode project's build number.\n\n"
				      @"Usage: increment-build-number [options] info_plist_path...\n\n"
					  @"Options:\n"
			          @"    { -f | --format } build_number_format\n"
			          @"        Specifies the format that the build number should be in. Valid values:\n"
			          @"        basic (e.g. 253), Apple (e.g. 3A201)\n"
			          @"    { -m | --restartOnMajor }\n"
			          @"        Restart numbering after a new major version (only applicable to\n"
					  @"        Apple-style build numbers).\n"
			          @"    { -h | --help }\n"
			          @"        Show this help message.\n");
}

@end
