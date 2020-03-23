#import "StartDataController.h"
#import "AppController.h"
#import "AlphaHedraView.h"
#import "AlphaHedraViewController.h"
#import "EnDe.h"

@implementation StartDataController

@synthesize connection;

#pragma mark * Core transfer code

- (void)startSend:(NSArray *)informationArray {
#ifdef verbose
NSLog(@"into startSend:(NSArray *)informationArray of %@",[self class]);
#endif

    BOOL success;
    NSURL *url;
    NSMutableURLRequest *request;

	responseData = nil;
	[responseData release];
	responseData = [[NSMutableData alloc] init];
	
	url = [NSURL URLWithString:@"http://www.smallfeats.com/polywords/startgame.php"];
    success = (url != nil);
	AppController *appController = (AppController *)[[UIApplication sharedApplication] delegate];

	if (success) {
		request = [NSMutableURLRequest requestWithURL:url];
		NSString *postString = [NSString stringWithFormat:@"GameID=%@&Mode=%i",[informationArray objectAtIndex:0],appController.mode];
		NSData *encodedString = [postString dataUsingEncoding:NSASCIIStringEncoding];
		NSString *encryptedString = [NSString stringWithFormat:@"data=%@",[EnDe encodeBase64:encodedString]];
		NSData *encryptedencodedString = [encryptedString dataUsingEncoding:NSASCIIStringEncoding];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:encryptedencodedString];
		[request setTimeoutInterval:60.0];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%i",[encodedString length]] forHTTPHeaderField:@"Content-Length"];
        
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
	
	NSString *errorDesc = nil;
	NSPropertyListFormat format;

	NSString *string = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];//[NSString stringWithUTF8String:[responseData bytes]];

//	NSLog(@"response string = %@",string);
	[string release];

	NSArray *gameInformation = (NSArray *)[NSPropertyListSerialization
										  propertyListFromData:responseData
										  mutabilityOption:NSPropertyListImmutable
										  format:&format
										  errorDescription:&errorDesc];
	if (!gameInformation) {
		NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
	}
	[errorDesc release];
	AppController *appController = (AppController *)[[UIApplication sharedApplication] delegate];
	AlphaHedraView *alphaHedraView = (AlphaHedraView *)appController.alphaHedraView;
	if (appController.mode == kTwoPlayerClientMode && [[gameInformation objectAtIndex:0] intValue] == 5) {
		alphaHedraView.opponent_ready = YES;
		[alphaHedraView startGameAnimation];
	}
	else if (appController.mode == kTwoPlayerServerMode && [[gameInformation objectAtIndex:0] intValue] == 4) {
		alphaHedraView.opponent_ready = YES;
		[alphaHedraView startGameAnimation];
	}
	appController.connection_failed = NO;
}

- (void)dealloc {
#ifdef verbose
NSLog(@"into dealloc  of %@",[self class]);
#endif

	[super dealloc];
}

@end
