//
//  FailToConnectController.swift
//  WatchAuthenticatior Extension
//
//  Created by 周昊炜 on 2018/12/3.
//  Copyright © 2018 周昊炜. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class FailToConnectController: WKInterfaceController {
    @IBOutlet weak var refreshButton : WKInterfaceButton!
    
    private lazy var watchSessionDelegater: WatchSessionDelegate = {
        return WatchSessionDelegate()
    }()

    override func awake(withContext context: Any?) {
        super.awake(withContext: nil)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).activationDidComplete(_:)),
            name: .activationDidComplete, object: nil
        )
        
        // Configure interface objects here.
    }
    
    @objc
    private func activationDidComplete(_ notification: Notification) {
        self.dismiss()
    }
}
