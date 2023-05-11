#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import "ZPLPrinter.h"
#import "CallbackData.h"
#import "EABluetoothPort.h"

@interface EhmSewooBt : RCTEventEmitter <RCTBridgeModule>
{
    ZPLPrinter* zplPrinter;
}

@end
