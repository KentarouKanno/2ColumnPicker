//
//  CustomTextField.swift
//  MultiTextField
//
//  Created by KentarOu on 2015/09/08.
//  Copyright (c) 2015年 KentarOu. All rights reserved.
//

import Foundation
import UIKit


enum InputType {
    case None
    case TextField
    case PickerView
    case DatePicker
    case TwoColumnPicker
}

protocol CustomTextFieldDelegate {
    
    func selectValue(textValue:NSString, itemValue:AnyObject, inputType:InputType)
}

class CustomTextField: UITextField, KeyboardToolBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Delegate
    var parent: CustomTextFieldDelegate!
    
    var twoColumnYearData: [String] = []
    var twoColumnMonthData: [String] = []
    
    // DatePicker
    var datePicker: UIDatePicker!
    var pickerDate: NSDate {
        get {
            return itemValue as! NSDate
        }
        set(newValue) {
            itemValue = newValue
        }
    }
    
    // PikerView
    var pickerView: UIPickerView!
    var pickerDataArray: NSMutableArray = NSMutableArray()
    var isClearPicker: Bool = false
    
    var inputType: InputType = .TextField
    var toolBar: KeyboardToolBar = KeyboardToolBar()
    
    var textValue: NSString = ""
    var itemValue: AnyObject?
    
    var tmpTextValue: NSString = ""
    var tmpItemValue: AnyObject?
    
    var isPushDoneButton: Bool = false
    
    
    
    // MARK:- initialize
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    
        self.initSettings()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initSettings()
    }
    
    func initSettings() {
        self.textColor = UIColor(white: 0.146, alpha: 1.0)
        self.borderStyle = .RoundedRect
        toolBar.parentTextField = self
        
        
        for month in 1...12 {
            twoColumnMonthData.append(String(month))
        }
        
        for year in 1974...2015 {
            twoColumnYearData.append(String(year))
        }
    
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
    
        
        if inputType == .TextField {
            if "copy:" == action || "paste:" == action || "select:" == action || "selectall:" == action {
                return  true;
            }
        }
        return false
    }
    
    // MARK:- TextField OverRide
    
    // inputView
    override var inputView: UIView? {
        get {
            
            
            let baseView: UIView = UIView()
            baseView.backgroundColor = UIColor.whiteColor()
            
            switch inputType {
            case .TextField :
                
                tmpTextValue = self.text!
                tmpItemValue = self.text!
                
                return super.inputView
            case .PickerView :
                self.valueForKeyPath("textInputTraits")?.setValue(UIColor.clearColor(), forKey: "insertionPointColor")
                
                pickerView = UIPickerView()
                pickerView.delegate = self
                pickerView.dataSource = self
                pickerView.showsSelectionIndicator = true
                
                if let value: AnyObject = itemValue {
                    pickerView.selectRow(value.integerValue, inComponent: 0, animated: true)
                    tmpItemValue = itemValue
                } else {
                    itemValue = "0"
                    tmpItemValue = "0"
                }
                
                pickerView.delegate?.pickerView!(pickerView, didSelectRow: itemValue!.integerValue, inComponent: 0)
                tmpTextValue = textValue
                
                baseView.frame = pickerView.frame;
                baseView.addSubview(pickerView)
                
                return baseView
            case .DatePicker :
                
                self.valueForKeyPath("textInputTraits")?.setValue(UIColor.clearColor(), forKey: "insertionPointColor")
                
                datePicker = UIDatePicker()
                datePicker.addTarget(self, action: "changedDateEvent:", forControlEvents: UIControlEvents.ValueChanged)
                datePicker.datePickerMode = UIDatePickerMode.Date
                
                if let itemval: AnyObject = itemValue {
                    tmpItemValue = itemValue
                    datePicker.date = itemval as! NSDate
                } else {
                    tmpItemValue = nil
                }
                
                self.changedDateEvent(datePicker)
                tmpTextValue = textValue
                
                baseView.frame = datePicker.frame;
                baseView.addSubview(datePicker)
                return baseView
                
            case .TwoColumnPicker :
                
                self.valueForKeyPath("textInputTraits")?.setValue(UIColor.clearColor(), forKey: "insertionPointColor")
                
                pickerView = UIPickerView()
                pickerView.delegate = self
                pickerView.dataSource = self
                pickerView.showsSelectionIndicator = true
                
                if let value: AnyObject = itemValue {
                    pickerView.selectRow(value.integerValue, inComponent: 0, animated: true)
                    tmpItemValue = itemValue
                } else {
                    itemValue = "0"
                    tmpItemValue = "0"
                }
                
                //pickerView.delegate?.pickerView!(pickerView, didSelectRow: itemValue!.integerValue, inComponent: 0)
                //tmpTextValue = textValue
                
                baseView.frame = pickerView.frame;
                baseView.addSubview(pickerView)
                
                return baseView
                
            default:
                return super.inputView
            }
        }
        
        set(newInset) {
            
            super.inputView = newInset
        }
    }
    
    // inputAccessoryView
    override var inputAccessoryView: UIView? {
        get {
            let keyboardBar:KeyboardToolBar = toolBar.initWithKeyboardToolBar()
            keyboardBar.parentTextField = self
            if inputType == .TextField {
                keyboardBar.hideCancelButton()
            }
            
            return keyboardBar
        }
        set(newValue) {
            self.inputAccessoryView = newValue
        }
    }
    
    // MARK:- DatePicker Event 
    
    func changedDateEvent(datePicker: UIDatePicker) {
        
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        let dateString: NSString = dateFormatter.stringFromDate(datePicker.date)
        
        textValue = dateString
        itemValue = datePicker.date
    }
    
    // MARK:- PickerView Delegate,DataSource
    
    // PickerView Columns Count
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return inputType == .PickerView ? 1 : 2
    }
    
    // PickerView Rows Count
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if inputType == .PickerView {
            return pickerDataArray.count
        } else {
            return component == 0 ? twoColumnYearData.count : twoColumnMonthData.count
        }
    }
    
    // PickerView Display Value
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if inputType == .PickerView {
            return pickerDataArray[row] as? String
        } else {
            return component == 0 ? twoColumnYearData[row] + "年" : twoColumnMonthData[row] + "月"
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        pickerLabel.font = UIFont.systemFontOfSize(14)
        pickerLabel.textAlignment = NSTextAlignment.Center
        
        if inputType == .PickerView {
            pickerLabel.text = pickerDataArray[row] as? String
            pickerLabel.frame = CGRectMake(0, 0, 320, 30)
        } else {
            pickerLabel.text = component == 0 ? twoColumnYearData[row] + "年" : twoColumnMonthData[row] + "月"
            pickerLabel.frame = component == 0 ? CGRectMake(0, 0, pickerView.frame.size.width / 2, 30) : CGRectMake(frame.size.width / 2, 0, frame.size.width / 2, 30)
        }
        
        return pickerLabel
    }
    
    // Select PickerView
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if inputType == .TwoColumnPicker {
            
            let num = twoColumnMonthData[pickerView.selectedRowInComponent(1)]
            let value = NSString(format: "%02d", Int(num)!)
            textValue = (twoColumnYearData[pickerView.selectedRowInComponent(0)] + (value as String)) as NSString
            return
        }
        
        if isClearPicker && row == 0 {
            textValue = ""
        } else {
            textValue = pickerDataArray[pickerView.selectedRowInComponent(0)] as! NSString
        }
        
        itemValue = "\(row)"
    }
    
    // MARK:- KeyboardToolBarDelegate
    
    func selectValue(pushDoneButton: Bool) {
        
        if pushDoneButton {
            isPushDoneButton = true
        }
        
        switch inputType {
        case .TextField :
            
            if pushDoneButton == false && isPushDoneButton == false {
                textValue = tmpTextValue
                itemValue = tmpItemValue
                
            } else {
                textValue = self.text!
                itemValue = self.text!
                
                if pushDoneButton == false && isPushDoneButton == true {
                    isPushDoneButton = false
                }
            }
            
        case .PickerView,.DatePicker :
            
            if pushDoneButton == false && isPushDoneButton == false {
                textValue = tmpTextValue
                itemValue = tmpItemValue
                
            } else {
                self.text = textValue as String
                
                if pushDoneButton == false && isPushDoneButton == true {
                    isPushDoneButton = false
                }
            }
        case .TwoColumnPicker :
//            let str = twoColumnYearData[pickerView.selectedRowInComponent(0)] + twoColumnMonthData[pickerView.selectedRowInComponent(1)]
            self.text = textValue as String
            //textValue = textValue
            itemValue = textValue
            
        default:
            print("None")
        }
        
        if let parent = self.parent {
            parent .selectValue(textValue, itemValue: itemValue!, inputType: inputType)
        }
    }
}
