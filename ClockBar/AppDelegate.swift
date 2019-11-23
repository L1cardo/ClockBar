//
//  AppDelegate.swift
//  ClockBar
//
//  Created by Licardo on 2019/11/8.
//  Copyright © 2019 Licardo. All rights reserved.
//

import Cocoa
import LoginServiceKit
import Defaults

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusBarMenu: NSMenu!
    @IBOutlet weak var preferencesWindowVersionNum: NSTextField!
    @IBOutlet weak var aboutWindowVersionNum: NSTextField!
    @IBOutlet weak var launchAtLoginCheckbox: NSButton!
    @IBOutlet weak var timeFormat12h: NSButton!
    @IBOutlet weak var timeFormat24h: NSButton!
    @IBOutlet weak var preferencesWindow: NSWindow!
    @IBOutlet weak var aboutWindow: NSWindow!
    @IBOutlet weak var alertWindow: NSWindow!
    
    var touchBarButton: NSButton?
    var timeFormatter: DateFormatter?
    let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // get current version
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        preferencesWindowVersionNum.stringValue = version
        aboutWindowVersionNum.stringValue = version
        
        // status bar
        displayStatusBarMenu()
   
        launchAtLoginCheckbox.state = LoginServiceKit.isExistLoginItems() ? .on : .off
        
        switch Defaults[.timeFormat] {
        case "h:mm":
            timeFormat12h.state = .on
            timeFormat24h.state = .off
        case "HH:mm":
            timeFormat12h.state = .off
            timeFormat24h.state = .on
        default:
            return
        }
        
        clockBar()
        
        // update time
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    // add clockbar to touch bar
    func clockBar() {
        DFRSystemModalShowsCloseBoxWhenFrontMost(true)

        timeFormatter = DateFormatter()
        timeFormatter?.dateFormat = Defaults[.timeFormat]
        let nowTime = timeFormatter?.string(from: Date())

        let clockBarIdentifier = NSTouchBarItem.Identifier(rawValue: "ClockBar")
        let clockBar = NSCustomTouchBarItem.init(identifier: clockBarIdentifier)
        touchBarButton = NSButton(title: nowTime!, target: nil, action: nil)
        clockBar.view = touchBarButton!
        NSTouchBarItem.addSystemTrayItem(clockBar)
        DFRElementSetControlStripPresenceForIdentifier(clockBarIdentifier, true)
    }
    
    // update time
    @objc func updateTime() {
        timeFormatter?.dateFormat = Defaults[.timeFormat]
        touchBarButton?.title = (timeFormatter?.string(from: Date()))!
    }
    
    // display status menu
    func displayStatusBarMenu() {
        guard let button = statusBarItem.button else { return }
        statusBarItem.button?.image = NSImage(named: "StatusBarIcon")
        button.action = #selector(statusBarMenuClicked)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    @objc func statusBarMenuClicked() {
        let event = NSApp.currentEvent!
        if event.type == .leftMouseUp || event.type == .rightMouseUp {
            statusBarItem.menu = statusBarMenu
            statusBarItem.button?.performClick(self)
            statusBarItem.menu = nil
        }
    }
    
    
    
    // click status bar menu item
    @IBAction func didClickStatusBarMenuItem(_ sender: NSMenuItem) {
        switch sender.tag {
        case 1:
            NSApp.activate(ignoringOtherApps: true)
            aboutWindow.close()
            preferencesWindow.makeKeyAndOrderFront(sender)
        case 3:
            NSApp.activate(ignoringOtherApps: true)
            preferencesWindow.close()
            aboutWindow.makeKeyAndOrderFront(sender)
        case 4:
            NSApp.activate(ignoringOtherApps: true)
            alertWindow.makeKeyAndOrderFront(sender)
        default:
            return
        }
    }
    
    // launch at login checkbox
    @IBAction func launchAtLoginChecked(_ sender: NSButton) {
        let isChecked = launchAtLoginCheckbox.state == .on
        if isChecked == true {
            LoginServiceKit.addLoginItems()
        } else {
            LoginServiceKit.removeLoginItems()
        }
    }
    
    @IBAction func timeFormat(_ sender: NSButton) {
        switch sender.tag {
        case 0:
            Defaults[.timeFormat] = "h:mm"
            timeFormat24h.state = .off
        case 1:
            Defaults[.timeFormat] = "HH:mm"
            timeFormat12h.state = .off
        default:
            return
        }
    }
    
    // preferences window close button
    @IBAction func preferencesWindowClosetButton(_ sender: Any) {
        preferencesWindow.close()
    }
    
    // preferences window quit button
    @IBAction func preferencesWindowQuitButton(_ sender: NSButton) {
        NSApp.activate(ignoringOtherApps: true)
        alertWindow.makeKeyAndOrderFront(sender)
    }
    
    // alert window yes button
    @IBAction func alertWindowYesButton(_ sender: NSButton) {
        NSApp.terminate(self)
    }
    
    // alert window cancel button
    @IBAction func alertWindowCancelButton(_ sender: NSButton) {
        alertWindow.close()
    }
    
    // about window urls
    @IBAction func didClickURL(_ sender: NSButton) {
        let url: String
        switch sender.tag {
        case 1:
            url = "https://github.com/L1cardo"
        case 2:
            url = "https://licardo.cn"
        case 3:
            url = "https://twitter.com/AlbertAbdilim"
        case 41:
            url = "https://paypal.me/mrlicardo"
        case 42:
            url = "https://raw.githubusercontent.com/L1cardo/Image-Hosting/master/donate/alipay.jpg"
        case 43:
            url = "https://raw.githubusercontent.com/L1cardo/Image-Hosting/master/donate/wechat.jpg"
        case 5:
            url = "mailto:albert.abdilim@foxmail.com"
        default:
            return
        }
        NSWorkspace.shared.open(URL(string: url)!)
    }


}

extension Defaults.Keys {
    static let timeFormat = Key<String>("timeFormat", default: "h:mm")
}
