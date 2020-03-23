#import "PostDictController.h"
#import "AppController.h"
#import "WebViewController.h"

@implementation PostDictController

@synthesize connection, webViewController;

#pragma mark * Core transfer code

- (void)startSend:(NSString *)word {
#ifdef verbose
NSLog(@"into startSend:(NSString *)word  of %@",[self class]);
#endif

    BOOL success;
    NSURL *url;
    NSMutableURLRequest *request;

	responseData = nil;
	[responseData release];
	responseData = [[NSMutableData alloc] init];
	
	url = [NSURL URLWithString:@"http://www.dict.org/bin/Dict"];
    success = (url != nil);

	if (success) {
		request = [NSMutableURLRequest requestWithURL:url];        
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:[[NSString stringWithFormat:@"Form=Dict1&Query=%@&Strategy=*&Database=*&submit=Submit+query",word] dataUsingEncoding:NSASCIIStringEncoding]];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"64" forHTTPHeaderField:@"Content-Length"];
        
		self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response {
#ifdef verbose
NSLog(@"into connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response  of %@",[self class]);
#endif

	#pragma unused(theConnection)
	#pragma unused(response)
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data {
#ifdef verbose
NSLog(@"into connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data  of %@",[self class]);
#endif

	#pragma unused(theConnection)
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
#ifdef verbose
NSLog(@"into connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error  of %@",[self class]);
#endif
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"You must be connected to the internet for two-player games.\n\n\n\n" 
												   delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	[alert show];
	[alert release];
	AppController *appController = (AppController *)[[UIApplication sharedApplication] delegate];
	appController.connection_failed = YES;

	#pragma unused(theConnection)
	#pragma unused(error)
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
#ifdef verbose
NSLog(@"into connectionDidFinishLoading:(NSURLConnection *)theConnection  of %@",[self class]);
#endif

	#pragma unused(theConnection)

	NSString *string = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];//[NSString stringWithUTF8String:[responseData bytes]];
	[webViewController setViewContent:string];
	[webViewController.myWebView setNeedsDisplay];
	[string release];
	AppController *appController = (AppController *)[[UIApplication sharedApplication] delegate];
	appController.connection_failed = NO;
}

- (void)dealloc {
#ifdef verbose
NSLog(@"into dealloc  of %@",[self class]);
#endif

	[super dealloc];
}

@end
