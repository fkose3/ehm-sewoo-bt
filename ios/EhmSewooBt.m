#import "EhmSewooBt.h"

@implementation EhmSewooBt
RCT_EXPORT_MODULE()

-(void)initialize {
    zplPrinter = [[ZPLPrinter alloc] init];
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
    long ret = [zplPrinter openPort:@"bluetooth" withPortParam:0];
    
    if(ret >= 0)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusCheckReceived:) name:EADSessionDataReceivedNotification object:nil];
        [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
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
    [zplPrinter closePort];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EADSessionDataReceivedNotification object:nil];
    resolve(@(TRUE));
}

RCT_EXPORT_METHOD(PrintZpl:(NSString*)zpl
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    [zplPrinter printString:zpl];
    [zplPrinter printerCheck];
    resolve(@(TRUE));
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

- (void)dealloc
{
    [zplPrinter release];
    [super dealloc];
}

@end
