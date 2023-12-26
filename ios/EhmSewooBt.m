#import "EhmSewooBt.h"

@implementation EhmSewooBt
RCT_EXPORT_MODULE()

-(void)initialize {
    zplPrinter = [[ZPLPrinter alloc] init];
}

- (NSDictionary *)constantsToExport
{
    
    /*
     EVENT_DEVICE_ALREADY_PAIRED    Emits the devices array already paired
     EVENT_DEVICE_DISCOVER_DONE    Emits when the scan done
     EVENT_DEVICE_FOUND    Emits when device found during scan
     EVENT_CONNECTION_LOST    Emits when device connection lost
     EVENT_UNABLE_CONNECT    Emits when error occurs while trying to connect device
     EVENT_CONNECTED    Emits when device connected
     */

    return @{ @"connecting": @"connecting",
              @"connected":@"connected",
              @"disconnecting":@"disconnecting",
              @"disconnected":@"disconnected",
              @"paperEmpty":@"paperEmpty",
              @"coverOpen":@"coverOpen",
              @"battery":@"battery"
              };
}

- (NSArray<NSString *> *)supportedEvents
{
    /*
     EVENT_DEVICE_ALREADY_PAIRED    Emits the devices array already paired
     EVENT_DEVICE_DISCOVER_DONE    Emits when the scan done
     EVENT_DEVICE_FOUND    Emits when device found during scan
     EVENT_CONNECTION_LOST    Emits when device connection lost
     EVENT_UNABLE_CONNECT    Emits when error occurs while trying to connect device
     EVENT_CONNECTED    Emits when device connected
     */

    return @[@"connecting",
             @"connected",
             @"disconnecting",
             @"disconnected",
             @"paperEmpty",
             @"coverOpen",
             @"battery"];
}

RCT_EXPORT_METHOD(DiscoverDevices:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(nil);
}

RCT_EXPORT_METHOD(StopDiscover:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(nil);
}

RCT_EXPORT_METHOD(ConnectDevice:(NSString*)deviceId
                  withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    [self sendEventWithName:@"connecting" body:nil];
    //long ret = [zplPrinter openPort:@"192.168.43.245", withPortParam:9100];
    long ret = [zplPrinter openPort:deviceId withPortParam:9100];
    if(ret >= 0)
    {
        [self sendEventWithName:@"connected" body:nil];
    }
    resolve((@TRUE));
}

RCT_EXPORT_METHOD(GetDevices:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(nil);
}

RCT_EXPORT_METHOD(Disconnect:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    [self sendEventWithName:@"disconnecting" body:nil];
    [zplPrinter closePort];
    [self sendEventWithName:@"disconnected" body:nil];
    resolve(@(TRUE));
}

RCT_EXPORT_METHOD(PrintZpl:(NSString*)zpl
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        if(zplPrinter == nil){
            [self sendEventWithName:@"disconnecting" body:nil];
            resolve(@(FALSE));
        }else {
            
            NSData *data = [zpl dataUsingEncoding:NSUTF8StringEncoding];
            const unsigned char *bytes = (const unsigned char *)[data bytes];
            NSUInteger length = [data length];
            [zplPrinter printData:bytes withLength:length];
            
            resolve(@(TRUE));
        }
    } @catch (NSException *exception)
    {
        [self sendEventWithName:@"disconnecting" body:nil];

        if(!zplPrinter)
        {
            [zplPrinter closePort];
        }
        
        [self sendEventWithName:@"disconnected" body:nil];
        resolve(@(FALSE));
    }
}

- (void) tcpStatusBox:(long) sts
{
    sts = [zplPrinter status];
    if(sts == STS_ZPL_NORMAL)
    {
        
    } else {
       if((sts & STS_ZPL_PAPER_EMPTY) > 0)
       {
           [self sendEventWithName:@"paperEmpty" body:nil];
       }
        if((sts & STS_ZPL_COVER_OPEN) > 0)
        {
            [self sendEventWithName:@"coverOpen" body:nil];
        }
        if((sts & STS_ZPL_BATTERY_LOW) > 0)
        {
            [self sendEventWithName:@"battery" body:nil];
        }
        [self sendEventWithName:@"disconnecting" body:nil];
        [zplPrinter closePort];
        [self sendEventWithName:@"disconnected" body:nil];
    }
}
- (void) statusCheckReceived:(NSNotification *) notification
{
    long bytesAvailable = 0;
    long readLength = 0;
    unsigned char buf[8] = {0,};
    EABluetoothPort * sessionController = (EABluetoothPort *)[notification object];
    NSString * result = [[NSString alloc] init];
#ifdef DEBUG
    NSLog(@"===== Status Check START =====");
#endif
    NSMutableData * readData = [[NSMutableData alloc] init];
    while((bytesAvailable = [sessionController readBytesAvailable]) > 0)
    {
        NSData * data = [sessionController readData:bytesAvailable];
        if(data)
        {
            [readData appendData:data];
            readLength = readLength + bytesAvailable;
        }
    }
    if(readLength > sizeof(buf))
        readLength = sizeof(buf);
    [readData getBytes:buf length:readLength];
    
    int sts = buf[readLength - 1];
    if(sts == STS_ZPL_NORMAL)
    {
       
    }
    else
    {
        if((sts & STS_ZPL_BUSY) > 0)
        {
            result = [result stringByAppendingString:@"Printer Busy\r\n"];
        }
        if((sts & STS_ZPL_COVER_OPEN) > 0)
        {
            result = [result stringByAppendingString:@"Cover Open\r\n"];
        }
        if((sts & STS_ZPL_PAPER_EMPTY) > 0)
        {
            result = [result stringByAppendingString:@"Paper Empty\r\n"];
        }
        if((sts & STS_ZPL_BATTERY_LOW) > 0)
        {
            result = [result stringByAppendingString:@"Battery Low\r\n"];
        }
    }
#ifdef DEBUG
    NSLog(@"===== Status Check EXIT =====");
#endif
}


@end
