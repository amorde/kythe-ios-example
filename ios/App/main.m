@import ModuleA;
@import ModuleB;

int main(int argc, char **argv) {
    AObject *a = [[AObject alloc] init];
    BObject *b = [[BObject alloc] initWithObject:a];
    [b doBThing];
    return UIApplicationMain(argc, argv, nil, nil);
}
