//
//  ViewController.swift
//  ZPL-BT-Swift
//
//  Created by OHSANG OK on 1/6/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var buttonStatus: UIButton!
    @IBOutlet weak var buttonPDFFile: UIButton!
    @IBOutlet weak var buttonBitmap: UIButton!
    @IBOutlet weak var button2DBarcode: UIButton!
    @IBOutlet weak var button1DBarcode: UIButton!
    @IBOutlet weak var buttonGeometry: UIButton!
    @IBOutlet weak var buttonText: UIButton!
    @IBOutlet weak var segmentedMedia: UISegmentedControl!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var buttonOpen: UIButton!
    @IBOutlet weak var inputAddress: UITextField!
    
    let zplPrinter = ZPLPrinter()
    
    var media_type:String = ZPL_SENSE_GAP
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        segmentedMedia.addTarget(self, action: #selector(ViewController.changedMediaType(sender:)), for: .allEvents)
        
        inputAddress.text = "bluetooth"
        setButtonUIStatus(isOpen: false)    //not Port open
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusCheckReceived(_:)), name: NSNotification.Name.EADSessionDataReceived, object: nil)
        
        EAAccessoryManager.shared().registerForLocalNotifications()
    }
    
    func alertMessageBox(title:String, message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setButtonUIStatus(isOpen: Bool)
    {
        buttonOpen.isEnabled = !isOpen
        inputAddress.isEnabled = !isOpen
        buttonClose.isEnabled = isOpen
        buttonText.isEnabled = isOpen
        buttonGeometry.isEnabled = isOpen
        button1DBarcode.isEnabled = isOpen
        button2DBarcode.isEnabled = isOpen
        buttonBitmap.isEnabled = isOpen
        buttonPDFFile.isEnabled = isOpen
        buttonStatus.isEnabled = isOpen
        segmentedMedia.isEnabled = isOpen
    }
    
    var stsData = Data()
    
    @objc func statusCheckReceived(_ notification:Notification)
    {
        let sessionController:EABluetoothPort = notification.object as! EABluetoothPort
        var bytesAvailable:CLong = 0
        
        while(true)
        {
            bytesAvailable = sessionController.readBytesAvailable()
            
            if(bytesAvailable > 0)
            {
                let data:Data = sessionController.readData(UInt(bytesAvailable))
                stsData.append(data)
            }
            else
            {
                break;
            }
        }
        
        if stsData.count > 0 && stsData.isEmpty == false {
            if(stsData[0] == STS_ZPL_NORMAL)
            {
                alertMessageBox(title: "Printer Status", message: "Normal")
            }
            else {
                var result:String = ""
                var ists:Int = 0
                
                if((stsData[0] & UInt8(STS_ZPL_BUSY)) > 0)
                {
                    result += "Printer Busy\r\n"
                    ists = 1;
                }
                
                if((stsData[0] & UInt8(STS_ZPL_COVER_OPEN)) > 0)
                {
                    result += "Cover Open\r\n";
                    ists = 1;
                }
                
                if((stsData[0] & UInt8(STS_ZPL_PAPER_EMPTY)) > 0)
                {
                    result += "Paper empty\r\n";
                    ists = 1;
                }
                
                if((stsData[0] & UInt8(STS_ZPL_BATTERY_LOW)) > 0)
                {
                    result += "Battery Low\r\n"
                }
                
                
                if( ists == 1)
                {
                    alertMessageBox(title: "Printer Status", message: result)
                }
            }
            stsData.removeAll()
        }
    }

    @IBAction func openPort(_ sender: Any) {
        let address: String = inputAddress.text ?? "bluetooth"
        var errCode: Int = 0
        
        errCode = zplPrinter.openPort(address, withPortParam: 9100)
        
        if(errCode >= 0)
        {
            setButtonUIStatus(isOpen: true)
        }
        else if(errCode == -3)
        {
            alertMessageBox(title: "Connection", message: "Connection failed")
        }
        else
        {
            alertMessageBox(title: "Connection", message: "Connection failed")
        }
    }
    
    @IBAction func closePort(_ sender: Any) {
        zplPrinter.closePort()
        setButtonUIStatus(isOpen: false)
    }
    
    @IBAction func printText(_ sender: Any) {
        zplPrinter.setupPrinter(ZPL_ROTATION_180, withmTrack:media_type, withWidth:384, withHeight:480)
        zplPrinter.setSpeed(5)
        zplPrinter.startPage()
        zplPrinter.setInternationalFont(0)

        
        zplPrinter.printText(ZPL_FONT_A, withOrientation:ZPL_ROTATION_0, withWidth:15, withHeight:12, withPrintX:0, withPrintY:0, withData:"FontA 0123")
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:15, withHeight:12, withPrintX:0, withPrintY:30, withData:"FontB 0123")
        zplPrinter.printText(ZPL_FONT_C, withOrientation:ZPL_ROTATION_0, withWidth:15, withHeight:12, withPrintX:0, withPrintY:60, withData:"FontC 0123")
        zplPrinter.printText(ZPL_FONT_D, withOrientation:ZPL_ROTATION_0, withWidth:15, withHeight:12, withPrintX:0, withPrintY:90, withData:"FontD 0123")
        zplPrinter.printText(ZPL_FONT_E, withOrientation:ZPL_ROTATION_0, withWidth:15, withHeight:12, withPrintX:0, withPrintY:120, withData:"FontE 0123")
        zplPrinter.printText(ZPL_FONT_F, withOrientation:ZPL_ROTATION_0, withWidth:15, withHeight:12, withPrintX:0, withPrintY:160, withData:"FontF 0123")
        zplPrinter.printText(ZPL_FONT_G, withOrientation:ZPL_ROTATION_0, withWidth:15, withHeight:12, withPrintX:0, withPrintY:210, withData:"FontG 01")
        zplPrinter.printText(ZPL_FONT_H, withOrientation:ZPL_ROTATION_0, withWidth:15, withHeight:12, withPrintX:0, withPrintY:300, withData:"FontH 01234567")

        zplPrinter.endPage(1)
    }
    
    @IBAction func printGeometry(_ sender: Any) {
        zplPrinter.setupPrinter(ZPL_ROTATION_180, withmTrack:media_type, withWidth:384, withHeight:300)
        zplPrinter.startPage()
        zplPrinter.setInternationalFont(0)

        zplPrinter.printCircle(40, withPrintY:40, withDiameter:70, withThickness:0, withLineColor:ZPL_LINE_COLOR_B)
        zplPrinter.printDiagonalLine(30, withPrintY:30, withWidth:100, withHeight:100, withThickness:7, withLineColor:ZPL_LINE_COLOR_B, withDirection:ZPL_DIAGONAL_L)
        zplPrinter.printEllipse(10, withPrintY:10, withWidth:300, withHeight:200, withThickness:2, withLineColor:ZPL_LINE_COLOR_B)
        zplPrinter.printRectangle(120, withPrintY:10, withWidth:120, withHeight:80, withThickness:10, withLineColor:ZPL_LINE_COLOR_B, withRounding:0)
        zplPrinter.printRectangle(120, withPrintY:100, withWidth:120, withHeight:80, withThickness:10, withLineColor:ZPL_LINE_COLOR_B, withRounding:8)

        zplPrinter.endPage(1)
    }
    
    @IBAction func print1DBarcode(_ sender: Any) {
        let barData:String = "123456789012"
        
        zplPrinter.setupPrinter(ZPL_ROTATION_180, withmTrack:media_type, withWidth:384, withHeight:1600)
        zplPrinter.startPage()
        zplPrinter.setInternationalFont(0)

        zplPrinter.setBarcodeField(2, withRatio:"3", withBarHeight:20)

        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:70, withData:"Code11")
        zplPrinter.printBarcode(ZPL_BCS_Code11, withBarcodeProp:"", withPrintX:10, withPrintY:10, withData:barData)
            
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:150, withData:"Code128")
        zplPrinter.printBarcode(ZPL_BCS_Code128, withBarcodeProp:"", withPrintX:10, withPrintY:100, withData:barData)
            
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:250, withData:"Code39")
        zplPrinter.printBarcode(ZPL_BCS_Code39, withBarcodeProp:"", withPrintX:10, withPrintY:200, withData:barData)
            
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:350, withData:"Code93")
        zplPrinter.printBarcode(ZPL_BCS_Code93, withBarcodeProp:"", withPrintX:10, withPrintY:300, withData:barData)
            
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:450, withData:"EAN13")
        zplPrinter.printBarcode(ZPL_BCS_EAN13, withBarcodeProp:"", withPrintX:10, withPrintY:400, withData:barData)
            
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:550, withData:"EAN8")
        zplPrinter.printBarcode(ZPL_BCS_EAN8, withBarcodeProp:"", withPrintX:10, withPrintY:500, withData:"12345")
            
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:650, withData:"Industrial 2OF5")
        zplPrinter.printBarcode(ZPL_BCS_Industrial_2OF5, withBarcodeProp:"", withPrintX:10, withPrintY:600, withData:barData)
            
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:750, withData:"Interleaved 2OF5")
        zplPrinter.printBarcode(ZPL_BCS_Interleaved_2OF5, withBarcodeProp:"", withPrintX:10, withPrintY:700, withData:barData)
            
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:850, withData:"LOGMARS")
        zplPrinter.printBarcode(ZPL_BCS_LOGMARS, withBarcodeProp:"", withPrintX:10, withPrintY:800, withData:barData)
            
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:950, withData:"MSI")
        zplPrinter.printBarcode(ZPL_BCS_MSI, withBarcodeProp:"", withPrintX:10, withPrintY:900, withData:barData)
                    
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:1050, withData:"PlanetCode")
        zplPrinter.printBarcode(ZPL_BCS_PlanetCode, withBarcodeProp:"", withPrintX:10, withPrintY:1000, withData:barData)
            
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:1150, withData:"Plessey")
        zplPrinter.printBarcode(ZPL_BCS_Plessey, withBarcodeProp:"", withPrintX:10, withPrintY:1100, withData:barData)
            
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:1250, withData:"POSTNET")
        zplPrinter.printBarcode(ZPL_BCS_POSTNET, withBarcodeProp:"", withPrintX:10, withPrintY:1200, withData:barData)
            
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:1350, withData:"Standard 2OF5")
        zplPrinter.printBarcode(ZPL_BCS_Standard_2OF5, withBarcodeProp:"", withPrintX:10, withPrintY:1300, withData:barData)
                    
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:1450, withData:"UPCA")
        zplPrinter.printBarcode(ZPL_BCS_UPCA, withBarcodeProp:"", withPrintX:10, withPrintY:1400, withData:barData)
            
        zplPrinter.printText(ZPL_FONT_B, withOrientation:ZPL_ROTATION_0, withWidth:10, withHeight:10, withPrintX:0, withPrintY:1550, withData:"UPCE")
        zplPrinter.printBarcode(ZPL_BCS_UPCE, withBarcodeProp:"", withPrintX:10, withPrintY:1500, withData:barData)

        zplPrinter.endPage(1)
    }
    
    @IBAction func print2DBarcode(_ sender: Any) {
        zplPrinter.setupPrinter(ZPL_ROTATION_180, withmTrack:media_type, withWidth:384, withHeight:400)
        zplPrinter.startPage()
        zplPrinter.setInternationalFont(0)

        zplPrinter.printQRCODE(10, withPrintY:220, withOrientation:ZPL_ROTATION_0, withModel:2, withCellWidth:5, withData:"MM,AAC-42")
        zplPrinter.printPDF417(10, withPrintY:10, withOrientation:ZPL_ROTATION_0, withCellWidth:5, withSecurity:5, withNumOfRow:23, withTruncate:"N", withData:"PDF417-ABDFFEWGSERSHSRGRR")
        zplPrinter.printDataMatrix(200, withPrintY:220, withOrientation:ZPL_ROTATION_0, withCellWidth:10, withQuality:ZPL_DM_QUALITY_200, withData:"ABDFFEWGSERSHSRGRR")

        zplPrinter.endPage(1)
    }
    
    @IBAction func printBitmap(_ sender: Any) {
        let imgfile2:String = Bundle.main.path(forResource: "sample_2", ofType: "jpg") ?? ""
        let imgfile3:String = Bundle.main.path(forResource: "sample_3", ofType: "jpg") ?? ""
        let imgfile4:String = Bundle.main.path(forResource: "sample_4", ofType: "jpg") ?? ""
        
        zplPrinter.setupPrinter(ZPL_ROTATION_180, withmTrack:media_type, withWidth:384, withHeight:340)
        zplPrinter.startPage()
        zplPrinter.setInternationalFont(0)
        
        zplPrinter.printImage(imgfile2, withPrintX:1, withPrintY:200, withBrightness:5)
        zplPrinter.printImage(imgfile3, withPrintX:100, withPrintY:10, withBrightness:5)
        zplPrinter.printImage(imgfile4, withPrintX:120, withPrintY:245, withBrightness:5)

        zplPrinter.endPage(1)
    }
    
    @IBAction func printPDFFile(_ sender: Any) {
        let path:String = Bundle.main.path(forResource: "PDF_Sample-2mm", ofType: "pdf") ?? ""
        
        zplPrinter.setupPrinter(ZPL_ROTATION_180, withmTrack:media_type, withWidth:384, withHeight:340)
        zplPrinter.startPage()
        zplPrinter.setInternationalFont(0)
        
        //zplPrinter.printPdfFile(path, withPage:0, withPrintWidth:384) // 2-inch print all pages
        //zplPrinter.printPdfFile(path, withPage:0, withPrintWidth:576) // 3-inch print all pages
        //zplPrinter.printPdfFile(path, withPage:0, withPrintWidth:832) // 4-inch print all pages
        zplPrinter.printPdfFile(path, withPage:1, withPrintWidth:384) // 3-inch print page 1

        //zplPrinter.printPdfFilePartial(path, withStartPage:2 withEndPage:3 withPrintWidth:576]; // 3-inch print partial pages(2~3)
        
        zplPrinter.endPage(1)
    }
    
    @IBAction func getStatus(_ sender: Any) {
        zplPrinter.printerCheck()
    }
    
    @objc func changedMediaType(sender: UISegmentedControl)
    {
        if(sender.selectedSegmentIndex == 0)
        {
            media_type = ZPL_SENSE_GAP;
        }
        else if(sender.selectedSegmentIndex == 1)
        {
            media_type = ZPL_SENSE_BLACKMARK;
        }
        else if(sender.selectedSegmentIndex == 2)
        {
            media_type = ZPL_SENSE_CONTINUOUS;
        }
    }
}

