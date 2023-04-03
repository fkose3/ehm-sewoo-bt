import React
import Foundation
import ExternalAccessory

@objc(EhmSewooBt)
class EhmSewooBt: NSObject, RCTBridgeModule {
    static func moduleName() -> String! {
        return "EhmSewooBt"
    }
    
    var stsData = Data()
    let zplPrinter = ZPLPrinter()
    var media_type:String = ZPL_SENSE_GAP
    static let shared = EhmSewooBt()

    override init() {
        super.init()
        
        let accessoryManager = EAAccessoryManager.shared()
        accessoryManager.registerForLocalNotifications() // bildirimleri almak için kaydol
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusCheckReceived(_:)), name: NSNotification.Name.EADSessionDataReceived, object: nil)
           
    }
    
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
                //alertMessageBox(title: "Printer Status", message: "Normal")
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
                    //alertMessageBox(title: "Printer Status", message: result)
                }
            }
            stsData.removeAll()
        }
    }
    
    @objc(DiscoverDevices:withRejecter:)
    func DiscoverDevices(resolve:RCTPromiseResolveBlock, reject: RCTPromiseResolveBlock) -> Void {
        resolve(true)
    }
    
    @objc(StopDiscover:withRejecter:)
    func StopDiscover(resolve:RCTPromiseResolveBlock, reject: RCTPromiseResolveBlock) -> Void {
        resolve(true)
    }
    
    @objc(ConnectDevice:withRejecter:)
    func ConnectDevice(resolve:RCTPromiseResolveBlock, reject: RCTPromiseResolveBlock) -> Void {
        var errCode: Int = 0
        errCode = zplPrinter.openPort("bluetooth", withPortParam: 0)
        
        if(errCode >= 0)
        {
            resolve(true)
        }
        else
        {
            resolve(false)
        }
    }
    
    @objc(GetDevices:withRejecter:)
    func GetDevices(resolve:RCTPromiseResolveBlock, reject: RCTPromiseResolveBlock) -> Void {
        resolve(true)
    }
    
    @objc(Disconnect:withRejecter:)
    func Disconnect(resolve:RCTPromiseResolveBlock, reject: RCTPromiseResolveBlock) -> Void {
        resolve(true)
    }
    
    @objc(PrintZpl:withResolver:withRejecter:)
    func PrintZpl(zpl: String, resolve:RCTPromiseResolveBlock, reject: RCTPromiseResolveBlock) -> Void {
        zplPrinter.setupPrinter(ZPL_ROTATION_180, withmTrack:media_type, withWidth:384, withHeight:480)
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
    
}
