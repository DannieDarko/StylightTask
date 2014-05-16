//
//  SLDataGrabber.m
//  StylightTask
//
//  Created by Daniel Rexin on 14/04/25.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import "SLDataGrabber.h"
#import "SLDataGrabberDelegate.h"

static NSString * const kSLAPIURL=@"http://api.stylight.com/api/new";
static NSString * const kSLAPIKEYHEADERFIELD=@"X-apiKey";
static NSString * const kSLAPIKEY=@"D13A5A5A0A3602477A513E02691A8458";
static float const kSLTIMEOUT=30.0f;

@interface SLDataGrabber () {
    NSURLSession *_session;
}
@end

static SLDataGrabber *_instance;

@implementation SLDataGrabber

@synthesize delegate=_delegate;

+(SLDataGrabber *)defaultDataGrabber
{
    @synchronized(self) {
        if(_instance==nil) {
            _instance=[[[self class] alloc] init];
        }
        return _instance;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)grabDataOfPage:(NSUInteger)page completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler
{
    if(!_session) {
        NSURLSessionConfiguration *config=[NSURLSessionConfiguration ephemeralSessionConfiguration];
        _session=[NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    }
    NSString *endpointURL=[kSLAPIURL stringByAppendingFormat:@"?gender=women&page=%li&pageItems=20&initializeRows=100",(long)page];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpointURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kSLTIMEOUT];
    [request setValue:kSLAPIKEY forHTTPHeaderField:kSLAPIKEYHEADERFIELD];
    NSURLSessionDataTask *dataTask=[_session dataTaskWithRequest:request completionHandler:completionHandler];
    [dataTask resume];
}

-(void)cancelSession
{
    [_session invalidateAndCancel];
    _session=nil;
}




@end
