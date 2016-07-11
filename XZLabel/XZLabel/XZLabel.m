//
//  XZLabel.m
//  XZLabel
//
//  Created by 徐章 on 16/7/7.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "XZLabel.h"
#import <CoreText/CoreText.h>
#import <XZCategory/XZCategory.h>

#define XZ_URL_FORMATE @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"

#define XZ_EMAIL_FORMAT @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
@implementation XZLabelLink
@end

@implementation XZLabelEmail
@end

@implementation XZLabelConfig

- (id)init{

    self = [super init];
    if (self) {
        
        self.text = @"";
        self.font = [UIFont systemFontOfSize:15.0f];
        self.textColor = [UIColor blackColor];
        self.linkColor = [UIColor blueColor];
        self.emailColor = [UIColor purpleColor];
    }
    return self;
}

@end


@interface XZLabel()

@property (nonatomic, assign) CTFrameRef frameRef;
@property (nonatomic, strong) NSMutableArray *linkArray;
@property (nonatomic, strong) NSMutableArray *emailArray;
@property (nonatomic, strong) XZLabelConfig *config;

@end

@implementation XZLabel

- (id)initWithConfig:(XZLabelConfig *)config{

    self = [super init];
    if (self) {
        
        self.config = config;
    }
    return self;
    
}

- (void)drawRect:(CGRect)rect{

    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //翻转坐标系
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);

    //设置字体大小、颜色
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:self.config.text];
    [attText setTextWithFont:self.config.font inRange:NSMakeRange(0, attText.length)];
    [attText setTextWithColor:self.config.textColor inRange:NSMakeRange(0, attText.length)];
    
    //匹配出所有链接的信息
    NSRegularExpression *regex_link = [NSRegularExpression regularExpressionWithPattern:XZ_URL_FORMATE options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *match_link = [regex_link matchesInString:self.config.text options:0 range:NSMakeRange(0, self.config.text.length)];
    
    //设置所有链接字段
    for (NSTextCheckingResult *match in match_link)
    {
        [attText setTextWithColor:self.config.linkColor inRange:match.range];
        
        XZLabelLink *labelLink = [[XZLabelLink alloc] init];
        NSAttributedString *urlStr = [attText attributedSubstringFromRange:match.range];
        labelLink.url = [NSURL URLWithString:urlStr.string];
        labelLink.range = match.range;
        [self.linkArray addObject:labelLink];
    }
    
    //匹配出所有的邮箱信息
    NSRegularExpression *regex_email = [NSRegularExpression regularExpressionWithPattern:XZ_EMAIL_FORMAT options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *match_email = [regex_email matchesInString:self.config.text options:0 range:NSMakeRange(0, self.config.text.length)];
    
    //设置所有邮箱字段
    for (NSTextCheckingResult *match in match_email) {
        
        [attText setTextWithColor:self.config.emailColor inRange:match.range];
        XZLabelEmail *labelEmail = [[XZLabelEmail alloc] init];
        labelEmail.email = [attText attributedSubstringFromRange:match.range].string;
        labelEmail.range = match.range;
        [self.emailArray addObject:labelEmail];
    }
    
    //创建CTFramesetterRef
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attText);
    //创建CTFrameRef
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    CTFrameDraw(frameRef, context);
    
    self.frameRef = frameRef;
    CFRelease(framesetterRef);
}

#pragma mark - Setter && Getter
- (NSMutableArray *)linkArray{

    if (!_linkArray) {
        _linkArray = [NSMutableArray array];
    }
    return _linkArray;
}

- (NSMutableArray *)emailArray{

    if (!_emailArray) {
        
        _emailArray = [NSMutableArray array];
    }
    return _emailArray;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    CGPoint point = [[touches anyObject] locationInView:self];
    
    CFIndex index = [self touchContentOffsetAtPoint:point];
    if (index == -1)
        return;
    
    [self clickAtIndex:index];
}

//将点击的位置转换成字符串的偏移量，如果没有找到就返回－1
- (CFIndex)touchContentOffsetAtPoint:(CGPoint)point{

    CFArrayRef lines = CTFrameGetLines(self.frameRef);
    
    if (!lines) {
        return -1;
    }
    
    CFIndex count = CFArrayGetCount(lines);
    
    //获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, 0), origins);
    
    //翻转坐标系
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
    transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
    
    CFIndex idx = -1;
    for (int i = 0; i<count; i++) {
        
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        //获得每一行的CGRect的信息
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        if (CGRectContainsPoint(rect, point)) {
            
            //将点击的坐标转换成相当于当前行的坐标
            CGPoint relativePoint = CGPointMake(point.x - CGRectGetMinX(rect), point.y - CGRectGetMinY(rect));
            
            //获取当前点击坐标对应的字符串偏移
            idx = CTLineGetStringIndexForPosition(line, relativePoint);
        }
        
    }
    return idx;
}

- (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point{
    
    CGFloat ascent = 0.0f;
    CGFloat desent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &desent, &leading);
    CGFloat height = ascent - desent;
    
    return CGRectMake(point.x, point.y, width, height);
}

- (void)clickAtIndex:(CFIndex)index{

    for (XZLabelLink *labelLink in self.linkArray) {
        if (NSLocationInRange(index, labelLink.range)) {
            self.linkClickBlock(labelLink);
            break;
        }
    }
    
    for (XZLabelEmail *labelEmail in self.emailArray) {
        if (NSLocationInRange(index, labelEmail.range)) {
            self.emailClickBlock(labelEmail);
            break;
        }
    }
}



@end
