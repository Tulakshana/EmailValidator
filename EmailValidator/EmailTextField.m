//
//  EmailTextField.m
//  EmailValidator
//
//  Created by Tulakshana Weerasooriya on 2018-10-14.
//  Copyright © 2018 Tula Weerasooriya. All rights reserved.
//

#import "EmailTextField.h"

@interface EmailTextField ()

@property (strong, nonatomic) UILabel *domainLabel;

@end

@implementation EmailTextField

- (void) awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize
{
    self.keyboardType = UIKeyboardTypeEmailAddress;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [self addTarget:self
             action:@selector(nd_emailEditingChanged:)
   forControlEvents:UIControlEventEditingChanged];
    [self addTarget:self
             action:@selector(nd_emailEditingEnded:)
   forControlEvents:UIControlEventEditingDidEnd];
    [self addTarget:self
             action:@selector(nd_emailEditingEnded:)
   forControlEvents:UIControlEventEditingDidEndOnExit];
    
    _domainLabel = [[UILabel alloc] init];
    _domainLabel.font = self.font;
    _domainLabel.textColor = [self defaultDomainTextColor];
    
    [self addSubview:_domainLabel];
}

#pragma mark - Action

- (void)nd_emailEditingChanged:(id)sender
{
    if (!self.text.length) {
        _domainLabel.text = @"";
        return;
    }
    if (![self.text containsString:@"@"]) {
        _domainLabel.text = @"";
        return;
    }
    NSArray *components = [self.text componentsSeparatedByString:@"@"];
    if (components.count > 2) {
        _domainLabel.text = @"";
        return;
    }
    NSString *writtenDomain = components.lastObject;
    NSString *recommendDomain = [self recommentDomainWithText:writtenDomain];
    
    NSString *domain = [recommendDomain stringByReplacingOccurrencesOfString:writtenDomain withString:@""];
    _domainLabel.text = domain;
    
    CGFloat textWidth = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}].width;
    
    CGRect editingRect = [self editingRectForBounds:self.bounds];
    _domainLabel.frame = CGRectMake(editingRect.origin.x + textWidth, editingRect.origin.y, CGRectGetWidth(editingRect) - textWidth, CGRectGetHeight(editingRect));
}

- (void)nd_emailEditingEnded:(id)sender
{
    _domainLabel.text = @"";
    if (!self.text.length) {
        return;
    }
    if (![self.text containsString:@"@"]) {
        return;
    }
    NSArray *components = [self.text componentsSeparatedByString:@"@"];
    if (components.count > 2) {
        _domainLabel.text = @"";
        return;
    }
    
    NSString *writtenDomain = components.lastObject;
    NSString *recommendDomain = [self recommentDomainWithText:writtenDomain];
    NSString *remainDomain = [recommendDomain stringByReplacingOccurrencesOfString:writtenDomain withString:@""];
    
    if (remainDomain.length) {
        self.text = [self.text stringByAppendingString:remainDomain];
    }
}

#pragma mark - Data utility

- (NSString *)recommentDomainWithText:(NSString *)writtenDomain
{
    NSArray *domains = [self defaultDomains];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith %@", writtenDomain];
    NSArray *filteredDomains = [domains filteredArrayUsingPredicate:predicate];
    NSString *recommendDomain = filteredDomains.firstObject;
    if (!writtenDomain.length) {
        recommendDomain = domains.firstObject;
    }
    return recommendDomain;
}

- (NSArray<NSString *> *)defaultDomains
{
    // Default domain list from `Mailcheck WIKI.`
    // https://github.com/mailcheck/mailcheck/wiki/List-of-Popular-Domains
    
    return @[
             /* Default domains included */
             @"aol.com", @"att.net", @"comcast.net", @"facebook.com", @"gmail.com", @"gmx.com", @"googlemail.com",
             @"google.com", @"hotmail.com", @"hotmail.co.uk", @"mac.com", @"me.com", @"mail.com", @"msn.com",
             @"live.com", @"sbcglobal.net", @"verizon.net", @"yahoo.com", @"yahoo.co.uk",
             
             /* Other global domains */
             @"email.com", @"fastmail.fm", @"games.com" /* AOL */, @"gmx.net", @"hush.com", @"hushmail.com", @"icloud.com",
             @"iname.com", @"inbox.com", @"lavabit.com", @"love.com" /* AOL */, @"outlook.com", @"pobox.com", @"protonmail.com",
             @"rocketmail.com" /* Yahoo */, @"safe-mail.net", @"wow.com" /* AOL */, @"ygm.com" /* AOL */,
             @"ymail.com" /* Yahoo */, @"zoho.com", @"yandex.com",
             
             /* Domains used in Canada */
             
             @"aol.ca", @"google.ca",
             
             /* United States ISP domains */
             @"bellsouth.net", @"charter.net", @"cox.net", @"earthlink.net", @"juno.com",
             
             /* British ISP domains */
             @"btinternet.com", @"virginmedia.com", @"blueyonder.co.uk", @"freeserve.co.uk", @"live.co.uk",
             @"ntlworld.com", @"o2.co.uk", @"orange.net", @"sky.com", @"talktalk.co.uk", @"tiscali.co.uk",
             @"virgin.net", @"wanadoo.co.uk", @"bt.com",
             
             /* Domains used in Asia */
             @"sina.com", @"sina.cn", @"qq.com", @"naver.com", @"hanmail.net", @"daum.net", @"nate.com", @"yahoo.co.jp", @"yahoo.co.kr", @"yahoo.co.id", @"yahoo.co.in", @"yahoo.com.sg", @"yahoo.com.ph", @"163.com", @"126.com", @"aliyun.com", @"foxmail.com",
             
             /* French ISP domains */
             @"hotmail.fr", @"live.fr", @"laposte.net", @"yahoo.fr", @"wanadoo.fr", @"orange.fr", @"gmx.fr", @"sfr.fr", @"neuf.fr", @"free.fr",
             
             /* German ISP domains */
             @"gmx.de", @"hotmail.de", @"live.de", @"online.de", @"t-online.de" /* T-Mobile */, @"web.de", @"yahoo.de",
             
             /* Italian ISP domains */
             @"libero.it", @"virgilio.it", @"hotmail.it", @"aol.it", @"tiscali.it", @"alice.it", @"live.it", @"yahoo.it", @"email.it", @"tin.it", @"poste.it", @"teletu.it",
             
             /* Russian ISP domains */
             @"mail.ru", @"rambler.ru", @"yandex.ru", @"ya.ru", @"list.ru",
             
             /* Belgian ISP domains */
             @"hotmail.be", @"live.be", @"skynet.be", @"voo.be", @"tvcablenet.be", @"telenet.be",
             
             /* Argentinian ISP domains */
             @"hotmail.com.ar", @"live.com.ar", @"yahoo.com.ar", @"fibertel.com.ar", @"speedy.com.ar", @"arnet.com.ar",
             
             /* Domains used in Mexico */
             @"yahoo.com.mx", @"live.com.mx", @"hotmail.es", @"hotmail.com.mx", @"prodigy.net.mx",
             
             /* Domains used in Brazil */
             @"yahoo.com.br", @"hotmail.com.br", @"outlook.com.br", @"uol.com.br", @"bol.com.br", @"terra.com.br", @"ig.com.br", @"itelefonica.com.br", @"r7.com", @"zipmail.com.br", @"globo.com", @"globomail.com", @"oi.com.br"
             ];
}

#pragma mark - View utility

- (UIColor *)defaultDomainTextColor
{
    return [UIColor colorWithRed:191.f/255.f
                           green:191.f/255.f
                            blue:198.f/255.f alpha:1.f];
}

@end
