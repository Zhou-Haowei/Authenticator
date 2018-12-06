//
//  WatchSessionManager.swift
//  Authenticator
//
//  Created by 周昊炜 on 2018/12/3.
//  Copyright © 2018 周昊炜. All rights reserved.
//


import Foundation
import WatchConnectivity
import OneTimePassword


// Custom notifications.
// Posted when Watch Connectivity activation or reachibility status is changed,
// or when data is received or sent. Clients observe these notifications to update the UI.
extension Notification.Name {
//    static let dataDidFlow = Notification.Name("DataDidFlow")
//    static let activationDidComplete = Notification.Name("ActivationDidComplete")
//    static let reachabilityDidChange = Notification.Name("ReachabilityDidChange")
}

// Implement WCSessionDelegate methods to receive Watch Connectivity data and notify clients.
// WCsession status changes are also handled here.
class SessionDelegate: NSObject, WCSessionDelegate {

    
    
    private var tokenList:TokenList = TokenList()
    private var store: TokenStore
    private let settings: Settings = Settings()
    
    override init() {
        do {
            store = DemoTokenStore()
//            if CommandLine.isDemo {
//                // If this is a demo, use a token store of mock data, not backed by the keychain.
//                store = DemoTokenStore()
//            } else {
//                store = try KeychainTokenStore(
//                    keychain: Keychain.sharedInstance,
//                    userDefaults: UserDefaults.standard
//                )
//            }
//        } catch {
//            // If the TokenStore could not be created, the app is unusable.
//            fatalError("Failed to load token store: \(error)")
        }

        super.init()
    }
    
    // Called when WCSession activation state is changed.
    //
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    // Called when WCSession reachability is changed.
    //
    func sessionReachabilityDidChange(_ session: WCSession) {
    
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            let (currentViewModel, nextRefreshTime) = self.tokenList.viewModel(with: self.store.persistentTokens,
                                                                               at: DisplayTime(date: Date()),
                                                                               digitGroupSize: self.settings.digitGroupSize)
            var context = [String:[String]]()
            for i in 0..<currentViewModel.rowModels.count {
                let accountArray:[String] = [
                    currentViewModel.rowModels[i].name,
                    currentViewModel.rowModels[i].issuer,
                    currentViewModel.rowModels[i].password,
                ]
                context[i.description] = accountArray
            }
            context[currentViewModel.rowModels.count.description] = [
                //Date().description,
                nextRefreshTime.description
            ]
            if #available(iOS 9.3, *) {
                guard WCSession.default.activationState == .activated else {
                    return
                }
                do {
                    try WCSession.default.updateApplicationContext(context)
                } catch {
                    print("error")
                }
            } else {
                // Fallback on earlier versions
                return
            }
        }
    }

    // Called when an app context is received.
    //
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        
    }
    
    // WCSessionDelegate methods for iOS only.
    //
    #if os(iOS)
    @available(iOS 9.3, *)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("activationState = \(session.activationState.rawValue)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Activate the new session after having switched to a new watch.
        session.activate()
    }

    @available(iOS 9.0, *)
    func sessionWatchStateDidChange(_ session: WCSession) {
        
    }
    
    #endif
}
