//
//  AppDelegate_iPad.m
//  NetHack-iOS
//
//  Created by Dirk Zimmermann on 7/6/10.
//  Copyright Dirk Zimmermann 2010. All rights reserved.
//

#import "AppDelegate_iPad.h"
#import "MainViewController.h"

#import "winios.h"

#include <sys/stat.h>

extern int unixmain(int argc, char **argv);

@implementation AppDelegate_iPad

@synthesize window;
@synthesize mainViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)isGameWorthSaving {
	return !program_state.gameover && program_state.something_worth_saving;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	[window addSubview:mainViewController.view];
    [window makeKeyAndVisible];
	
	netHackThread = [[NSThread alloc] initWithTarget:self selector:@selector(netHackMainLoop:) object:nil];
	[netHackThread start];
	
	return YES;
}


- (void)cleanUpLocks {
	// clean up locks / levelfiles
	delete_levelfile(ledger_no(&u.uz));
	delete_levelfile(0);
}

- (void)saveAndQuitGame {
	if (self.isGameWorthSaving) {
		dosave0();
	} else {
		[self cleanUpLocks];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
	[self saveAndQuitGame];
}


- (void) netHackMainLoop:(id)arg {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	char *argv[] = {
		"NetHack",
	};
	int argc = sizeof(argv)/sizeof(char *);
	
	// create necessary directories
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *baseDirectory = [paths objectAtIndex:0];
	DLog(@"baseDir %@", baseDirectory);
	setenv("NETHACKDIR", [baseDirectory cStringUsingEncoding:NSASCIIStringEncoding], 1);
	//setenv("SHOPTYPE", "G", 1); // force general stores on every level in wizard mode
	NSString *saveDirectory = [baseDirectory stringByAppendingPathComponent:@"save"];
	mkdir([saveDirectory cStringUsingEncoding:NSASCIIStringEncoding], 0777);
	
	// show directory (for debugging)
#if 0	
	for (NSString *filename in [[NSFileManager defaultManager] enumeratorAtPath:baseDirectory]) {
		DLog(@"%@", filename);
	}
#endif
	
	// set plname (very important for save files and getlock)
	[[NSUserName() capitalizedString] getCString:plname maxLength:PL_NSIZ encoding:NSASCIIStringEncoding];
	
	// call Slash'EM
	unixmain(argc, argv);
	
	// clean up thread pool
	[pool drain];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
