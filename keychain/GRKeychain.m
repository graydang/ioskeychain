//
//  GRKeychain.m
//  GRKeychain
//
//  Created by Gray on 2018/6/25.
//  Copyright © 2018年 gray. All rights reserved.
//

#import "GRKeychain.h"

typedef void(^GRKeychainInnerSearchResultBlock)(NSMutableDictionary *query, OSStatus status, NSData *result);

@interface GRKeychain ()

@property (nonatomic, copy, readwrite) NSString *service;

@end

@implementation GRKeychain

+ (instancetype)defaultService {
    GRKeychain *keychain = [[GRKeychain alloc] initWithService:[[NSBundle mainBundle] bundleIdentifier]];
    return keychain;
}

- (instancetype)initWithService:(NSString *)service {
    self = [super init];
    if (service) {
        self.service = service;
    } else {
        NSAssert(false, @"service cannot be nil!");
    }
    return self;
}

- (void)updateKeychainWithAccount:(NSString *)account password:(NSString *)password resultBlock:(GRKeychainUpdateResultBlock)block {
    if (password.length != 0) {
        [self p_addOrUpdateKeychainItemWithAccount:account password:password resultBlock:block];
    } else {
        [self p_deleteKeychainItemWithAccount:account resultBlock:block];
    }
}

- (void)searchKeychainWithAccount:(NSString *)account resultBlock:(GRKeychainSearchResultBlock)block {
    if (!block) {
        return;
    }
    [self p_searchKeychainItemWithAccount:account resultBlock:^(NSMutableDictionary *query, OSStatus status, NSData *result) {
        if (status == errSecSuccess) {
            NSString *password = [[NSString alloc] initWithBytes:result.bytes length:result.length encoding:NSUTF8StringEncoding];
            NSMutableDictionary *info = [NSMutableDictionary new];
            [info setValue:account forKey:GRKeychainKeyForAccount];
            [info setValue:password forKey:GRKeychainKeyForPassword];
            block(info, true);
        } else {
            block(nil, false);
        }
    }];
}

#pragma mark - private
- (void)p_addOrUpdateKeychainItemWithAccount:(NSString *)account password:(NSString *)password resultBlock:(GRKeychainUpdateResultBlock)block {
    [self p_searchKeychainItemWithAccount:account resultBlock:^(NSMutableDictionary *query, OSStatus status, NSData *result) {
        NSData *pwdData = [password dataUsingEncoding:NSUTF8StringEncoding];//密码
        if (status == errSecSuccess) {
            NSMutableDictionary *newQuery = [NSMutableDictionary dictionary];
            [newQuery setValue:pwdData forKey:(__bridge id)kSecValueData];
            status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)newQuery);
        } else if (status == errSecItemNotFound) {
            [query setValue:pwdData forKey:(__bridge id)kSecValueData];
            status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
        }
        if (block) {
            block(status == errSecSuccess);
        }
    }];
}

- (void)p_deleteKeychainItemWithAccount:(NSString *)account resultBlock:(GRKeychainUpdateResultBlock)block {
    NSMutableDictionary *query = [self p_getDefaultQuery];//获取标准查询参数
    [query setValue:account forKey:(__bridge id)kSecAttrAccount];//账户
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (block) {
        block(status == errSecSuccess);
    }
}

- (void)p_searchKeychainItemWithAccount:(NSString *)account resultBlock:(GRKeychainInnerSearchResultBlock)block {
    if (!block) {
        return;
    }
    NSMutableDictionary *query = [self p_getDefaultQuery];//获取标准查询参数
    [query setValue:account forKey:(__bridge id)kSecAttrAccount];//账户
    [query setValue:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];//设置返回数据
    
    CFTypeRef result;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    
    //返回标准查询参数
    [query removeObjectForKey:(__bridge id)kSecReturnData];
    
    if (status != errSecSuccess) {
        block(query, status, nil);
        return;
    }
    
    //取出密码
    NSData *pwdData = (__bridge_transfer NSData *)result;
    block(query, status, pwdData);
}

- (NSMutableDictionary *)p_getDefaultQuery {
    //构造查询参数
    NSMutableDictionary *query = [NSMutableDictionary new];
    //设置类型参数
    [query setValue:self.service forKey:(__bridge id)kSecAttrService]; //标识
    [query setValue:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass]; //储存密码
    return query;
}

@end
