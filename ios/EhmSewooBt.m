#import "EhmSewooBt.h"

@implementation EhmSewooBt
RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(DiscoverDevices,
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(nil);
}

RCT_REMAP_METHOD(StopDiscover,
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(nil);
}

RCT_REMAP_METHOD(ConnectDevice,
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(nil);
}

RCT_REMAP_METHOD(GetDevices,
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(nil);
}

RCT_REMAP_METHOD(Disconnect,
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(nil);
}

RCT_REMAP_METHOD(PrintZpl,
                 withZpl:(NString*)zpl
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(nil);
}

@end
