#import "GetGameDataController.h"
#import "AppController.h"
//#import "WebViewController.h"

@implementation GetGameDataController

@synthesize connection;

#pragma mark * Core transfer code

- (void)startSend:(NSArray *)informationArray {
#ifdef verbose
NSLog(@"into startSend:(NSArray *)informationArray  of %@",[self class]);
#endif

    BOOL success;
    NSURL *url;
    NSMutableURLRequest *request;

	responseData = nil;
	[responseData release];
	responseData = [[NSMutableData alloc] init];
	
	url = [NSURL URLWithString:@"http://www.smallfeats.com/polywords/getgamedata.php"];
    success = (url != nil);

	if (success) {
		request = [NSMutableURLRequest requestWithURL:url];
		NSString *postString = [NSString stringWithFormat:@"GameID=%@",[informationArray objectAtIndex:0]];
		NSData *encodedString = [postString dataUsingEncoding:NSASCIIStringEncoding];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:encodedString];
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
	AppController *appController = (AppController *)[[UIApplication sharedApplication] delegate];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"You must be connected to the internet for two-player games.\n\n\n\n" 
												   delegate:appController.alphaHedraViewController cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	[alert show];
	[alert release];
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

	NSArray *gameInformation = (NSArray *)[NSPropertyListSerialization
										  propertyListFromData:responseData
										  mutabilityOption:NSPropertyListImmutable
										  format:&format
										  errorDescription:&errorDesc];
	if (!gameInformation) {
		NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
	}
	[errorDesc release];
	int poly_id = [[gameInformation objectAtIndex:1] intValue];
	AppController *appController = (AppController *)[[UIApplication sharedApplication] delegate];
	int counter = 0;
	for (NSDictionary *dict in appController.polyhedronInfoArray) {
		int poly_id_2 = [[dict objectForKey:@"polyID"] intValue];
		if (poly_id == poly_id_2) break;
		counter++;
	}

	if (counter < kNumPolyhedra) {
		if ((!appController.unlocked && counter > 9) || (counter > 4 && !appController.upgraded)) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Level Locked" message:@"Upgrade PolyWords to unlock this level." 
														   delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		NSDictionary *polyInfo = [appController.polyhedronInfoArray objectAtIndex:counter];
		[appController startClientGameWithPolyhedron:polyInfo letters:[gameInformation objectAtIndex:0]];
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
