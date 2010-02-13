//
//  PPFileHandleLineBuffer.m
//  PlayerPiano
//
//  Created by Steve Streza on 2/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PPFileHandleLineBuffer.h"


@implementation PPFileHandleLineBuffer

-(id)initWithFileHandle:(NSFileHandle *)handle{
	if(self = [super init]){
		buffer = [[NSMutableData dataWithCapacity:256] retain];
		
		fileHandle = [handle retain];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataAvailable:) name:NSFileHandleDataAvailableNotification object:fileHandle];

		[fileHandle waitForDataInBackgroundAndNotify];
	}
	return self;
}

-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:fileHandle];
	[fileHandle release], fileHandle = nil;
	
	[super dealloc];
}

-(void)dataAvailable:(NSNotification *)notif{
	NSData *data = [fileHandle availableData];
	[buffer appendData:data];
	
#define StringFromData(__dat) [[[NSString alloc] initWithData:__dat encoding:NSUTF8StringEncoding] autorelease]
	NSLog(@"Data get: '%@' \n\n%@\n\n", StringFromData(data), StringFromData(buffer) );
	
	NSData *newline = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
	
	NSRange newlineRange = NSMakeRange(0, 0);
	do{
		newlineRange = [buffer rangeOfData:newline options:0 range:NSMakeRange(0,[buffer length])];
		if(newlineRange.location != NSNotFound){
			NSData *lineData = [buffer subdataWithRange:NSMakeRange(0, newlineRange.location)];
			NSString *line = [[[NSString alloc] initWithData:lineData encoding:NSUTF8StringEncoding] autorelease];
			NSLog(@"We gots a line! '%@'", line);
			
			[buffer setData:[buffer subdataWithRange:NSMakeRange(newlineRange.location+1, buffer.length - newlineRange.location-1)]];
		}
		
	}while(newlineRange.location != NSNotFound);
	
	[fileHandle waitForDataInBackgroundAndNotify];
}

@end
