//
//  WatchSessionManager.swift
//  Authenticator
//
//  Created by 周昊炜 on 2018/12/3.
//  Copyright © 2018 周昊炜. All rights reserved.
//

import Foundation
import WatchConnectivity
import ClockKit

// Custom notifications.
// Posted when Watch Connectivity activation or reachibility status is changed,
// or when data is received or sent. Clients observe these notifications to update the UI.
//
extension Notification.Name {
    static let dataDidFlow = Notification.Name("DataDidFlow")
    static let reachabilityDidChange = Notification.Name("ReachabilityDidChange")
    static let activationDidComplete = Notification.Name("ActivationDidComplete")
}


// Implement WCSessionDelegate methods to receive Watch Connectivity data and notify clients.
// WCsession status changes are also handled here.
//
class WatchSessionDelegate: NSObject, WCSessionDelegate {
    
    // Called when WCSession activation state is changed.
    //
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .activationDidComplete, object: nil)
        }
    }
    
    // Called when WCSession reachability is changed.
    //
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .reachabilityDidChange, object: nil)
        }
    }
    
    // Called when an app context is received.
    //
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .dataDidFlow, object: applicationContext)
        }
    }
    
}
