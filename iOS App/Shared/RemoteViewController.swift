//
//  RemoteViewController.swift
//  Remote
//
//  Created by Kristian Trenskow on 30/07/16.
//  Copyright © 2016 trenskow.io. All rights reserved.
//

import UIKit
import CoreBluetooth

public class RemoteButton : UIButton {
    @IBInspectable var command: UInt8 = 0
}

public extension Remote.State {
    
    var valueLED: UIImage {
        switch self {
        case .connecting:
            fallthrough
        case .disconnecting:
            return #imageLiteral(resourceName: "Yellow")
        case .connected:
            return #imageLiteral(resourceName: "Green")
        case .disconnected:
            return #imageLiteral(resourceName: "Red")
        }
    }
    
}

open class RemoteViewController: UIViewController, CBPeripheralDelegate {
        
    @IBOutlet public var allButtons: [RemoteButton]!
    
    @IBOutlet public weak var imageViewStatusLED: UIImageView!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(remoteStateChanged(notification:)), name: nil, object: Remote.default)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Remote.default.connect()
        updateLED()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Remote.default.disconnect()
        updateLED()
    }
    
    public func updateLED() {
        imageViewStatusLED.image = Remote.default.state.valueLED
    }
    
    func remoteStateChanged(notification: Notification) {
        updateLED()
    }
    
    @IBAction public func stateChanged(_ sender: RemoteButton) {
        
        let command: UInt8 = allButtons
            .filter({ $0.isTracking })
            .map({ $0.command })
            .reduce(0, +)
        
        Remote.default.do(command: Remote.Command(rawValue: command))
        
    }
    
}
