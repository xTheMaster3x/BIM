#import "BingBongWebViewController.h"
#import <objc/runtime.h>

@implementation BingBongWebViewController
-(void)setURL:(NSURL*)url {
    urlToLoad = url;
}
-(BOOL)isURLSecure:(NSURL*)url {
    if ([url.scheme isEqual:@"https"]) {
        return TRUE;
    }
    else {
        return FALSE;
    }
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    popupBrowserView = [[[objc_getClass("WKWebView") alloc] initWithFrame:self.view.frame] autorelease];
    [popupBrowserView setNavigationDelegate:self];
    [popupBrowserView loadRequest:[[[NSURLRequest alloc] initWithURL:urlToLoad] autorelease]];
    [self.view addSubview:popupBrowserView];
    loadingView = [[[UIProgressView alloc] initWithFrame:CGRectMake(0.0f, self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, [[UIScreen mainScreen] bounds].size.width, 9)] autorelease];
    //popupBrowserView.scalesPageToFit = YES;
    popupBrowserView.allowsBackForwardNavigationGestures = YES;
    [popupBrowserView addSubview:loadingView];

    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissView)] autorelease];
    UIBarButtonItem *refreshButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)] autorelease];
    UIBarButtonItem *fixedSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    fixedSpace.width = 30.0;
    UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *safariButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openInSafari)] autorelease];
    leftButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Bim/left.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)] autorelease];
    rightButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Bim/right.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goForward)] autorelease];
    [self setToolbarItems:[NSArray arrayWithObjects:leftButton, fixedSpace, rightButton, flexSpace, safariButton, nil]];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = refreshButton;
    leftButton.enabled = NO;
    rightButton.enabled = NO;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    popupBrowserView.frame = self.view.frame;
    loadingView.frame = CGRectMake(0.0f, self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, [[UIScreen mainScreen] bounds].size.width, 9);
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [progressTimer invalidate];
    progressTimer = nil;
    loadingView.hidden = FALSE;
    loadingView.alpha = 1.0;
    loadingView.progress = 0;
    loadingView.trackTintColor = [UIColor clearColor];
    isFinishedLoading = FALSE;
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(refreshProgress) userInfo:nil repeats:YES];
    self.navigationItem.title = @"Loading...";
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    isFinishedLoading = TRUE;
    if ([webView canGoBack]) {
        leftButton.enabled = YES;
    }
    else {
        leftButton.enabled = NO;
    }
    if ([webView canGoForward]) {
        rightButton.enabled = YES;
    }
    else {
        rightButton.enabled = NO;
    }
    if ([self isURLSecure:urlToLoad]) {
        NSString *lock = @"🔒";
        self.navigationItem.title = [lock stringByAppendingString:popupBrowserView.title];
    }
    else {
        self.navigationItem.title = popupBrowserView.title;
    }
}
-(void)refreshProgress {
    if (isFinishedLoading) {
        if (loadingView.progress >= 1) {
            [UIView animateWithDuration:0.3 delay:0.3 options:0 animations:^{
                loadingView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [progressTimer invalidate];
                progressTimer = nil;
            }];
        }
        else {
            loadingView.progress += 0.1;
        }
    }
    else {
        if (loadingView.progress >= popupBrowserView.estimatedProgress) {
            loadingView.progress = popupBrowserView.estimatedProgress;
        }
        else {
            loadingView.progress += 0.005;
        }
    }
}
-(void)dismissView {
    [self dismissViewControllerAnimated:YES completion:nil];
    [progressTimer invalidate];
    progressTimer = nil;
    //[[UIApplication sharedApplication] popupDismissed];
}
-(void)refresh {
    [popupBrowserView reload];
}
-(void)goForward {
    [popupBrowserView goForward];
}
-(void)goBack {
    [popupBrowserView goBack];
}
-(void)openInSafari {
    [[UIApplication sharedApplication] setBIMDismissed:true];
    [[UIApplication sharedApplication] openURL:popupBrowserView.URL];
    [self dismissView];
}
@end