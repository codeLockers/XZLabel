//
//  NSString+Category.h
//  XZCategory
//
//  Created by 徐章 on 16/4/10.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Category)

/**
*  the string use md5 encryption
*
*  @return the string's md5 string
*/
- (NSString *)md5;

/** change string to json string*/
@property (nonatomic, readonly, strong) NSString *jsonString;

/** Whether it is pure int numbers*/
@property (nonatomic, readonly, assign) BOOL isPureInt;
/** Whether it is float numbers*/
@property (nonatomic, readonly, assign) BOOL isFloatNumber;


/**
 *  int->string
 *
 *  @param value the value of int
 *
 *  @return the string of int
 */
+ (NSString *)stringFromInt:(NSInteger)value;

/**
 *  float->string
 *
 *  @param value  the value of float
 *  @param format the format of string, such as the value=8.234 with the format="%0.2f", the result of the method is "8.23", default format is "0.2f"
 *
 *  @return the string of float
 */
+ (NSString *)stringFromFloat:(CGFloat)value format:(NSString *)format;

/**
 *  judge the string is contain emoji
 *
 *  @return YES:contain NO:no
 */
- (BOOL)isContainsEmoji;

/**
 *  remove all emoji is string
 *
 *  @return the string without emoji
 */
- (NSString *)removeEmoji;
@end
