#import <React/RCTBridgeModule.h>
#import "ZPLPrinter.h"
#import "CallbackData.h"
#import "EABluetoothPort.h"

@interface EhmSewooBt : NSObject <RCTBridgeModule>

    @property (nonatomic, strong) ZPLPrinter* zplPrinter;

@end
