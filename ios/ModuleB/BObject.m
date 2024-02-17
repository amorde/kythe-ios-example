@import ModuleA;
#import <ModuleB/BObject.h>

@interface BObject ()

@property (nonatomic, nonnull) AObject *object;

@end

@implementation BObject

- (nonnull instancetype)initWithObject:(nonnull AObject *)object {
    self = [super init];
    if (self) {
        _object = object;
    }
    return self;
}

- (void)doBThing {
    [self.object foo];
}

@end
