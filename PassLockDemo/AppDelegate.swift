//
//  AppDelegate.swift
//  PassLockDemo
//
//  Created by edison on 9/19/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import UIKit
import PassLock

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    lock()
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    lock()
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}

// MARK: - PassLock

extension AppDelegate: PassLockProtocol {
  private func lock() {
    if PassLockHelper.hasPassLock {
      let config = PassLockConfiguration(keychainConfig: PassLockHelper.keychain.config,
                                         usingTouchID: PassLockHelper.enableTouchID,
                                         passLockType: .Unlock)
      let controller = PassLockViewController.instantiateViewController(configration: config)
      controller.delegate = self
      controller.present(animated: false, completion: nil)
    }
  }
  
  func passLockController(passLockController: PassLockViewController, didUnlock result: Result<UnlockBy>) {
    print("\(#function) \(result)")
    switch result {
    case .Success(let unlockBy):
      switch unlockBy {
      case .Password:
        passLockController.passwordInputView.resignFirstResponder()
      case .TouchID:
        dispatch_async(dispatch_get_main_queue()) {
          passLockController.passwordInputView.resignFirstResponder()
        }
      }
      passLockController.dismiss(animated: true, completion: nil)
    default:
      PassLockHelper.deletePassLock()
      exit(0)
    }
  }
}
