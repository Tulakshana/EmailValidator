//
//  EmailValidator.m
//  EmailValidator
//
//  Created by Tulakshana Weerasooriya on 2018-10-14.
//  Copyright © 2018 Tula Weerasooriya. All rights reserved.
//

#import "EmailValidator.h"
#import <UIKit/UIKit.h>

NSString *const EmailValidatorErrorDomain = @"com.tula.EmailValidator";
NSString *const KICKBOX_API_KEY = @"";

@implementation EmailValidator

+ (BOOL) validateUsername:(NSString *)username withError:(NSError **)error {
    NSPredicate *usernamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Z0-9a-z.!#$%&'*+-/=?^_`{|}~]+"];
    if (username.length == 0 || ![usernamePredicate evaluateWithObject:username] || [username hasPrefix:@"."] || [username hasSuffix:@"."] || ([username rangeOfString:@".."].location != NSNotFound)) {
        NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"The username looks invalid."};
        
        if (error != NULL) {
            *error = [NSError errorWithDomain:EmailValidatorErrorDomain code:EmailInvalidUsernameError userInfo:errorDictionary];
        }
        
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL) validateDomain:(NSString *)domain withError:(NSError **)error {
    NSPredicate *domainPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Z0-9a-z.-]+"];
    if (domain.length == 0 || ![domainPredicate evaluateWithObject:domain]) {
        NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"The domain name is invalid."};
        
        if (error != NULL) {
            *error = [NSError errorWithDomain:EmailValidatorErrorDomain code:EmailInvalidDomainError userInfo:errorDictionary];
        }
        
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL) validateTLD:(NSString *)tld withError:(NSError **)error {
    NSPredicate *tldPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Za-z][A-Z0-9a-z-]{0,22}[A-Z0-9a-z]"];
    if (![tldPredicate evaluateWithObject:tld]) {
        NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: @"The top level domain looks invalid."};
        
        if (error != NULL) {
            *error = [NSError errorWithDomain:EmailValidatorErrorDomain code:EmailInvalidTLDError userInfo:errorDictionary];
        }
        
        return NO;
    } else {
        return YES;
    }
}

+ (void) validateEmail:(NSString *)email completionHandler:(void (^)(BOOL valid, NSError *error))completionHandler{
    
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.kickbox.com/v2/verify?email=%@&apikey=%@", email, KICKBOX_API_KEY];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        BOOL valid = false;
        NSError *responseError = error;
        if (responseError == nil) {
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&responseError];
            if (responseError == nil) {
                valid = [jsonDic[@"result"] isEqualToString:@"deliverable"];
                if (!valid) {
                    responseError = [self generateError:jsonDic[@"reason"] withSuggestion:jsonDic[@"did_you_mean"]];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(valid, responseError);
        });
    }];
    [dataTask resume];
}

+ (NSError *)generateError:(NSString *)type withSuggestion:(NSString *) suggestion {
    NSString *errorMessage = @"";
    EmailValidatorErrorCode code = EmailInvalidError;
    
    if ([type isEqualToString:@"invalid_email"]) {
        code = EmailInvalidError;
        errorMessage = @"Specified email is not a valid email address syntax. ";
    } else if ([type isEqualToString:@"invalid_domain"]) {
        code = EmailInvalidDomainError;
        errorMessage = @"Domain for email does not exist. ";
    } else if ([type isEqualToString:@"rejected_email"]) {
        code = EmailRejectedError;
        errorMessage = @"Email address was rejected by the SMTP server, email address does not exist. ";
    } else if ([type isEqualToString:@"low_quality"]) {
        code = EmailLowQualityError;
        errorMessage = @"Email address has quality issues that may make it a risky or low-value address. ";
    } else if ([type isEqualToString:@"low_deliverability"]) {
        code = EmailLowDeliverabilityError;
        errorMessage = @"Email address appears to be deliverable, but deliverability cannot be guaranteed. ";
    }
    if (![suggestion isEqual:[NSNull null]]) {
        errorMessage = [[NSString alloc] initWithFormat:@"%@%@.", errorMessage, suggestion];
    }
    if (errorMessage == nil) {
        return  nil;
    }
    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey: errorMessage};
    return [NSError errorWithDomain:EmailValidatorErrorDomain code:code userInfo:errorDictionary];
}

@end
