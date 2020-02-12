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
class AppDelegate: NSObject, NSApplicationDelegate, NSTextFieldDelegate {

    @IBOutlet weak var statusBarMenu: NSMenu!
    @IBOutlet weak var preferencesWindowVersionNum: NSTextField!
    @IBOutlet weak var aboutWindowVersionNum: NSTextField!
    @IBOutlet weak var launchAtLoginCheckbox: NSButton!
    @IBOutlet weak var time1Text: NSTextField!
    @IBOutlet weak var time2Text: NSTextField!
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
        
        time1Text.delegate = self
        time2Text.delegate = self
        time1Text.stringValue = Defaults[.time1]
        time2Text.stringValue = Defaults[.time2]
        
        clockBar()
        
        // update time
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func showTime() {
        switch Defaults[.shouldShowTime1] {
        case true:
            Defaults[.showTime] = Defaults[.time1]
        default:
            Defaults[.showTime] = Defaults[.time2]
        }
    }
    
    func controlTextDidChange(_ obj: Notification) {
        Defaults[.time1] = time1Text.stringValue
        Defaults[.time2] = time2Text.stringValue
        showTime()
    }
    
    // add clockbar to touch bar
    func clockBar() {
        DFRSystemModalShowsCloseBoxWhenFrontMost(true)

        timeFormatter = DateFormatter()
        timeFormatter?.dateFormat = Defaults[.showTime]
        let nowTime = timeFormatter?.string(from: Date())

        let clockBarIdentifier = NSTouchBarItem.Identifier(rawValue: "ClockBar")
        let clockBar = NSCustomTouchBarItem.init(identifier: clockBarIdentifier)
        touchBarButton = NSButton(title: nowTime!, target: self, action: #selector(changeTime))
        clockBar.view = touchBarButton!
        NSTouchBarItem.addSystemTrayItem(clockBar)
        DFRElementSetControlStripPresenceForIdentifier(clockBarIdentifier, true)
    }
    
    @objc func changeTime() {
        showTime()
        Defaults[.shouldShowTime1] = !Defaults[.shouldShowTime1]
    }
    
    // update time
    @objc func updateTime() {
        timeFormatter?.dateFormat = Defaults[.showTime]
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
            UserDefaults.standard.set("h:mm", forKey: "timeFormat")
            
        case 1:
            UserDefaults.standard.set("HH:mm", forKey: "timeFormat")
            
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
        case 0:
            url = "https://blog.licardo.cn/posts/33030"
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
    static let time1 = Key<String>("time1", default: "h:mm")
    static let time2 = Key<String>("time2", default: "HH:mm")
    static let showTime = Key<String>("showTime", default: "h:mm")
    static let shouldShowTime1 = Key<Bool>("showTime1", default: true)
}
