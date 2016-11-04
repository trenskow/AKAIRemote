//
//  AppDelegate.swift
//  Remote
//
//  Created by Kristian Trenskow on 29/07/16.
//  Copyright © 2016 trenskow.io. All rights reserved.
//

import UIKit
import CoreBluetooth
import Shared

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RemoteDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Remote.default.delegate = self
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        UIApplication.shared.windows.forEach { (window) in
            window.rootViewController?.beginAppearanceTransition(false, animated: false)
            window.rootViewController?.endAppearanceTransition()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.windows.forEach { (window) in
            window.rootViewController?.beginAppearanceTransition(true, animated: false)
            window.rootViewController?.endAppearanceTransition()
        }
    }
    
    var backgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    func remote(_ remote: Remote, didChangeState state: Remote.State) {
        switch state {
        case .disconnecting:
            backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        case .disconnected where backgroundTaskIdentifier != UIBackgroundTaskInvalid:
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        default:
            break
        }
    }
    
}
