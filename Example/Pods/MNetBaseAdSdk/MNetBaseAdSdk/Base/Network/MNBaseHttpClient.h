//
//  MNBaseHttpClient.h
//  Pods
//
//  Created by akshay.d on 17/02/17.
//
//

#import <Foundation/Foundation.h>

@interface MNBaseHttpClient : NSObject
NS_ASSUME_NONNULL_BEGIN

+ (NSURLSessionDataTask *_Nullable)doPostOn:(NSString *)url
                                    headers:(NSDictionary *_Nullable)headers
                                     params:(NSDictionary *_Nullable)params
                                       body:(NSString *_Nullable)body
                                    timeout:(NSTimeInterval)timeout
                                    success:(void (^_Nullable)(NSDictionary *))successHandler
                                      error:(void (^_Nullable)(NSError *))errorHandler;

+ (NSURLSessionDataTask *_Nullable)doPostOn:(NSString *)url
                                    headers:(NSDictionary *_Nullable)headers
                                     params:(NSDictionary *_Nullable)params
                                       body:(NSString *_Nullable)body
                                    success:(void (^)(NSDictionary *))successHandler
                                      error:(void (^)(NSError *))errorHandler;

+ (nullable NSURLSessionDataTask *)doGetOn:(NSString *)url
                                   headers:(NSDictionary *_Nullable)headers
                                    params:(NSDictionary *_Nullable)params
                                   timeout:(NSTimeInterval)timeout
                                   success:(void (^_Nullable)(NSDictionary *))successHandler
                                     error:(void (^_Nullable)(NSError *))errorHandler;

+ (nullable NSURLSessionDataTask *)doGetOn:(NSString *)url
                                   headers:(NSDictionary *_Nullable)headers
                                    params:(NSDictionary *_Nullable)params
                                   success:(void (^_Nullable)(NSDictionary *))successHandler
                                     error:(void (^_Nullable)(NSError *))errorHandler;

+ (NSURLSessionDataTask *)doGetWithStrResponseOn:(NSString *)url
                                         headers:(NSDictionary *_Nullable)headers
                                     shouldRetry:(BOOL)retryEnabled
                                         success:(void (^)(NSString *))successHandler
                                           error:(void (^)(NSError *))errorHandler;

+ (void)doGetImageOn:(NSString *)url
             success:(void (^_Nullable)(UIImage *))successHandler
               error:(void (^_Nullable)(NSError *))errorHandler;

+ (BOOL)isInternetConnectivityPresent;
+ (void)isUrlReachable:(NSString *)url withStatus:(void (^_Nullable)(BOOL))statusCb;
+ (void)makeLatencyTestRequest;

NS_ASSUME_NONNULL_END
@end
