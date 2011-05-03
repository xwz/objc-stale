#import "HttpClient.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

@implementation HttpClient

+ (BOOL) fetchFromUrl: (NSString *)urlString 
			 useCache:(BOOL)useCache 
		   whenFinish:(HttpBlock) onFinishBlock
{
	NSURL *url = [NSURL URLWithString:urlString];
	__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	
	BOOL cacheUsed = NO;
	ASIDownloadCache *cache = [ASIDownloadCache sharedCache];
	[request setDownloadCache:cache];
	[request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];	
	
	ASICachePolicy policy = ASIAskServerIfModifiedWhenStaleCachePolicy;
	policy |= ASIFallbackToCacheIfLoadFailsCachePolicy;
	if (!useCache) {
		policy |= ASIDoNotReadFromCacheCachePolicy;
	}	
	[request setCachePolicy:policy];
	
	BOOL executeFinishBlockAgain = YES;
	cacheUsed = [request.downloadCache canUseCachedDataForRequest:request];
	NSString *file = [cache pathToStoreCachedResponseDataForRequest:request];
	
	NSLog(@"Fetching %@", urlString);
	
	// try to load data from file (stale data), run the request in background
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (useCache && [fileManager fileExistsAtPath:file]) {
		NSLog(@"Using data from %@", file);
		NSString *data = [NSString stringWithContentsOfFile:file
												   encoding:NSUTF8StringEncoding 
													  error:nil];
		if (data != nil) {
			NSLog(@"Data is available");
			onFinishBlock(data, YES, request);
			executeFinishBlockAgain = NO;
			cacheUsed = YES;
		}
	}
	
	[request setCompletionBlock:^{
		if (request.didUseCachedResponse) {			
			NSLog(@"Loaded data from HTTP cache");
		}
		else {
			NSLog(@"Loaded data from web");
		}			
		if (executeFinishBlockAgain) {
			if ([request responseStatusCode] == 200) {
				NSLog(@"Data is available");				
				NSString *data = [request responseString];
				onFinishBlock(data, YES, request);
			}
			else {
				onFinishBlock(nil, NO, request);
			}
		}
	}];
	
	[request setFailedBlock:^{
		if (executeFinishBlockAgain) {
			onFinishBlock(nil, NO, request);
		}
	}];
	
	[request startAsynchronous];
	return cacheUsed;
}

@end
