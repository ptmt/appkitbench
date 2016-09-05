//
//  AppDelegate.m
//  AppKitBench
//
//  Created by Dmitriy Loktev on 8/21/16.
//  Copyright © 2016 Frontendy. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _window.delegate = self;
//    {
//    name: 'John',
//    data: [0, 1, 4, 4, 5, 2, 3, 7]
//    }, {
//    name: 'Jane',
//    data: [1, 0, 3, null, 3, 1, 2, 1]
//    }]
    NSMutableArray *creationDictionary = [[NSMutableArray alloc] init];
    [creationDictionary addObject:[self measure:@"addVanillaViewsAtTopLevel:"]];
    [creationDictionary addObject:[self measure:@"addVanillaViewsAsATree:"]];
    [creationDictionary addObject:[self measure:@"addLayerHostingViews:"]];
    [creationDictionary addObject:[self measure:@"addLayerHostingViewsWithPolicy:"]];
    [creationDictionary addObject:[self measure:@"addLayerBackedViews:"]];
    [creationDictionary addObject:[self measure:@"addLayerBackedViewsWithPolicy:"]];
    NSLog(@"write to file: creation_timings.json");
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:creationDictionary
                        options:NSJSONWritingPrettyPrinted error:&writeError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [jsonString writeToFile:@"creation_timings.json"
        atomically:NO
        encoding:NSStringEncodingConversionAllowLossy
        error:&writeError];
    NSLog(@"%@", writeError);
    [NSApp terminate:nil];
}

- (NSDictionary *)measure:(NSString *)methodToMeasure {
    NSMutableArray *creation = [[NSMutableArray alloc] init];
    NSMutableArray *resize = [[NSMutableArray alloc] init];
    SEL method = NSSelectorFromString(methodToMeasure);
    for (int N = 10; N<10000; N+=100) {
        CFTimeInterval elapsedTime = [[self performSelector:method
                                                 withObject:[NSNumber numberWithInt:N]] doubleValue];
        [creation addObject:@[@(N), @(elapsedTime)]];
        [resize addObject:@[@(N), @([self resizeAllViews])]];
        [self clearAllViews];
    }
    NSLog(@"measured: %@", methodToMeasure);
    return @{
             @"name": methodToMeasure,
             @"creation": creation,
             @"resize": resize
             };
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (CFTimeInterval)addVanillaViewsAtTopLevel:(NSNumber *)N {
    CFTimeInterval startTime = CACurrentMediaTime();
    for (int i = 0; i < [N intValue]; i++) {
        NSView *subview = [[NSView alloc] initWithFrame:[self calcRect:_window.frame]];
        [_window.contentView addSubview:subview];
    }
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    //NSLog(@"addVanillaViewsAtTopLevel: Created %@ views in %f ms", N, elapsedTime);
    return elapsedTime;
}

- (CFTimeInterval)addVanillaViewsAsATree:(NSNumber *)N {
    CFTimeInterval startTime = CACurrentMediaTime();
    NSView *currentView =_window.contentView;
    for (int i = 0; i < [N intValue]; i++) {
        NSView *subview = [[NSView alloc] initWithFrame:[self calcRect:currentView.frame]];
        [currentView addSubview:subview];
        currentView = subview;
    }
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    //NSLog(@"addVanillaViewsAsATree: Created %@ views in %f ms", N, elapsedTime);
    return elapsedTime;
}

- (CFTimeInterval)addLayerHostingViews:(NSNumber *) N {
    CFTimeInterval startTime = CACurrentMediaTime();
    NSView *currentView =_window.contentView;
    for (int i = 0; i < [N intValue]; i++) {
        NSView *subview = [[NSView alloc] initWithFrame:[self calcRect:currentView.frame]];
        [subview setWantsLayer:YES];
        CALayer* hostedLayer = [CALayer layer];
        [subview setLayer:hostedLayer];
        [currentView addSubview:subview];
        currentView = subview;
    }
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    //NSLog(@"addLayerHostingViews, Created in %f ms", elapsedTime);
    return elapsedTime;
}

- (CFTimeInterval)addLayerHostingViewsWithPolicy:(NSNumber *) N {
    CFTimeInterval startTime = CACurrentMediaTime();
    NSView *currentView =_window.contentView;
    for (int i = 0; i < [N intValue]; i++) {
        NSView *subview = [[NSView alloc] initWithFrame:[self calcRect:currentView.frame]];
        [subview setWantsLayer:YES];
        CALayer* hostedLayer = [CALayer layer];
        [subview setLayer:hostedLayer];
        [subview setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawOnSetNeedsDisplay];
        [currentView addSubview:subview];
        currentView = subview;
    }
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    //NSLog(@"addLayerHostingViews, Created in %f ms", elapsedTime);
    return elapsedTime;
}

- (CFTimeInterval)addLayerBackedViews:(NSNumber *) N {
    CFTimeInterval startTime = CACurrentMediaTime();
    NSView *currentView =_window.contentView;
    for (int i = 0; i < [N intValue]; i++) {
        NSView *subview = [[NSView alloc] initWithFrame:[self calcRect:currentView.frame]];
        [subview setWantsLayer:YES];
        [currentView addSubview:subview];
        currentView = subview;
    }
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    //NSLog(@"addLayerBackedViews, Created in %f ms", elapsedTime);
    return elapsedTime;
}

- (CFTimeInterval)addLayerBackedViewsWithPolicy:(NSNumber *) N {
    CFTimeInterval startTime = CACurrentMediaTime();
    NSView *currentView =_window.contentView;
    for (int i = 0; i < [N intValue]; i++) {
        NSView *subview = [[NSView alloc] initWithFrame:[self calcRect:currentView.frame]];
        [subview setWantsLayer:YES];
        [subview setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawOnSetNeedsDisplay];
        [currentView addSubview:subview];
        currentView = subview;
    }
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    // NSLog(@"addLayerBackedViewsWithPolicy, Created in %f ms", elapsedTime);
    return elapsedTime;
}

- (void)clearAllViews {
    CFTimeInterval startTime = CACurrentMediaTime();
    while (_window.contentView.subviews.count > 0) {
        NSView* view = _window.contentView.subviews.firstObject;
        [view removeFromSuperview];
    }
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    // NSLog(@"Removed views in %f ms", elapsedTime);
}

- (NSRect)calcRect:(NSRect)parentRect {
    CGFloat x = parentRect.origin.x;
    CGFloat y = parentRect.origin.y;
    CGFloat w = parentRect.size.width - arc4random_uniform(10);
    CGFloat h = parentRect.size.height - arc4random_uniform(10);
    return NSMakeRect(x, y, w, h);
}

- (void)resizeView:(NSView *)view {
    [view setFrameSize:[self calcRect:view.frame].size];
    for (NSView* subview in view.subviews) {
        [self resizeView:subview];
    }
}

- (CFTimeInterval)resizeAllViews {
    CFTimeInterval startTime = CACurrentMediaTime();
    for (NSView* subview in _window.contentView.subviews) {
        [self resizeView:subview];
    }
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    return elapsedTime;
}

- (void)windowDidResize:(NSNotification *)notification {
    [self resizeAllViews];
}

@end
