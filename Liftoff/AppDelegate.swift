//
//  AppDelegate.swift
//  Liftoff
//
//  Created by Blackboxed on 2017-04-26.
//  Copyright © 2017 Blackboxed. All rights reserved.
//

import UIKit
import RaunchKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = UIColor(red:0.54, green:0.43, blue:0.62, alpha:1.00)
        Raunch.start()
        return true
    }

}

