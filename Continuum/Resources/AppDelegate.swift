//
//  AppDelegate.swift
//  Continuum
//
//  Created by DevMountain on 2/11/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        application.applicationIconBadgeNumber = 0
        
        // Use this to suppress warnings about auto layout constraints and make debugging console easier to read
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // Check to see if the user is signed in to their iCloud Account
        checkAccountStatus { [weak self] (accountAvailable) in
            // Present an error alert if the account is not available
            if !accountAvailable {
                DispatchQueue.main.async {
                    self?.window?.rootViewController?.presentErrorAlert(for: "Error: Account Not Available", message: "Please make sure you are signed in to your iCloud account on this device and try again.")
                }
            }
        }
        
        // Request permissions to send notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (userDidAllow, error) in
                   if let error = error { print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)") }
                   
                   if userDidAllow {
                       DispatchQueue.main.async {
                           UIApplication.shared.registerForRemoteNotifications()
                       }
                   }
               }
        
        return true
    }
    
    func checkAccountStatus(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { (accountStatus, error) in
            // Handle any errors
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false) }
            
            // Deal with the account status
            switch accountStatus {
            case .available:
                return completion(true)
            default:
                return completion(false)
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

