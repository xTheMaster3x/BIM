#import <CoreGraphics/CoreGraphics.h>
#import <WebKit/WebKit.h>

// @interface WKWebView : UIView <UIScrollViewDelegate>
// @property(nonatomic) BOOL allowsBackForwardNavigationGestures;
// -(NSString *)title;
// -(CGFloat)estimatedProgress;
// @end

// @interface WKNavigation : NSObject

// @end

// @protocol WKNavigationDelegate <NSObject>

// @end

@interface BingBongWebViewController : UIViewController <WKNavigationDelegate> {
    BOOL isFinishedLoading;
    UIProgressView* loadingView;
    NSTimer *progressTimer;
    NSTimer *waitTimer;
    WKWebView *popupBrowserView;
    NSURL *urlToLoad;
    UIBarButtonItem *leftButton;
    UIBarButtonItem *rightButton;
}
-(void)setURL:(NSURL*)url;
@end
