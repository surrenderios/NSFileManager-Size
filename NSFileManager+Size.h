//
//  NSFileManager+Size.h
//  AppSweeper
//
//  Created by Alex_Wu on 1/6/17.
//  Copyright © 2017 alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Size)

/**
 calculate size at url

 @param url file or folder url
 @return size of url
 */
- (unsigned long long) sizeAtUrl:(NSURL *)url;


/**
 calculate size at path

 @param path file or folder path
 @return size of path
 */
- (unsigned long long) sizeAtPath:(NSString *)path;


/**
 calculate size at path

 @param path file or folder path
 @param readUrl if use path's size attribute
 @param mdItem if use mdItem's size attribute
 @return size of path
 */
- (unsigned long long) sizeAtPath:(NSString *)path useUrl:(BOOL)readUrl useMDItem:(BOOL)mdItem;
@end
