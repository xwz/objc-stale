@class ASIHTTPRequest;

typedef void (^HttpBlock) (id data, BOOL success, ASIHTTPRequest *request);

@interface HttpClient : NSObject

+ (BOOL) fetchFromUrl: (NSString *)urlString 
			 useCache:(BOOL)useCache 
		   whenFinish:(HttpBlock) onFinishBlock;

@end
