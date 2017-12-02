//
//  AppDelegate.swift
//  Watts-ON
//
//  Created by Diego Silva on 9/19/15.
//  Copyright (c) 2015 SudoCRUD. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // set the status bar color
        UIApplication.shared.statusBarStyle = .lightContent
        
        // subclassing
        PFUser.registerSubclass()
        
        // enable cache with the call:
        Parse.enableLocalDatastore()
        
        Parse.setApplicationId(
            "HwQhHlTelzYC8QdDWP8ZYDrdzAMJRURfW1ZtxYM3",
            clientKey: "7dCcNEdfUaEPk3s5NnjqlqsB0pXcKFUUQGu54to2"
        )
        
        // enable the revocable session for users on background, it makes renewable sessions possible
        PFUser.enableRevocableSessionInBackground()
        
        // passes the current application and the launch options to facebook
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
    
    
    // Facebook mandatory method
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    

    /*
        Sent when the application is about to move from active to inactive state. This can occur for 
        certain types of temporary interruptions (such as an incoming phone call or SMS message) or 
        when the user quits the application and it begins the transition to the background state.
    
        Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame 
        rates. Games should use this method to pause the game.
    */
    func applicationWillResignActive(_ application: UIApplication) {
        print("\napplication will resing active for user \(PFUser.current())...")
    }

    
    /*
        Use this method to release shared resources, save user data, invalidate timers, and store 
        enough application state information to restore your application to its current state in 
        case it is terminated later.
    
        If your application supports background execution, this method is called instead of 
        applicationWillTerminate: when the user quits.
    */
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("\napplication is going to background ...")
    }

    
    /*
        Called as part of the transition from the background to the inactive state; here you can 
        undo many of the changes made on entering the background.
    */
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("\napplication will enter foreground ...")
    }

    
    /*
        Restart any tasks that were paused (or not yet started) while the application was inactive. 
        If the application was previously in the background, optionally refresh the user interface.
    */
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("\napplication did become active ...")
    }
    

    /* 
        Called when the application is about to terminate. Save data if appropriate. See also
        applicationDidEnterBackground:.
    */
    func applicationWillTerminate(_ application: UIApplication) {
        print("\nuser is terminating app, normalizing session variables \(PFUser.current()) ...")
    }


}

