/*
 Convert NSKeyedArchiver / NSArchiver data to XML plist.
 This only works when the encoded data maps to plist types.
 
 Reads data from first argument or stdin, writes to stdout.
 
     dump-nsarchive /path/to/file
 
 You can combine it with OpenSSL to decode base64 encoded
 archives from another XML plist's <data> section. Copy
 the base64 block to the clipboard and then run:
 
     pbpaste | openssl base64 -d | dump-nsarchive
 
 Marc Liyanage <http://www.entropy.ch>
 
 */

#import <Foundation/Foundation.h>

int main (int argc, const char * argv[]) {

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	NSString *path = argc > 1 ? [NSString stringWithUTF8String:argv[1]] : @"/dev/stdin";
	NSData *data = [[NSFileHandle fileHandleForReadingAtPath:path] readDataToEndOfFile];
	if (!data) {
		NSLog(@"Unable to read data from file '%@'", path);
		return 1;
	}

	id archiver = [[[NSUnarchiver alloc] initForReadingWithData:data] autorelease];
	if (!archiver)
		archiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease]; // throws on invalid data

	id plist = [archiver decodeObject];
	if (!plist) {
		NSLog(@"Unable to decode archive");
		return 3;
	}

	NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:plist format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
	[plistData writeToFile:@"/dev/stdout" atomically:NO];
	
    [pool drain];
    return 0;

}
