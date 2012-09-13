//
//  DocumentHelper.m
//  Maestro Sales Leads
//
//  Created by Dan Frazee on 9/13/12.
//  Copyright (c) 2012 Maestro Mobile. All rights reserved.
//

#import "DocumentHelper.h"

@implementation DocumentHelper

+(NSString*)setDocumentPathForImage:(UIImage*)image
{
    NSData *pngData = UIImagePNGRepresentation(image);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *randomImageRef = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *imageName = [randomImageRef stringByAppendingString:@".png"];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:imageName]; //Add the file name
    [pngData writeToFile:filePath atomically:YES]; //Write the file
    
    return filePath;
}

@end
