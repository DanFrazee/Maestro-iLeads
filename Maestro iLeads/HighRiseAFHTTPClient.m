//
//  HighRiseAFHTTPClient.m
//  Maestro iLeads
//
//  Created by Dan Frazee on 9/20/12.
//  Copyright (c) 2012 Maestro. All rights reserved.
//

#import "HighRiseAFHTTPClient.h"
#import "AFXMLRequestOperation.h"

@implementation HighRiseAFHTTPClient

-(id)init
{
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**This is section is to keep urlPath and apiToken private. The plist is located in main bundle and is listed in .gitignor **/
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"api_token" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    NSString *urlPath = [dict objectForKey:@"urlPath"];
    NSString *apiToken = [dict objectForKey:@"apiToken"];
    
    NSURL *url = [NSURL URLWithString:urlPath];
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    self = [super initWithBaseURL:url];
    
    if(self){
        [self setAuthorizationHeaderWithUsername:apiToken password:@"x"];
        //[self setAuthorizationHeaderWithToken:apiToken];
        [self registerHTTPOperationClass:[AFXMLRequestOperation class]];
        //NSLog(@"%@ , %@ , %@",[self defaultValueForHeader:@"Accept-Encoding"], [self defaultValueForHeader:@"Accept-Language"], [self defaultValueForHeader:@"User-Agent"]);
    }
    return self;
}

-(id)initWithBaseURL:(NSURL *)url
{
    return [self init];
}

@end
