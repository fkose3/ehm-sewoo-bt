#import "EhmSewooBt.h"
#import "ZPLPrinter.h"
#import "CallbackData.h"
#import "EABluetoothPort.h"

@implementation EhmSewooBt
{
    ZPLPrinter *zplPrinter;
}

RCT_EXPORT_MODULE()


int iInterface = 0;

RCT_EXPORT_METHOD(connect:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    
    @try
    {
        long ret;
        
        ret = [zplPrinter openPort:@"bluetooth", withPortParam:0];

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

RCT_EXPORT_METHOD(disconnect:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [zplPrinter closePort];
	
    resolve(@(YES));
}

RCT_EXPORT_METHOD(print:(NSString*) txt
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    [zplPrinter startPage];
    [zplPrinter setInternationalFont:0];
    
    [zplPrinter printString:txt];

}

RCT_REMAP_METHOD(multiply,
                 multiplyWithA:(double)a withB:(double)b
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    NSNumber *result = @(a * b);

    resolve(result);
}
