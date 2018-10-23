//
//  NSFileManager+Size.h
//  AppSweeper
//
//  Created by Alex_Wu on 1/6/17.
//  Copyright © 2017 alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Size)
- (unsigned long long) sizeAtUrl:(NSURL *)url;
- (unsigned long long) sizeAtPath:(NSString *)path useUrl:(BOOL)readUrl useMDItem:(BOOL)mdItem;
- (unsigned long long) sizeAtPath:(NSString *)path;
@end
