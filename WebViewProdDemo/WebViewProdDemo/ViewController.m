//
//  ViewController.m
//  WebViewProdDemo
//
//  Created by snowlu on 2017/11/6.
//  Copyright © 2017年 LittleShrimp. All rights reserved.
//

#import "ViewController.h"
#import "ZLWebViewProgressView.h"
@interface ViewController ()<UIWebViewDelegate>
{
    
ZLWebViewProgressView *_webViewProgress;
    

}
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _webViewProgress = [[ZLWebViewProgressView alloc] init];
    
    self.webView.delegate  =_webViewProgress;
    
    _webViewProgress.webViewProxy  =self ;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
