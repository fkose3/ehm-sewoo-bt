#import "EhmSewooBt.h"
#import "ZPLPrinter.h"
#import "CallbackData.h"
#import "EABluetoothPort.h"

@implementation EhmSewooBt
{
    ZPLPrinter *zplPrinter;
}

RCT_EXPORT_MODULE();



RCT_REMAP_METHOD(connect,
                  withResolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    
    @try
    {
        long ret;
        zplPrinter = [[ZPLPrinter alloc] init];
        ret = [zplPrinter openPort:@"bluetooth" withPortParam:0];
        
        if(ret >= 0)
        {
            resolve(@(YES));
        }
        else
        {
            resolve(@(NO));
        }
    }
    @catch (NSException *exception)
    {
        resolve(@(NO));
    }
    
    
}

RCT_REMAP_METHOD(disconnect,
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)
{
    [zplPrinter closePort];
    
    resolve(@(YES));
}

RCT_REMAP_METHOD(print,
                  withPrintString:(NSString*) txt
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)
{
    [zplPrinter startPage];
    [zplPrinter setInternationalFont:0];
    
    [zplPrinter printString:txt];
    
}

@end
