//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Kristian Trenskow on 04/11/2016.
//  Copyright © 2016 trenskow.io. All rights reserved.
//

import UIKit
import NotificationCenter
import Shared

class TodayViewController: RemoteViewController, NCWidgetProviding {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: 0, height: 100)
        
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
}
