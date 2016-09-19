#import "BingBongWebViewController.h"

@interface SFSafariViewController : UIViewController
- (id)initWithURL:(id)arg1;
@end

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
static BOOL legacy = SYSTEM_VERSION_LESS_THAN(@"9.0");

static BOOL isEditing = FALSE;
static BOOL bypassBIM = FALSE;
static SFSafariViewController *webView = nil;

static BOOL isValidURL(NSURL* url) {
    [url retain];
    if ([url.scheme isEqual:@"http"] || [url.scheme isEqual:@"https"]) {
        return YES;
    }
    else {
        return NO;
    }
}

%group SMS
%hook SMSApplication
-(BOOL)openURL:(NSURL*)url {
    if (bypassBIM) {
        bypassBIM = false;
        return %orig(url);
    }
    if (isValidURL(url)) {
        if (isEditing) {
           [[self keyWindow].rootViewController.view endEditing:YES];
        }
        if (!legacy) {
            webView = [[%c(SFSafariViewController) alloc] initWithURL:url];
            [[self keyWindow].rootViewController presentViewController:webView animated:YES completion:nil];
            [webView release];
        }
        else {
            BingBongWebViewController *popupView = [[BingBongWebViewController alloc] init];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:popupView];
            [navController setToolbarHidden:NO animated:NO];
            [[self keyWindow].rootViewController presentViewController:navController animated:YES completion:nil];
            [popupView setURL:url];
            [popupView release];
            [navController release];
        }
        return FALSE;
    }
    else {
        return %orig(url);
    }
}
%new -(void)setBIMDismissed:(BOOL)dismissed {
    bypassBIM = dismissed;

}
%end
%hook CKTranscriptController
-(void)messageEntryViewDidBeginEditing:(id)arg1 {
    isEditing = TRUE;
}
-(void)messageEntryViewDidEndEditing:(id)arg1 {
    isEditing = FALSE;
}
%end
%end

%group Mail
%hook MailAppController
-(BOOL)openURL:(NSURL*)url {
    if (bypassBIM) {
        bypassBIM = FALSE;
        return %orig(url);
    }
    if (isValidURL(url)) {
        if (!legacy) {
            webView = [[%c(SFSafariViewController) alloc] initWithURL:url];
            [[self keyWindow].rootViewController presentViewController:webView animated:YES completion:nil];
            [webView release];
        }
        else {
            BingBongWebViewController *popupView = [[BingBongWebViewController alloc] init];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:popupView];
            [navController setToolbarHidden:NO animated:NO];
            [[self keyWindow].rootViewController presentViewController:navController animated:YES completion:nil];
            [popupView setURL:url];
            [popupView release];
            [navController release];
        }
        return FALSE;
    }
    else {
        return %orig(url);
    }
}
%new -(void)setBIMDismissed:(BOOL)dismissed {
    bypassBIM = dismissed;
}
%end
%end

%ctor {
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.MobileSMS"]) {
        HBLogDebug(@"BIM - MobileSMS Hooked, loading...")
        %init(SMS);
    }
    else {
        if ([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.mobilemail"]) {
            HBLogDebug(@"BIM - MobileMail Hooked, loading...")
            %init(Mail);
        }
    }
}