//
//  EmailValidator.h
//  EmailValidator
//
//  Created by Tulakshana Weerasooriya on 2018-10-14.
//  Copyright © 2018 Tula Weerasooriya. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    EmailInvalidUsernameError = 1000,
    EmailInvalidDomainError,
    EmailInvalidTLDError,
    EmailInvalidError,
    EmailRejectedError,
    EmailLowQualityError,
    EmailLowDeliverabilityError,
} EmailValidatorErrorCode;

@interface EmailValidator : NSObject

+ (BOOL) validateUsername:(NSString *)username withError:(NSError **)error;
+ (BOOL) validateDomain:(NSString *)domain withError:(NSError **)error;
+ (BOOL) validateTLD:(NSString *)tld withError:(NSError **)error;
+ (void) validateEmail:(NSString *)email completionHandler:(void (^)(BOOL valid, NSError *error))completionHandler;

@end

NS_ASSUME_NONNULL_END
