//
//  AppDelegate_iPad.h
//  NetHack-iOS
//
//  Created by Dirk Zimmermann on 7/6/10.
//  Copyright Dirk Zimmermann 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface AppDelegate_iPad : NSObject <UIApplicationDelegate> {

    UIWindow *window;
	NSThread *netHackThread;
	MainViewController *mainViewController;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;
@property (nonatomic, readonly) BOOL isGameWorthSaving;

@end

