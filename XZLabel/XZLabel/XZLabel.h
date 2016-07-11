//
//  XZLabel.h
//  XZLabel
//
//  Created by 徐章 on 16/7/7.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XZLabelLink : NSObject
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) NSRange range;
@end

@interface XZLabelEmail : NSObject
@property (nonatomic, strong) NSString *email;
@property (nonatomic, assign) NSRange range;
@end

@interface XZLabelConfig : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *linkColor;
@property (nonatomic, strong) UIColor *emailColor;
@end

typedef void(^XZLinkClickBlock)(XZLabelLink *labelLink);
typedef void(^XZEmailClickBlock)(XZLabelEmail *labelEmail);

@interface XZLabel : UILabel

@property (nonatomic, copy) XZLinkClickBlock linkClickBlock;
@property (nonatomic, copy) XZEmailClickBlock emailClickBlock;
- (id)initWithConfig:(XZLabelConfig *)config;

@end
