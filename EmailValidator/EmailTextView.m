//
//  EmailTextView.m
//  EmailValidator
//
//  Created by Tulakshana Weerasooriya on 2018-10-14.
//  Copyright © 2018 Tula Weerasooriya. All rights reserved.
//

#import "EmailTextView.h"
#import "EmailValidator.h"

const NSString *emailHelperText = @"aaa@bbb.ccc";

@interface EmailTextView ()

@property (nonatomic, weak) IBOutlet UILabel *lblEmailHelper;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation EmailTextView

- (IBAction)txtEmailEditingChanged:(id)sender {
    [self performEmailHelper:(UITextField *)sender];
}

- (IBAction)txtEmailEditingDidEnd:(id)sender {
    [self performEmailHelper: (UITextField *)sender];
    [self validateEmail:(UITextField *)sender];
}

- (void) performEmailHelper:(UITextField *)txtEmail {

    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc] initWithString:[emailHelperText copy]];
    
    if ([txtEmail.text isEqualToString:@"@"]) {
        [self handleError:nil];
        return;
    } else if ([txtEmail.text length] > 0) {
        NSError *error;
        NSDictionary *attrib = [[NSDictionary alloc] initWithObjectsAndKeys:UIColor.darkGrayColor, NSForegroundColorAttributeName, nil];
        NSArray *emailComponents = [txtEmail.text componentsSeparatedByString:@"@"];
        if ([emailComponents count] > 0) {
            if ([EmailValidator validateUsername:emailComponents.firstObject withError:&error]) {
                [attribString setAttributes:attrib range:NSMakeRange(0, 3)];
            } else {
                [self handleError:error];
                return;
            }
        }
        if ([emailComponents count] > 1) {
            NSString *lastCharacter = [txtEmail.text substringFromIndex:(txtEmail.text.length - 1)];
            if ([lastCharacter isEqualToString:@"@"]) {
                [attribString setAttributes:attrib range:NSMakeRange(0, 4)];
            } else {
                NSArray *components = [emailComponents[1] componentsSeparatedByString:@"."];
                if ([components count] > 0) {
                    if ([EmailValidator validateDomain:components.firstObject withError:&error]) {
                        [attribString setAttributes:attrib range:NSMakeRange(0, 7)];
                    } else {
                        [self handleError:error];
                        return;
                    }
                }
                if ([components count] > 1) {
                    NSString *tld = components[1];
                    if ([lastCharacter isEqualToString:@"."]) {
                        [attribString setAttributes:attrib range:NSMakeRange(0, 8)];
                    } else {
                        if ([EmailValidator validateTLD:tld withError:&error]) {
                            [attribString setAttributes:attrib range:NSMakeRange(0, 11)];
                        } else {
                            [self handleError:error];
                            return;
                        }
                    }
                }
            }
        }
        if ([emailComponents count] > 2) {
            [self handleError:nil];
            return;
        }
    } else {
        NSDictionary *attrib = [[NSDictionary alloc] initWithObjectsAndKeys:UIColor.lightGrayColor, NSForegroundColorAttributeName, nil];
        [attribString setAttributes:attrib range:NSMakeRange(0, emailHelperText.length)];
    }
    self.lblEmailHelper.attributedText = attribString;
}

- (void) handleError: (NSError *)error {
    NSString *text = @"Invalid email";
    if (error) {
        text = error.localizedDescription;
    }
    
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc] initWithString:text];
    NSDictionary *attrib = [[NSDictionary alloc] initWithObjectsAndKeys:UIColor.redColor, NSForegroundColorAttributeName, nil];
    [attribString setAttributes:attrib range:NSMakeRange(0, text.length)];
    
    self.lblEmailHelper.attributedText = attribString;
}

- (void) validateEmail:(UITextField *)txtEmail {
    
    if (![[self.lblEmailHelper.attributedText string] isEqualToString:[emailHelperText copy]]) {
        return;
    }
    
    self.lblEmailHelper.attributedText = nil;
    txtEmail.enabled = false;
    [self.activityView startAnimating];

    __weak EmailTextView *weakSelf = self;
    __weak UITextField *weakTxtEmail = txtEmail;
    [EmailValidator validateEmail:txtEmail.text completionHandler:^(BOOL valid, NSError *error) {
        [weakSelf.activityView stopAnimating];
        weakTxtEmail.enabled = true;
        if (valid) {
            NSString *text = @"Valid email";
            NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc] initWithString:text];
            NSDictionary *attrib = [[NSDictionary alloc] initWithObjectsAndKeys:UIColor.greenColor, NSForegroundColorAttributeName, nil];
            [attribString setAttributes:attrib range:NSMakeRange(0, text.length)];
            
            weakSelf.lblEmailHelper.attributedText = attribString;
        } else {
            [weakSelf handleError:error];
        }
    }];
}

@end
