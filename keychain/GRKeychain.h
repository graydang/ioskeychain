//
//  GRKeychain.h
//  GRKeychain
//
//  Created by Gray on 2018/6/25.
//  Copyright © 2018年 gray. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GRKeychainKeyForAccount @"account"
#define GRKeychainKeyForPassword @"password"

typedef void(^GRKeychainSearchResultBlock)(NSDictionary *query, BOOL success);
typedef void(^GRKeychainUpdateResultBlock)(BOOL success);

@interface GRKeychain : NSObject

@property (nonatomic, copy, readonly) NSString *service;

+ (instancetype)defaultService;
- (instancetype)initWithService:(NSString *)service;

- (void)updateKeychainWithAccount:(NSString *)account password:(NSString *)password resultBlock:(GRKeychainUpdateResultBlock)block;
- (void)searchKeychainWithAccount:(NSString *)account resultBlock:(GRKeychainSearchResultBlock)block;
@end
