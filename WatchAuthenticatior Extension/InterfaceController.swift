//
//  InterfaceController.swift
//  WatchAuthenticatior Extension
//
//  Created by 周昊炜 on 2018/12/3.
//  Copyright © 2018 周昊炜. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var button : WKInterfaceButton!
    @IBOutlet weak var codesTable : WKInterfaceTable!
    @IBOutlet weak var timerLabel : WKInterfaceLabel!
    
    
    private var message = ["Status": "Update"]
    
    @IBAction func sendContext() {
        updateAppContext(message)
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        //Add the notification observer  of the events which will trigger the custom action
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).dataDidFlow(_:)),
            name: .dataDidFlow, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).reachabilityDidChange(_:)),
            name: .reachabilityDidChange, object: nil
        )
        
        //Send a message via WCSession to exchange the needed data with iOS App
        self.updateAppContext(message)

        
    }

    override func didAppear() {

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    fileprivate func updateAppContext(_ context: [String: Any]) {
        WCSession.default.sendMessage(context, replyHandler: nil, errorHandler: { error in
            // Handle any errors here
            self.presentController(withName: "FailToConnectController", context: nil)
        });

//        guard WCSession.default.activationState == .activated else {
//            return presentController(withName: "FailToConnectController", context: nil)
//        }
//        do {
//            NSLog("yes")
//            try WCSession.default.updateApplicationContext(context)
//        } catch {
//            print("error")
//        }
    }
    
    @objc
    private func reachabilityDidChange(_ notification: Notification) {
        self.presentController(withName: "FailToConnectController", context: nil)
    }
    
    @objc
    private func dataDidFlow(_ notification: Notification) {
        guard var context = notification.object as? [String:[String]] else { return }
        print(context[(context.count-1).description]!)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let refreshTime = formatter.date(from: context[(context.count-1).description]![0])
        //let sendTime = formatter.date(from: context[(context.count-1).description]![0])
        let timeLapse = Int(refreshTime!.timeIntervalSince(Date()).rounded())
        //let realRefreshTime = refreshTime!.addingTimeInterval(TimeInterval(timeLapse))
        self.timerLabel.setText("Refresh in \(timeLapse)s")
        loadCodeTableItems(withContext: context)
        self.codeTimer(timeLapse)
        return
    }
    
    fileprivate func codeTimer(_ duration:Int) {
        var time = duration
        let codeTimer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: DispatchQueue.global())
        codeTimer.schedule(deadline: .now(), repeating: .milliseconds(1000))
        codeTimer.setEventHandler {
            time = time - 1
            
            DispatchQueue.main.async {
                self.timerLabel.setText("Refresh in \(time)s")
            }
            
            if time < 1 {
                codeTimer.cancel()
                DispatchQueue.main.async {
                    self.updateAppContext(self.message)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.timerLabel.setText("Refresh in \(time)s")
            }
            
        }
        
        codeTimer.activate()
    }
    
    fileprivate func loadCodeTableItems(withContext context: [String:[String]]) {

        // Configure the table object and get the row controllers.
        self.codesTable.setNumberOfRows(context.count-1, withRowType: "CodeTableRow")
        let rowCount = self.codesTable.numberOfRows

        // Iterate over the rows and set the label and image for each one.
        for i in 0 ..< rowCount {
            // Set the values for the row controller
            let row = self.codesTable.rowController(at: i) as! CodeTableRowController

            row.accountLabel.setText(context[i.description]![0])
            row.issuerLabel .setText(context[i.description]![1])
            row.codeLabel.setText(context[i.description]![2])
        }
    }
    

}
