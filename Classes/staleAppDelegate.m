#import "staleAppDelegate.h"
#import "HttpClient.h"

@implementation staleAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application 
		didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    [self.window makeKeyAndVisible];
	
	[HttpClient fetchFromUrl:@"http://fphnum.com/?number=%2B+41+044+668+18+00" 
					useCache:YES 
				  whenFinish:^(id data, BOOL success, ASIHTTPRequest *request){
					  NSLog(@"response = %@", data);
				  }];
    
    return YES;
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
