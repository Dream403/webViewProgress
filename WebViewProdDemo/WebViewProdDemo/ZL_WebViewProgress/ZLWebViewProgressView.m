//
//  ZLWebViewProgressView.m
//  WebViewProdDemo
//
//  Created by snowlu on 2017/11/6.
//  Copyright © 2017年 LittleShrimp. All rights reserved.
//

#import "ZLWebViewProgressView.h"
NSString *completeRPCURLPath = @"/webviewprogress/complete";

static const CGFloat WebViewProgressInitialValue = 0.1f;
static const CGFloat WebViewProgressInteractiveValue = 0.9f;
static const CGFloat WebViewProgressFinalProgressValue = 0.9f;

@interface ZLWebViewProgressView ()
/**
 *  加载
 */
@property (nonatomic) NSUInteger loadingCount;
/**
 *  最大加载
 */
@property (nonatomic) NSUInteger maxLoadCount;
/**
 *  <#Description#>
 */
@property (strong, nonatomic) NSURL *currentURL;
/**
 *  <#Description#>
 */
@property (nonatomic) BOOL interactive;
/**
 *  进度
 */
@property (nonatomic)CGFloat  progress;
/*
 *  重置
 */
- (void)reset;
/**
 *
 */
@property (strong, nonatomic) ZLWebViewProgressBar  *progressView;

@end

@implementation ZLWebViewProgressView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxLoadCount = _loadingCount = 0;
        _interactive = NO;
    }
    
    return self;
}
- (void)startProgress
{
    if (self.progress < WebViewProgressInitialValue) {
        [self setProgress:WebViewProgressInitialValue];
    }
}

- (void)incrementProgress
{
    float progress = self.progress;
    float maxProgress = self.interactive?WebViewProgressFinalProgressValue:WebViewProgressInteractiveValue;
    float remainPercent = (float)self.loadingCount/self.maxLoadCount;
    float increment = (maxProgress-progress) * remainPercent;
    progress += increment;
    progress = fminf(progress, maxProgress);
    [self setProgress:progress];
}

- (void)completeProgress
{
    [self setProgress:1.f];
    
}

- (void)setProgress:(CGFloat)progress
{
    if (progress > _progress || progress == 0) {
        _progress = progress;
        
        if (self.progressView) {
            [self.progressView setProgress:progress animated:YES];
        }
    }
}

- (void)reset
{
    self.maxLoadCount = self.loadingCount = 0;
    self.interactive = NO;
    [self setProgress:0.f];
}

-(ZLWebViewProgressBar *)progressView{
    if (!_progressView) {
        
        UIViewController *viewController = (UIViewController*)self.webViewProxy;
        _progressView = [[ZLWebViewProgressBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(viewController.view.bounds), 1)];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        [viewController.view addSubview:_progressView];
        
    }
    return _progressView;
}
#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL ret = YES;
    
    if (self.webViewProxy) {
        if ([self.webViewProxy respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
            ret = [self.webViewProxy webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
        }
    }
    
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    
    BOOL isHTTP = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"];
    if (ret && !isFragmentJump && isHTTP && isTopLevelNavigation) {
        self.currentURL = request.URL;
        [self reset];
    }
    
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (self.webViewProxy && [self.webViewProxy respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.webViewProxy webViewDidStartLoad:webView];
    }
    
    self.loadingCount++;
    
    self.maxLoadCount = fmax(self.loadingCount, self.loadingCount);
    
    [self startProgress];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.webViewProxy && [self.webViewProxy respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.webViewProxy webViewDidFinishLoad:webView];
    }
    
    self.loadingCount--;
    [self incrementProgress];
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        self.interactive = interactive;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);",
                                       webView.request.mainDocumentURL.scheme,
                                       webView.request.mainDocumentURL.host,
                                       completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = self.currentURL && [self.currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect) {
        [self completeProgress];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (self.webViewProxy && [self.webViewProxy respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.webViewProxy webView:webView didFailLoadWithError:error];
    }
    
    _loadingCount--;
    
    [self incrementProgress];
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        self.interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if ((complete && isNotRedirect) || error) {
        [self completeProgress];
    }
}

#pragma mark - Method Forwarding
- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    if ([self.webViewProxy respondsToSelector:aSelector]) {
        return YES;
    }
    
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        if (self.webViewProxy && [self.webViewProxy respondsToSelector:aSelector]) {
            return [(NSObject *)self.webViewProxy methodSignatureForSelector:aSelector];
        }
    }
    
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if (self.webViewProxy && [self.webViewProxy respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:self.webViewProxy];
    }
}
@end
