//
//  kakeiboAppDelegate.m
//  kakeibo
//
//  Created by hiro on 11/03/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Add_CategoryList.h"
#import "MyModel.h"
#import "Ana_Top.h"
#import "Sync_Top.h"
#import "Start_Login.h"

#import "GoogleCalender.h"

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}


@implementation AppDelegate

@synthesize window;
@synthesize tabBarController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    //NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	
    // Override point for customization after application launch.
	//設定値のデフォルトを定義
	NSDictionary* dic = @{@"IS_FIRST_EXEC": [NSNumber numberWithBool:TRUE],
						 @"NEXT_TMP_CAT_ID": @-1,
						 @"NEXT_TMP_HIS_ID": @-1,
						 @"NEXT_TMP_ANA_ID": @-1,
						 @"USR_NAME": @"",
						 @"USR_PASS": @"",
						 @"IS_REMEMBER_NAME_PASS": [NSNumber numberWithBool:FALSE],
						 @"IS_GRAPH_LINE": [NSNumber numberWithBool:FALSE],
						 @"DB_NAME": NSLocalizedString(@"STR-102", nil),
						 @"IS_ANA_MULTI": [NSNumber numberWithBool:TRUE],
						 @"IS_SORT_ASCEND": [NSNumber numberWithBool:FALSE],
						 @"MONEY_UNIT": NSLocalizedString(@"STR-032", nil),
						 @"IS_NARROW_CELL": [NSNumber numberWithBool:FALSE],
						 @"MONTH_END_DAY": @0,
						 @"SYNC_LOG": @"",
						 @"IS_HIDE_0": [NSNumber numberWithBool:FALSE],
						 @"DEFAULT_PERIOD": @1,
						 @"START_PASS": @"",
						 @"DEFAULT_PERSON": @"",};
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	[settings registerDefaults:dic];
	
	//クラッシュ検知
	//CrashController *crash = [CrashController sharedInstance];
	//crash.delegate = self;
	//[crash sendCrashReportsToEmail:@"oka.hirow.apple@gmail.com"	withViewController:self.tabBarController];
	
	
	//モデルの初期化
	g_model_ = [[MyModel alloc] init];
	
    // Add the tab bar controller's view to the window and display.
    [self.window addSubview:tabBarController.view];
    [self.window makeKeyAndVisible];
	
	GoogleCalender* cal = [GoogleCalender shared_obj];
	[cal sync_db];
	

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	
	//パスワードが設定されていたら
	if([[settings stringForKey:@"START_PASS"] isEqualToString:@""] == false){
		// ModalViewController生成
		Start_Login *modalViewController = [[Start_Login alloc] initWithNibName:@"Start_Login" bundle:nil];
		modalViewController.modalPresentationStyle = UIModalPresentationFullScreen;  // 画面を覆う
		
		[self.tabBarController dismissViewControllerAnimated:NO completion:^{
			NSLog(@"complete");
		}];
	}
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	UINavigationController* nc = (UINavigationController*)viewController;
	
	NSArray *allControllers = nc.viewControllers;
	
/*	
	//同期は止める
	if([allControllers count] >= 2){
		Sync_Top* sync_top = (Sync_Top*)[allControllers objectAtIndex:2];
		[sync_top cancel_sync];
	}
*/
	
	//入力
	if([viewController.tabBarItem.title isEqualToString:NSLocalizedString(@"STR-103", nil)]){		
		[nc popToRootViewControllerAnimated:NO];
	}
	//履歴
	else if([viewController.tabBarItem.title isEqualToString:NSLocalizedString(@"STR-213", nil)]){		
		[nc popToRootViewControllerAnimated:NO];
	}
	//集計
	else if([viewController.tabBarItem.title isEqualToString:NSLocalizedString(@"STR-104", nil)]){
		[nc popToRootViewControllerAnimated:NO];
		
		Ana_Top* top = (Ana_Top*)allControllers[0];
		
		[top reset_segment];
		[top get_ana_data];
		[top update_show_view];
	}
	//同期
	else if([viewController.tabBarItem.title isEqualToString:NSLocalizedString(@"STR-105", nil)]){
		[nc popToRootViewControllerAnimated:NO];
	}
	//設定
	else if([viewController.tabBarItem.title isEqualToString:NSLocalizedString(@"STR-010", nil)]){
		[nc popToRootViewControllerAnimated:NO];
	}
}


#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}



@end

