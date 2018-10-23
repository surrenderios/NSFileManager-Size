//
//  NSFileManager+Size.m
//  AppSweeper
//
//  Created by Alex_Wu on 1/6/17.
//  Copyright © 2017 alex. All rights reserved.
//

#import "NSFileManager+Size.h"
#import <sys/stat.h>

static NSString *kCustomerFileSizeKey = @"kCustomerFileSizeKey";

@implementation NSFileManager (Size)
- (unsigned long long) sizeAtUrl:(NSURL *)url;
{
    NSString *path = [url path];
    return [self sizeAtPath:path];
}

- (unsigned long long) sizeAtPath:(NSString *)path;
{
    return [self sizeAtPath:path useUrl:YES useMDItem:YES];
}

- (unsigned long long) sizeAtPath:(NSString *)path useUrl:(BOOL)readUrl useMDItem:(BOOL)mdItem;
{
    if (!path) { return 0; }
    
    //先读取自定义的
    NSNumber *fileSize = nil;
    
    fileSize = [self extended2WithPath:path key:kCustomerFileSizeKey];
    if ([fileSize longLongValue] != 0) { return [fileSize  longLongValue]; }
    
    //使用URL
    if (readUrl)
    {
        NSURL *url = [NSURL fileURLWithPath:path];
        [url getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        if ([fileSize longLongValue] != 0) {
            [self extended2WithPath:path key:kCustomerFileSizeKey value:fileSize];
            return [fileSize longLongValue];
        }
    }
    
    //使用MDItem
    if (mdItem)
    {
        MDItemRef item = MDItemCreate(kCFAllocatorDefault, (__bridge CFStringRef)path);
        if (!item) { return 0; } //系统可能返回空的
        
        CFArrayRef names = MDItemCopyAttributeNames(item);
        CFDictionaryRef attDic = MDItemCopyAttributes(item, names);
        NSDictionary *attributes = (__bridge_transfer NSDictionary *)attDic;
        CFRelease(item);
        CFRelease(names);
        
        fileSize = [attributes objectForKey:(NSString *)kMDItemFSSize];
        if ([fileSize longLongValue] != 0 ) {
            [self extended2WithPath:path key:kCustomerFileSizeKey value:fileSize];
            return [fileSize longLongValue];
        }
    }
    
    //最后使用遍历
    fileSize = [NSNumber numberWithUnsignedLongLong:[self fileSizeAtPath:path diskMode:YES]];
    if ([fileSize longLongValue] != 0 ) {
        [self extended2WithPath:path key:kCustomerFileSizeKey value:fileSize];
    }
    return [fileSize longLongValue];
}


//为文件增加一个扩展属性
- (BOOL)extended2WithPath:(NSString *)path key:(NSString *)key value:(NSNumber *)value
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    
    NSDictionary *extendedAttributes = [NSDictionary dictionaryWithObject:
                                        [NSDictionary dictionaryWithObject:data forKey:key]
                                                                   forKey:@"NSFileExtendedAttributes"];
    
    NSError *error = NULL;
    BOOL sucess = [[NSFileManager defaultManager] setAttributes:extendedAttributes
                                                   ofItemAtPath:path error:&error];
    return sucess;
}

//读取文件扩展属性
- (NSNumber *)extended2WithPath:(NSString *)path key:(NSString *)key
{
    NSError *error = NULL;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if (!attributes) {
        return nil;
    }
    NSDictionary *extendedAttributes = [attributes objectForKey:@"NSFileExtendedAttributes"];
    if (!extendedAttributes) {
        return nil;
    }
    id data = [extendedAttributes objectForKey:key];
    if (!data) {
        return nil;
    }
    NSNumber *number = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return number;
}


- (uint64_t)fileSizeAtPath:(NSString *)filePath diskMode:(BOOL)diskMode
{
    uint64_t totalSize = 0;
    
#if !__has_feature(objc_arc)
    NSMutableArray *searchPaths = [NSMutableArray arrayWithObject:filePath];
#else
    NSMutableArray *searchPaths = [[NSMutableArray alloc]initWithObjects:filePath, nil];
#endif
    while ([searchPaths count] > 0)
    {
        @autoreleasepool
        {
            NSString *fullPath = [NSString stringWithString:[searchPaths objectAtIndex:0]];
            [searchPaths removeObjectAtIndex:0];
            
            struct stat fileStat;
            if (lstat([fullPath fileSystemRepresentation], &fileStat) == 0)
            {
                if (fileStat.st_mode & S_IFDIR)
                {
                    NSArray *childSubPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:nil];
                    for (NSString *childItem in childSubPaths)
                    {
                        NSString *childPath = [fullPath stringByAppendingPathComponent:childItem];
                        [searchPaths insertObject:childPath atIndex:0];
                    }
                }else
                {
                    if (diskMode)
                        totalSize += fileStat.st_blocks*512;
                    else
                        totalSize += fileStat.st_size;
                }
            }
        }
    }
#if !__has_feature(objc_arc)
    [searchPaths release];
#endif
    
    return totalSize;
}
@end
