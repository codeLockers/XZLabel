//
//  ViewController.m
//  XZLabel
//
//  Created by 徐章 on 16/7/7.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "ViewController.h"
#import "XZLabel.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    XZLabelConfig *config = [[XZLabelConfig alloc] init];
    config.text = @"http://cn.bing.com/好的饿   http://baidu.com/发达省  codeLockers@outlook.com";
    
    XZLabel *label = [[XZLabel alloc] initWithConfig:config];
    label.frame = CGRectMake(0, 50, 300, 100);
    label.numberOfLines = 0;
    label.userInteractionEnabled = YES;
    label.linkClickBlock = ^(XZLabelLink *labelLink){
        
        NSLog(@"%@",labelLink.url);
    };
    
    label.emailClickBlock = ^(XZLabelEmail *labelemail){
        
        NSLog(@"%@",labelemail.email);
    };
    
    [self.view addSubview:label];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
