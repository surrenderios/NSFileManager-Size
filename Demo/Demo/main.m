//
//  main.m
//  Demo
//
//  Created by Alex_Wu on 10/23/18.
//  Copyright © 2018 Starcor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSFileManager+Size.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask] firstObject];
        unsigned long long size = [[NSFileManager defaultManager] sizeAtUrl:url];
        NSLog(@">>>>>%llu",size);
        
    }
    return 0;
}
