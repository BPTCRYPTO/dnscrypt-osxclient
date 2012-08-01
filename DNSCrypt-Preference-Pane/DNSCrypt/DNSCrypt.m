//
//  DNSCrypt.m
//  DNSCrypt
//
//  Created by OpenDNS, Inc. on 8/11/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#import "DNSCrypt.h"

@implementation DNSCrypt
@synthesize previewNotesWebView = _previewNotesWebView;
@synthesize releaseNotesWebView = _releaseNotesWebView;
@synthesize feedbackWebView = _feedbackWebView;
@synthesize aboutWebView = _aboutWebView;

@synthesize dnscryptButton = _dnscryptButton;
@synthesize opendnsButton = _opendnsButton;
@synthesize fallbackButton = _fallbackButton;
@synthesize familyShieldButton = _familyShieldButton;
@synthesize statusImageView = _statusImageView;
@synthesize statusText = _statusText;
@synthesize currentResolverTextField = _currentResolverTextField;

DNSConfigurationState currentState = kDNS_CONFIGURATION_UNKNOWN;

- (NSString *) fromCommand: (NSString *) launchPath withArguments: (NSArray *) arguments
{
    NSPipe *pipe = [NSPipe pipe];
    NSTask *task = [[NSTask alloc] init];
    NSData *data;
    NSString *result;
    task.launchPath = launchPath;
    task.arguments = arguments;
    task.standardOutput = pipe;
    [task launch];
    data = [[pipe fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];
    [task release];
    result = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    if ([result hasSuffix: @"\n"]) {
        result = [result substringToIndex: result.length - 1];
    }
    return result;
}

- (void) initState
{
    NSString *res;

    _dnscryptButton.state = 0;
    _familyShieldButton.state = 0;
    _opendnsButton.state = 0;
    _fallbackButton.state = 0;
    
    res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./get-dnscrypt-status.sh", nil]];
    NSLog(@"%@", res);
    if ([res isEqualToString: @"yes"]) {
        [_dnscryptButton setState: 1];
    }
    res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./get-familyshield-status.sh", nil]];
    NSLog(@"%@", res);
    if ([res isEqualToString: @"yes"]) {
        [_familyShieldButton setState: 1];
    }
    res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./get-insecure-opendns-status.sh", nil]];
    NSLog(@"%@", res);
    if ([res isEqualToString: @"yes"]) {
        [_opendnsButton setState: 1];
    }
    res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./get-fallback-status.sh", nil]];
    NSLog(@"%@", res);
    if ([res isEqualToString: @"yes"]) {
        [_fallbackButton setState: 1];
    }

}

- (BOOL) setDNSCryptOn {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./switch-to-dnscrypt.sh", nil]];
    NSLog(@"%@", res);
    return TRUE;
}

- (BOOL) setDNSCryptOff {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./switch-to-dhcp.sh", nil]];
    NSLog(@"%@", res);
    return TRUE;
}

- (BOOL) setFamilyShieldOn {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./switch-familyshield-on.sh", nil]];
    NSLog(@"%@", res);
    return TRUE;
}

- (BOOL) setFamilyShieldOff {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./switch-familyshield-off.sh", nil]];
    NSLog(@"%@", res);
    return TRUE;
}

- (BOOL) setInsecureOpenDNSOn {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./switch-insecure-opendns-on.sh", nil]];
    NSLog(@"%@", res);
    return TRUE;
}

- (BOOL) setInsecureOpenDNSOff {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./switch-insecure-opendns-off.sh", nil]];
    NSLog(@"%@", res);
    return TRUE;
}

- (BOOL) setFallbackOn {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./switch-fallback-on.sh", nil]];
    NSLog(@"%@", res);
    return TRUE;
}

- (BOOL) setFallbackOff {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./switch-fallback-off.sh", nil]];
    NSLog(@"%@", res);
    return TRUE;
}

- (IBAction)dnscryptButtonPressed:(NSButton *)sender
{
    if (sender.state != 0) {
        [self setDNSCryptOn];
    } else {
        [self setDNSCryptOff];
    }
}

- (IBAction)opendnsButtonPressed:(NSButton *)sender
{
    if (sender.state != 0) {
        [self setInsecureOpenDNSOn];
    } else {
        [self setInsecureOpenDNSOn];
    }
}

- (IBAction)familyShieldButtonPressed:(NSButton *)sender
{
    if (sender.state != 0) {
        [self setFamilyShieldOn];
    } else {
        [self setFamilyShieldOff];
    }
}

- (IBAction)fallbackButtonPressed:(NSButton *)sender
{
    if (sender.state != 0) {
        [self setFallbackOn];
    } else {
        [self setFallbackOff];
    }
}

- (void) initializeCheckBoxesWithState: (DNSConfigurationState) currentState
{
    switch (currentState) {
        case kDNS_CONFIGURATION_OPENDNS:
            _opendnsButton.state = NSOnState;
            _dnscryptButton.state = NSOffState;
            break;

        case kDNS_CONFIGURATION_LOCALHOST:
            _opendnsButton.state = NSOnState;
            _dnscryptButton.state = NSOnState;
            break;

        default:
            _opendnsButton.state = NSOffState;
            _dnscryptButton.state = NSOffState;
    }
    _fallbackButton.state = NSOnState;
}

- (void) updateLedStatus
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier: @"com.opendns.osx.DNSCrypt"];
    switch (currentState) {
        case kDNS_CONFIGURATION_UNKNOWN:
            _statusText.stringValue = NSLocalizedString(@"No network", @"Status");
            _statusImageView.image = [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"shield_red.png"]] autorelease];
            break;
        case kDNS_CONFIGURATION_VANILLA:
            _statusText.stringValue = NSLocalizedString(@"Unprotected", @"Status");
            _statusImageView.image = [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"shield_red.png"]] autorelease];
            break;
        case kDNS_CONFIGURATION_OPENDNS:
            _statusText.stringValue = NSLocalizedString(@"Unencrypted", @"Status");
            _statusImageView.image = [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"shield_yellow.png"]] autorelease];
            break;
        case kDNS_CONFIGURATION_LOCALHOST:
            _statusText.stringValue = NSLocalizedString(@"Protected", @"Status");
            _statusImageView.image = [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"shield_green.png"]] autorelease];
            break;
        default:
            return;
    }
}

- (BOOL) updateStatusWithCurrentConfig
{
    currentState = kDNS_CONFIGURATION_UNKNOWN;

    NSString *stateDescription = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./get-current-resolvers.sh | ./get-resolvers-description.sh", nil]];
    NSLog(@"%@", stateDescription);
    if ([stateDescription isEqualToString: @"FamilyShield"]) {
        currentState = kDNS_CONFIGURATION_OPENDNS;
    } else if ([stateDescription isEqualToString: @"DNSCrypt"]) {
        currentState = kDNS_CONFIGURATION_LOCALHOST;
    } else if ([stateDescription isEqualToString: @"OpenDNS"]) {
        currentState = kDNS_CONFIGURATION_OPENDNS;
    } else if ([stateDescription isEqualToString: @"OpenDNS IPv6"]) {
        currentState = kDNS_CONFIGURATION_OPENDNS;
    } else if ([stateDescription isEqualToString: @"None"]) {
        currentState = kDNS_CONFIGURATION_UNKNOWN;
    } else if ([stateDescription isEqualToString: @"Updating"]) {
        currentState = kDNS_CONFIGURATION_UNKNOWN;
        return FALSE;
    } else if (stateDescription.length > 0) {
        currentState = kDNS_CONFIGURATION_VANILLA;
    }
    [self updateLedStatus];
    
    NSString *currentResolvers = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./get-current-resolvers.sh | ./get-upstream-resolvers.sh", nil]];
    _currentResolverTextField.stringValue = currentResolvers;

    return TRUE;
}

- (void) showSpinners {
    NSBundle *bundle = [NSBundle bundleWithIdentifier: kBUNDLE_IDENTIFIER];

    _statusText.stringValue = @"";
    _statusImageView.image = [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"ajax-loader.gif"]] autorelease];
    _currentResolverTextField.stringValue = @"";
}

- (void) periodicallyUpdateStatusWithCurrentConfig {
    [self updateStatusWithCurrentConfig];
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(periodicallyUpdateStatusWithCurrentConfig) object: nil];
    [self performSelector: @selector(periodicallyUpdateStatusWithCurrentConfig) withObject:nil afterDelay: 0.7];
}

- (void) mainViewDidLoad
{
    currentState = kDNS_CONFIGURATION_UNKNOWN;
    [_previewNotesWebView setDrawsBackground:false];
    
    [self initState];
    [self periodicallyUpdateStatusWithCurrentConfig];

    NSString *version = kDNSCRYPT_PACKAGE_VERSION;
    NSString *softwareBlurbFormat = NSLocalizedString(@"This software (v: %@) encrypts DNS packets between your computer and OpenDNS.  This prevents man-in-the-middle attacks and snooping of DNS traffic by ISPs or others.", @"Description of what the package does - %@ is replaced by the version number");
    NSString *provideFeedback = NSLocalizedString(@"Please help by providing feedback!", @"Ask for feedback");
    NSString *describeTCPWorkaround = NSLocalizedString(@"If you have a firewall or other middleware mangling your packets, try enabling DNSCrypt with TCP over port 443.", @"Describe what the TCP/443 checkbox does");
    NSString *describeFallback = NSLocalizedString(@"If you prefer reliability over security, enable fallback to insecure DNS.", @"Describe what the 'fallback to insecure mode' checkbox does");

    NSMutableString *htmlString = [NSMutableString stringWithString: @"<html><body style=\"font-family:Helvetica, sans-serif; font-size: 11px; color: #333; margin: 0px; padding: 2px 0px;\">"];

    [htmlString appendFormat: softwareBlurbFormat, version];
    [htmlString appendString: @"<br/><br/>"];
    [htmlString appendString: @"<strong>"];
    [htmlString appendString: provideFeedback];
    [htmlString appendString: @"</strong>"];
    [htmlString appendString: @"<ul style=\"list-style-position: inside; list-style-type: square; padding-left: 0px; margin-top: 0; margin-bottom: 0; \">"];
    [htmlString appendFormat: @"<li>%@</li>", describeTCPWorkaround];
    [htmlString appendFormat: @"<li>%@</li>", describeFallback];
    [htmlString appendString: @"</ul>"];
    [htmlString appendString: @"</body></html>"];
    [[_previewNotesWebView mainFrame] loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"file:///"]];

    [_feedbackWebView setDrawsBackground:false];
    [_feedbackWebView setShouldUpdateWhileOffscreen:true];
    [_feedbackWebView setUIDelegate:self];
    NSString *feedbackURLText = @"http://dnscrypt.opendns.com/feedback.php";
    [[_feedbackWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:feedbackURLText]]];

    [_releaseNotesWebView setDrawsBackground:false];
    [_releaseNotesWebView setShouldUpdateWhileOffscreen:true];
    [_releaseNotesWebView setUIDelegate:self];
    NSString *releaseNotesURLText = @"http://dnscrypt.opendns.com/releasenotes.php";
    [[_releaseNotesWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:releaseNotesURLText]]];

    [_aboutWebView setDrawsBackground:false];
    [_aboutWebView setShouldUpdateWhileOffscreen:true];
    [_aboutWebView setUIDelegate:self];
    NSString *aboutURLText = @"http://dnscrypt.opendns.com/about.php";
    [[_aboutWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:aboutURLText]]];
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element
    defaultMenuItems:(NSArray *)defaultMenuItems
{
    // disable right-click context menu
    return nil;
}

- (BOOL) updateConfig
{
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(resetCheckBoxesHaveBeenInitialized) object: nil];
    [self performSelector: @selector(resetCheckBoxesHaveBeenInitialized) withObject: self afterDelay:kCHECKBOXES_FREEZE_DELAY];
    if (_dnscryptButton.state == NSOffState) {
        if (_opendnsButton.state == NSOffState) {
            currentState = kDNS_CONFIGURATION_VANILLA;
        } else {
            currentState = kDNS_CONFIGURATION_OPENDNS;
        }
    } else {
    }
    [self periodicallyUpdateStatusWithCurrentConfig];
    [self showSpinners];

    return TRUE;
}

- (IBAction)openDNSLinkPushed:(NSButton *)sender
{
    (void) sender;
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: kOPENDNS_URL]];
}


@end
