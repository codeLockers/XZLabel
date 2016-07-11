//
//  NSString+Category.m
//  XZCategory
//
//  Created by 徐章 on 16/4/10.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "NSString+Category.h"
#import <CommonCrypto/CommonDigest.h> 

@implementation NSString (Category)

- (NSString *)md5{
    
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)jsonString{
    
    NSMutableString *jsonStr = [NSMutableString stringWithString:self];
    [jsonStr replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [jsonStr length])];
    [jsonStr replaceOccurrencesOfString:@"\'" withString:@"\\'" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [jsonStr length])];
    [jsonStr replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [jsonStr length])];
    [jsonStr replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [jsonStr length])];
    [jsonStr replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [jsonStr length])];
    [jsonStr replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [jsonStr length])];
    [jsonStr replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [jsonStr length])];
    [jsonStr replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [jsonStr length])];
    return [NSString stringWithString:jsonStr];
}

- (BOOL)isPureInt{

    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (BOOL)isFloatNumber{

    NSScanner* scan = [NSScanner scannerWithString:self];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}

+ (NSString *)stringFromInt:(NSInteger)value{
    
    return [NSString stringWithFormat:@"%ld",(long)value];
}

+ (NSString *)stringFromFloat:(CGFloat)value format:(NSString *)format{
    
    if (!format)
        format = @"%0.2f";
    return [NSString stringWithFormat:format,value];
}


- (BOOL)isContainsEmoji{
    
    __block BOOL isEomji = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
    
         if (0xd800 <= hs && hs <= 0xdbff) {
             
             if (substring.length > 1) {
                 
                 const unichar ls = [substring characterAtIndex:1];
                 
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 
                 if (0x1d000 <= uc && uc <= 0x1f77f)
                     isEomji = YES;
             }
             
         } else if (substring.length > 1) {
             
             const unichar ls = [substring characterAtIndex:1];
             
             if (ls == 0x20e3)
                 isEomji = YES;
             
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b)
                 isEomji = YES;
             else if (0x2B05 <= hs && hs <= 0x2b07)
                 isEomji = YES;
             else if (0x2934 <= hs && hs <= 0x2935)
                 isEomji = YES;
             else if (0x3297 <= hs && hs <= 0x3299)
                 isEomji = YES;
             else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a )
                 isEomji = YES;
         }
     }];
    return isEomji;
}


- (NSString *)removeEmoji
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *newString = [regex stringByReplacingMatchesInString:self
                                                               options:0
                                                                 range:NSMakeRange(0, [self length])
                                                          withTemplate:@""];
    return newString;
}
@end
