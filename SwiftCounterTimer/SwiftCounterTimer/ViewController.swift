//
//  ViewController.swift
//  SwiftCounterTimer
//
//  Created by LiuScott on 15-4-17.
//  Copyright (c) 2015年 LiuScott. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate  {

    @IBOutlet weak var timeLeft: UILabel!
    
    @IBOutlet weak var workTimeSpanPicker: BinaryIntValuePicker!
    
    @IBOutlet weak var breakTimeSpanPicker: BinaryIntValuePicker!
    
    @IBAction func timerSwitch(sender: UIButton) {
        isRunning = !isRunning
    }
    var isRunning: Bool = false {
        willSet {
            if newValue {
                runningTimer()
            } else {
                pauseTimer()
            }
        }
    }

    enum TimerType {
        case WorkTimer
        case BreakTimer
    }

    var curTimerType : TimerType = .WorkTimer {
        willSet {
            switch newValue {
            case .WorkTimer :
                createAndFireLocalNotificationAfterSomeSeconds(NSTimeInterval(remainingWorkSeconds))
            case .BreakTimer:
                createAndFireLocalNotificationAfterSomeSeconds(NSTimeInterval(remainingBreakSeconds))
            }
        }
    }
    
    var remainingWorkSeconds : Int = 0 {
        willSet {
            formatIntVal(newValue)
        }
    }
    
    var remainingBreakSeconds : Int = 0 {
        willSet {
            formatIntVal(newValue)
        }
    }
    
    var workSpan : Int = 0
    var breakSpan : Int = 0
    
    var timerForWork  : NSTimer?
    var timerForBreak : NSTimer?
    
    var minuteCount = 60


    func runningTimer() {
        pickerView(breakTimeSpanPicker, didSelectRow: 0, inComponent: 0)
        pickerView(workTimeSpanPicker, didSelectRow: 0, inComponent: 0)
        
        if (curTimerType == .WorkTimer) {
            if 0 != workSpan {
                timerForWork = NSTimer.scheduledTimerWithTimeInterval(Double(1.0), target: self, selector: Selector("workTimeEnd:"), userInfo: nil, repeats: true)
                curTimerType = .WorkTimer
            }
        } else if (curTimerType == .BreakTimer) {
            if 0 != breakSpan {
                timerForBreak = NSTimer.scheduledTimerWithTimeInterval(Double(1.0), target: self, selector: Selector("breakTimeEnd"), userInfo: nil, repeats: true)
            
                curTimerType = .BreakTimer
            }
        }
    }
    
    func pauseTimer() {
        timerForBreak?.invalidate()
        timerForBreak = nil
        timerForWork?.invalidate()
        timerForWork = nil
        workSpan = 0
        breakSpan = 0
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    @IBAction func resetTimer(sender: UIButton) {
        disableTimer()
    }
    
    func workTimeEnd(sender : NSTimer) {
        remainingWorkSeconds -= 1
        if 0 == remainingWorkSeconds {
            timeLeft.backgroundColor = UIColor.greenColor()
            let alter = UIAlertView()
            alter.title = "Rest time!"
            alter.message = "Have a break please, walk away......"
            alter.addButtonWithTitle("Ok...")
            alter.show()
            if timerForBreak == nil {
                timerForWork?.invalidate()
                timerForWork = nil
                timerForBreak = NSTimer.scheduledTimerWithTimeInterval(Double(1.0), target: self, selector: Selector("breakTimeEnd"), userInfo: nil, repeats: true)
                
                curTimerType = .BreakTimer
            }
            
            remainingWorkSeconds = workSpan
        }
    }
    
    func breakTimeEnd() {
        remainingBreakSeconds -= 1
        if 0 == remainingBreakSeconds {
            timeLeft.backgroundColor = UIColor.blueColor()
            let alter = UIAlertView()
            alter.title = "Work time!"
            alter.message = "Have a rush hour, go go go ......"
            alter.addButtonWithTitle("Run ...")
            alter.show()
            if timerForWork == nil {
                timerForBreak?.invalidate()
                timerForBreak = nil
                timerForWork = NSTimer.scheduledTimerWithTimeInterval(Double(1.0), target: self, selector: Selector("workTimeEnd:"), userInfo: nil, repeats: true)
                
                curTimerType = .WorkTimer
            }
            
            remainingBreakSeconds = breakSpan
        }
    }
    

    func formatIntVal(totalTime: Int) {
        let minuteVal = Int(totalTime / 60)
        let secondVal = Int(totalTime % 60)
        timeLeft.text = NSString(format: "%02d:%02d", minuteVal, secondVal)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        for i in 0 ..< 2 {
            workTimeSpanPicker.selectRow(2, inComponent: i, animated: true)
        }

        workTimeSpanPicker.delegate = self
        breakTimeSpanPicker.delegate = self
        workTimeSpanPicker.dataSource = self
        breakTimeSpanPicker.dataSource = self
        
        pickerView(workTimeSpanPicker, didSelectRow: 0, inComponent: 0)
        pickerView(breakTimeSpanPicker, didSelectRow: 0, inComponent: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func clearWorkTime() {
        remainingWorkSeconds = 0
    }
    
    func clearBreakTime() {
        remainingBreakSeconds = 0
    }
    
    func disableTimer() {
        clearWorkTime()
        clearBreakTime()
        workSpan = 0
        breakSpan = 0
        
        isRunning = false
        curTimerType = .WorkTimer
        
        pauseTimer()
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    

    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 12
        case 1:
            return 60
        default:
            break
        }
        return 12
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        var retString : String = String()
        var num = row + 1
        switch component {
        case 0 :
            return "\(row) h"
        case 1 :
            return "\(num) m"
        case 2 :
            return "\(num) s"
        default:
            break
        }
        return retString
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var hour = pickerView.selectedRowInComponent(0)
        var minute = (pickerView.selectedRowInComponent(1) + 1)
        if pickerView == workTimeSpanPicker {
            workSpan = hour * 3600 + minute * minuteCount
            remainingWorkSeconds = workSpan
        } else if pickerView == breakTimeSpanPicker {
            breakSpan = hour * 3600 + minute * minuteCount
            remainingBreakSeconds = breakSpan
        }
    }
    
    func createAndFireLocalNotificationAfterSomeSeconds(seconds: NSTimeInterval) {
        println("notification setting called")
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: seconds)
        notification.timeZone = NSTimeZone.systemTimeZone();
        notification.alertBody = (curTimerType == .WorkTimer) ? "Work timer over, have a rest..." : "Rest timer over, work hard..."
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
}

