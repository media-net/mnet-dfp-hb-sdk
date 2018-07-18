//
//  MNBaseHttpClient.m
//  Pods
//
//  Created by akshay.d on 17/02/17.
//
//

#import "MNBaseHttpClient.h"
#import "MNBaseConstants.h"
#import "MNBaseDeviceUserAgent.h"
#import "MNBaseError.h"
#import "MNBaseLogger.h"
#import "MNBaseReachability.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseURL.h"
#import "MNBaseUtil.h"
#import "math.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFNetworking/AFImageDownloader.h>

@implementation MNBaseHttpClient

static AFHTTPSessionManager *manager;

#pragma mark - Initializations
+ (void)initializeManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      manager                    = [[AFHTTPSessionManager manager]
          initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
      manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
      manager.responseSerializer = [AFHTTPResponseSerializer serializer];

      manager.responseSerializer.acceptableContentTypes =
          [NSSet setWithObjects:@"application/json", @"text/plain", @"image/gif", @"application/xml", @"text/xml",
                                @"text/html", @"text/json", @"text/javascript", nil];
      [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    });
}

#pragma mark - Request maker

/// Checks the validity of the url-string
+ (BOOL)isValidUrl:(NSString *)url {
    NSURL *validURL = [NSURL URLWithString:url];
    return (validURL != nil);
}

/// Makes a request with all the given parameters. Also checks the validity of the given url
+ (NSMutableURLRequest *)getRequestWithMethod:(NSString *)method
                                    urlString:(NSString *)url
                                      headers:(NSDictionary *)headers
                                   parameters:(NSDictionary *)params
                                      timeout:(NSTimeInterval)timeout
                                         body:(NSString *)body
                                 withErrorRet:(NSError **)error {
    if ([self isValidUrl:url] == NO) {
        NSString *errStr = [NSString stringWithFormat:@"Invalid url %@", url];
        if (error != nil) {
            NSError *err =
                [MNBaseError createErrorWithCode:MNBaseErrCodeInvalidURL errorDescription:errStr andFailureReason:nil];
            (*error) = err;
        }
        return nil;
    }

    NSMutableURLRequest *request =
        [[AFJSONRequestSerializer serializer] requestWithMethod:method URLString:url parameters:params error:error];
    if ((*error) != nil) {
        return nil;
    }

    request.timeoutInterval = timeout;
    if (body != nil) {
        [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
        MNLogD(@"Making API call with body %@", body);
    }

    NSMutableDictionary *modifiableHeaders;
    if (headers != nil) {
        modifiableHeaders = [headers mutableCopy];
    } else {
        modifiableHeaders = [NSMutableDictionary new];
    }

    NSString *userAgent = [MNBaseDeviceUserAgent getDeviceUserAgent];
    if (userAgent != nil) {
        modifiableHeaders[@"User-Agent"] = userAgent;
    }

    if ([MNBaseUtil getApiHeaders] != nil) {
        [modifiableHeaders addEntriesFromDictionary:[MNBaseUtil getApiHeaders]];
    }

    headers = [NSDictionary dictionaryWithDictionary:modifiableHeaders];

    if (headers) {
        for (NSString *key in [headers keyEnumerator]) {
            NSString *value = [headers objectForKey:key];
            [request setValue:value forHTTPHeaderField:key];
        }
    }

    MNLogD(@"Request is %@", request);
    return request;
}

/// Makes a request with headers "Accept" and "Content-Type" as "application/json", along with the rest of the params
+ (NSMutableURLRequest *)getJSONRequestWithMethod:(NSString *)method
                                        urlString:(NSString *)url
                                          headers:(NSDictionary<NSString *, NSString *> *)headers
                                       parameters:(NSDictionary *)parameters
                                          timeout:(NSTimeInterval)timeout
                                             body:(NSString *)body
                                     withErrorRet:(NSError **)error {

    NSMutableDictionary *modifiedHeaders;
    if (headers == nil) {
        modifiedHeaders = [[NSMutableDictionary alloc] init];
    } else {
        modifiedHeaders = [headers mutableCopy];
    }

    NSString *jsonType = @"application/json";
    [modifiedHeaders setObject:jsonType forKey:@"Content-Type"];
    [modifiedHeaders setObject:jsonType forKey:@"Accept"];

    NSMutableURLRequest *request = [self getRequestWithMethod:method
                                                    urlString:url
                                                      headers:modifiedHeaders
                                                   parameters:parameters
                                                      timeout:timeout
                                                         body:body
                                                 withErrorRet:error];
    return request;
}

+ (NSTimeInterval)getDefaultTimeout {
    NSTimeInterval timeout;
    NSString *timeoutStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"];
    if (timeoutStr == nil || [timeoutStr isEqualToString:@""]) {
        timeout = DEFAULT_NETWORK_TIMEOUT;
    } else {
        timeout = [timeoutStr doubleValue];
    }
    return timeout;
}

#pragma mark - Response handler
/// A generic http json response handler. This will parse and return the json data
+ (NSDictionary *)httpJSONResponseHandler:(NSURLResponse *_Nonnull)response
                           responseObject:(id _Nullable)responseObject
                                 errorRet:(NSError **_Nullable)errorRet {
    if ((*errorRet) != nil) {
        MNLogD(@"Error %@", (*errorRet));
        return nil;
    }

    id parsedResponse;
    NSString *errDisplayStr = @"Error fetching response";

    @try {
        NSError *jsonError;
        parsedResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
        if (jsonError) {
            MNLogD(@"JSON parsing error %@", jsonError);
            (*errorRet) = jsonError;
            return nil;
        }
    } @catch (NSException *exception) {
        NSString *errReason =
            [NSString stringWithFormat:@"Exception: %@, Reason: %@", exception.name, exception.reason];
        NSError *parseErr = [MNBaseError createErrorWithCode:MNBaseErrCodeInvalidResponse
                                            errorDescription:errDisplayStr
                                            andFailureReason:errReason];
        (*errorRet)       = parseErr;
        return nil;
    }

    if (!parsedResponse) {
        NSString *errReason = @"The response is empty";
        NSError *emptyErr   = [MNBaseError createErrorWithCode:MNBaseErrCodeInvalidResponse
                                            errorDescription:errDisplayStr
                                            andFailureReason:errReason];
        (*errorRet)         = emptyErr;
        return nil;
    }

    if ([parsedResponse isKindOfClass:[NSDictionary class]] == NO) {
        NSString *errReason = [NSString
            stringWithFormat:@"The root response object is not a dictionary. It's a - %@", [parsedResponse class]];
        NSError *typeErr    = [MNBaseError createErrorWithCode:MNBaseErrCodeInvalidResponse
                                           errorDescription:errDisplayStr
                                           andFailureReason:errReason];
        (*errorRet)         = typeErr;
        return nil;
    }

    NSDictionary *responseDict = parsedResponse;

    NSNumber *successVal = [responseDict valueForKey:@"success"];
    BOOL responseStatus;
    if (successVal != nil) {
        responseStatus = [successVal boolValue];
    }

    if (responseStatus == NO) {
        NSArray *errorArr = [responseDict valueForKey:@"errors"];
        NSString *errReason;
        NSString *errMsg = [responseDict valueForKey:@"message"];
        if (!errMsg) {
            errMsg = @"";
        }
        errMsg = [NSString stringWithFormat:@"Received success as false from server. %@", errMsg];

        if (errorArr) {
            NSString *errListStr = [errorArr componentsJoinedByString:@", "];
            errReason = [NSString stringWithFormat:@"%@. Following reasons for errors- (%@)", errMsg, errListStr];
        } else {
            errReason = errMsg;
        }

        NSError *responseErr = [MNBaseError createErrorWithCode:MNBaseErrCodeInvalidResponse
                                               errorDescription:errDisplayStr
                                               andFailureReason:errReason];
        (*errorRet)          = responseErr;
        return nil;
    }

    return responseDict;
    ;
}

/// An ad-specific http json response handler. This will parse the json data.
/// It will return the contents of the "data" key, if it exists. Nil otherwise
+ (id)getDataFromhttpJSONResponse:(NSURLResponse *_Nonnull)response
                   responseObject:(id _Nullable)responseObject
                         errorRet:(NSError **_Nullable)errorRet {
    NSDictionary *responseDict =
        [self httpJSONResponseHandler:response responseObject:responseObject errorRet:errorRet];
    if (responseDict == nil) {
        return nil;
    }

    id responseDataVal = [responseDict valueForKey:@"data"];
    MNLogD(@"Response is %@", responseDataVal);
    if ([MNBaseUtil isNil:responseDataVal]) {
        responseDataVal = nil;
    }
    return responseDataVal;
}

#pragma mark - Http methods

#pragma mark - GET Methods
/// Make a get request. This sends and accepts only JSON
+ (nullable NSURLSessionDataTask *)doGetOn:(NSString *)url
                                   headers:(NSDictionary *)headers
                                    params:(NSDictionary *)params
                                   timeout:(NSTimeInterval)timeout
                                   success:(void (^)(NSDictionary *_Nonnull))successHandler
                                     error:(void (^)(NSError *_Nonnull))errorHandler {
    [self initializeManager];

    NSError *error;
    NSMutableURLRequest *request = [self getJSONRequestWithMethod:@"GET"
                                                        urlString:url
                                                          headers:headers
                                                       parameters:params
                                                          timeout:timeout
                                                             body:nil
                                                     withErrorRet:&error];

    if (error != nil) {
        errorHandler(error);
        return nil;
    }

    if (request == nil) {
        errorHandler([MNBaseError createErrorWithCode:MNBaseErrCodeInvalidRequest withFailureReason:nil]);
        return nil;
    }

    NSURLSessionDataTask *task = [manager
        dataTaskWithRequest:request
          completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject,
                              NSError *_Nullable respError) {
            NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            MNLogD(@"RESPONSE: %@", jsonString);

            id dataVal = [self getDataFromhttpJSONResponse:response responseObject:responseObject errorRet:&respError];

            if (respError != nil) {
                if (errorHandler) {
                    errorHandler(respError);
                } else {
                    MNLogD(@"There are no error handlers. Error - %@", respError);
                }
                return;
            }

            if (successHandler) {
                successHandler(dataVal);
            }
          }];

    [task resume];
    return task;
}

/// Make get request with default timeout
+ (nullable NSURLSessionDataTask *)doGetOn:(NSString *)url
                                   headers:(NSDictionary *)headers
                                    params:(NSDictionary *)params
                                   success:(void (^)(NSDictionary *_Nonnull))successHandler
                                     error:(void (^)(NSError *_Nonnull))errorHandler {
    return [self doGetOn:url
                 headers:headers
                  params:params
                 timeout:[self getDefaultTimeout]
                 success:successHandler
                   error:errorHandler];
}

+ (NSURLSessionDataTask *)doGetWithStrResponseOn:(NSString *)url
                                         headers:(NSDictionary *)headers
                                     shouldRetry:(BOOL)retryEnabled
                                         success:(void (^)(NSString *_Nonnull))successHandler
                                           error:(void (^)(NSError *_Nonnull))errorHandler {
    if (retryEnabled == NO) {
        return [self doGetWithStrResponseOn:url headers:headers success:successHandler error:errorHandler];
    }

    [self initializeManager];
    NSError *error;
    NSMutableURLRequest *request = [self getRequestWithMethod:@"GET"
                                                    urlString:url
                                                      headers:headers
                                                   parameters:nil
                                                      timeout:[self getDefaultTimeout]
                                                         body:nil
                                                 withErrorRet:&error];
    if (error != nil) {
        MNLogD(@"Error - %@", error);
        errorHandler(error);
        return nil;
    }

    if (request == nil) {
        errorHandler([MNBaseError createErrorWithCode:MNBaseErrCodeInvalidRequest withFailureReason:nil]);
        return nil;
    }
    NSInteger retryCount = [[[MNBaseSdkConfig getInstance] getNetworkRetryCount] integerValue];
    return [self doGetStrResponseWithRetryEnabledOnRequest:[request copy]
                                                retryCount:retryCount
                                                   success:successHandler
                                                     error:errorHandler];
}

+ (NSURLSessionDataTask *)doGetStrResponseWithRetryEnabledOnRequest:(NSURLRequest *_Nonnull)request
                                                         retryCount:(NSInteger)retryCount
                                                            success:(nonnull void (^)(NSString *_Nonnull))successHandler
                                                              error:(nonnull void (^)(NSError *_Nonnull))errorHandler {

    if (retryCount <= 0) {
        if (errorHandler) {
            NSString *failureReason = @"Failed to get response from server";
            NSError *err =
                [MNBaseError createErrorWithCode:MNBaseErrCodeInvalidResponse withFailureReason:failureReason];
            errorHandler(err);
        }
        return nil;
    }
    NSTimeInterval delayBeforeCall = 0.0;
    if (DEFAULT_RETRY_COUNT > retryCount) {
        delayBeforeCall = pow(DEFAULT_RETRY_EXPONENTIAL_BASE, DEFAULT_RETRY_COUNT - retryCount);
    }
    NSUInteger updatedRetryCount = retryCount - 1;
    __block NSURLSessionDataTask *task;
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayBeforeCall * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          task = [manager dataTaskWithRequest:request
                            completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject,
                                                NSError *_Nullable error) {
                              if (error) {
                                  MNLogD(@"Error %@", error);
                                  MNLogD(@"Retrying");
                                  MNLogD(@"Updated retry Count : %lu", (long) updatedRetryCount);
                                  [self doGetStrResponseWithRetryEnabledOnRequest:request
                                                                       retryCount:updatedRetryCount
                                                                          success:successHandler
                                                                            error:errorHandler];

                              } else if (!responseObject) {
                                  NSString *errStr = @"Response is nil";
                                  MNLogD(@"Error %@", errStr);
                                  if (errorHandler) {
                                      errorHandler([MNBaseError createErrorWithCode:MNBaseErrCodeInvalidResponse
                                                                  withFailureReason:errStr]);
                                  }
                              } else {
                                  @try {
                                      NSString *respStr = [NSString stringWithCString:[responseObject bytes]
                                                                             encoding:NSISOLatin1StringEncoding];
                                      successHandler(respStr);

                                  } @catch (NSException *except) {
                                      NSString *errStr = [except reason];
                                      MNLogD(@"Error %@", errStr);
                                      if (errorHandler) {
                                          errorHandler([MNBaseError createErrorWithCode:MNBaseErrCodeInvalidResponse
                                                                      withFailureReason:errStr]);
                                      }
                                  }
                              }
                            }];
          [task resume];
        });
    return task;
}

+ (NSURLSessionDataTask *)doGetWithStrResponseOn:(NSString *_Nonnull)url
                                         headers:(NSDictionary *_Nullable)headers
                                         success:(nonnull void (^)(NSString *_Nonnull))successHandler
                                           error:(nonnull void (^)(NSError *_Nonnull))errorHandler {
    [self initializeManager];

    NSError *error;
    NSMutableURLRequest *request = [self getRequestWithMethod:@"GET"
                                                    urlString:url
                                                      headers:headers
                                                   parameters:nil
                                                      timeout:[self getDefaultTimeout]
                                                         body:nil
                                                 withErrorRet:&error];
    if (error != nil) {
        MNLogD(@"Error - %@", error);
        errorHandler(error);
        return nil;
    }

    if (request == nil) {
        errorHandler([MNBaseError createErrorWithCode:MNBaseErrCodeInvalidRequest withFailureReason:nil]);
        return nil;
    }

    NSURLSessionDataTask *task = [manager
        dataTaskWithRequest:request
          completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
            if (error) {
                MNLogD(@"Error %@", error);
                if (errorHandler) {
                    errorHandler(error);
                }
                return;

            } else if (!responseObject) {
                NSString *errStr = @"Response is nil";
                MNLogD(@"Error %@", errStr);
                if (errorHandler) {
                    errorHandler(
                        [MNBaseError createErrorWithCode:MNBaseErrCodeInvalidResponse withFailureReason:errStr]);
                }
            }

            @try {
                NSString *respStr =
                    [NSString stringWithCString:[responseObject bytes] encoding:NSISOLatin1StringEncoding];
                successHandler(respStr);

            } @catch (NSException *except) {
                NSString *errStr = [except reason];
                MNLogD(@"Error %@", errStr);
                if (errorHandler) {
                    errorHandler(
                        [MNBaseError createErrorWithCode:MNBaseErrCodeInvalidResponse withFailureReason:errStr]);
                }
            }
          }];
    [task resume];

    return task;
}

+ (void)doGetImageOn:(NSString *)url
             success:(void (^)(UIImage *_Nonnull))successHandler
               error:(void (^)(NSError *_Nonnull))errorHandler {

    // Assert for valid url here
    if ([self isValidUrl:url] == NO) {
        NSString *errStr = [NSString stringWithFormat:@"Invalid url %@", url];
        errorHandler(
            [MNBaseError createErrorWithCode:MNBaseErrCodeInvalidURL errorDescription:errStr andFailureReason:nil]);
        return;
    }

    void (^imageDownloader)(void) = ^{
      // TODO: This needs to be more accurate. Can't let default values dictate this
      NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
      [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

      AFImageDownloader *downloader = [AFImageDownloader defaultInstance];
      UIImage *image                = [[downloader imageCache] imageforRequest:request withAdditionalIdentifier:nil];
      if (image) {
          MNLogD(@"Found image in cache");
          successHandler(image);
          return;
      }
      [downloader downloadImageForURLRequest:request
          success:^(NSURLRequest *_Nonnull request, NSHTTPURLResponse *_Nullable response,
                    UIImage *_Nonnull responseObject) {
            successHandler(responseObject);
          }
          failure:^(NSURLRequest *_Nonnull request, NSHTTPURLResponse *_Nullable response, NSError *_Nonnull error) {
            errorHandler(error);
          }];
    };

    if ([NSThread mainThread]) {
        imageDownloader();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
          @try {
              imageDownloader();
          } @catch (NSException *e) {
              MNLogE(@"EXCEPTION - image downloader err %@", e);
          }
        });
    }
}

#pragma mark - POST methods
+ (NSURLSessionDataTask *)doPostOn:(NSString *)url
                           headers:(NSDictionary *)headers
                            params:(NSDictionary *)params
                              body:(NSString *)body
                           timeout:(NSTimeInterval)timeout
                           success:(void (^)(NSDictionary *_Nonnull))successHandler
                             error:(void (^)(NSError *_Nonnull))errorHandler {
    [self initializeManager];
    NSError *error;
    NSMutableURLRequest *req = [self getJSONRequestWithMethod:@"POST"
                                                    urlString:url
                                                      headers:headers
                                                   parameters:params
                                                      timeout:timeout
                                                         body:body
                                                 withErrorRet:&error];

    if (error != nil) {
        errorHandler(error);
        return nil;
    }

    if (req == nil) {
        errorHandler([MNBaseError createErrorWithCode:MNBaseErrCodeInvalidRequest withFailureReason:nil]);
        return nil;
    }

    NSURLSessionDataTask *task = [manager
        dataTaskWithRequest:req
          completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject,
                              NSError *_Nullable respError) {
            id dataVal = [self getDataFromhttpJSONResponse:response responseObject:responseObject errorRet:&respError];

            if (respError != nil) {
                if (errorHandler) {
                    errorHandler(respError);
                } else {
                    MNLogD(@"There are no error handlers. Error - %@", respError);
                }
                return;
            }

            if (successHandler) {
                successHandler(dataVal);
            }
          }];
    [task resume];
    return task;
}

+ (NSURLSessionDataTask *)doPostOn:(NSString *)url
                           headers:(NSDictionary *)headers
                            params:(NSDictionary *)params
                              body:(NSString *)body
                           success:(void (^)(NSDictionary *_Nonnull))successHandler
                             error:(void (^)(NSError *_Nonnull))errorHandler {
    return [self doPostOn:url
                  headers:headers
                   params:params
                     body:body
                  timeout:DEFAULT_NETWORK_TIMEOUT
                  success:successHandler
                    error:errorHandler];
}

#pragma mark - HEAD Requests

+ (nullable NSURLSessionDataTask *)doHeadOn:(NSString *)url
                                    headers:(NSDictionary *)headers
                                    success:(void (^)(void))successHandler
                                      error:(void (^)(NSError *_Nonnull))errorHandler {
    [self initializeManager];
    NSTimeInterval timeout = [self getDefaultTimeout];

    NSError *error;
    NSMutableURLRequest *request = [self getRequestWithMethod:@"HEAD"
                                                    urlString:url
                                                      headers:headers
                                                   parameters:nil
                                                      timeout:timeout
                                                         body:nil
                                                 withErrorRet:&error];

    if (error != nil) {
        errorHandler(error);
        return nil;
    }

    if (request == nil) {
        errorHandler([MNBaseError createErrorWithCode:MNBaseErrCodeInvalidRequest withFailureReason:nil]);
        return nil;
    }

    NSURLSessionDataTask *task =
        [manager dataTaskWithRequest:request
                   completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject,
                                       NSError *_Nullable respError) {
                     if (respError != nil) {
                         if (errorHandler) {
                             errorHandler(respError);
                         } else {
                             MNLogD(@"There are no error handlers. Error - %@", respError);
                         }
                         return;
                     }

                     if (successHandler) {
                         successHandler();
                     }
                   }];

    [task resume];
    return task;
}

#pragma mark - Utility methods

+ (void)isUrlReachable:(NSString *)url withStatus:(void (^)(BOOL))statusCb {
    [self doGetWithStrResponseOn:url
        headers:nil
        success:^(NSString *_Nonnull response) {
          statusCb(YES);
        }
        error:^(NSError *_Nonnull error) {
          statusCb(NO);
        }];
}

+ (BOOL)isInternetConnectivityPresent {
    MNBaseReachability *reachability = [MNBaseReachability reachabilityForInternetConnection];
    [reachability startNotifier];
    MNBaseNetworkStatus status = [reachability currentReachabilityStatus];

    return (status != MNBaseNetworkNotReachable);
}

+ (void)makeLatencyTestRequest {
    NSNumber *startTime = [MNBaseUtil getTimestampInMillis];
    [MNBaseHttpClient isUrlReachable:[[MNBaseURL getSharedInstance] getLatencyTestUrl]
                          withStatus:^(BOOL isReachable) {
                            NSNumber *endTime = [MNBaseUtil getTimestampInMillis];
                            long timeDiff     = endTime.longValue - startTime.longValue;
                            MNLogD(@"LATENCY TEST: Time duration -> %lu ms", timeDiff);
                          }];
}

@end
