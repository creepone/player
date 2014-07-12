#import "PLServiceContainer.h"
#import "PLPathAssetSet.h"

@interface PLServiceContainer() {
    NSMutableDictionary *_singleInstances;
    NSMutableDictionary *_singleCreators;
    NSMutableDictionary *_multiInstances;
    NSMutableDictionary *_multiCreators;
}

@end

@implementation PLServiceContainer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _singleInstances = [NSMutableDictionary dictionary];
        _singleCreators = [NSMutableDictionary dictionary];
        _multiInstances = [NSMutableDictionary dictionary];
        _multiCreators = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (PLServiceContainer *)sharedContainer
{
    static dispatch_once_t once;
    static PLServiceContainer *sharedContainer;
    dispatch_once(&once, ^ { sharedContainer = [[self alloc] init]; });
    return sharedContainer;
}


- (void)registerInstance:(id)service underProtocol:(Protocol *)protocol
{
    [self registerInstance:service underName:NSStringFromProtocol(protocol)];
}

- (void)registerInstance:(id)service underName:(NSString *)name
{
    if (_singleInstances[name])
        DDLogWarn(@"Replacing the instance %@ with a new instance in the container.", name);

    if (_singleCreators[name]) {
        DDLogWarn(@"Replacing the creator %@ with a new instance in the container.", name);
        [_singleCreators removeObjectForKey:name];
    }
    
    if (_multiInstances[name] || _multiCreators[name]) {
        NSString *reason = [NSString stringWithFormat:@"The given key %@ was already registered as a multi-service in the container.", name];
        @throw [NSException exceptionWithName:@"PLServiceContainerInconsistency" reason:reason userInfo:nil];
    }

    _singleInstances[name] = service;
}

- (void)addInstance:(id)service underProtocol:(Protocol *)protocol
{
    [self addInstance:service underName:NSStringFromProtocol(protocol)];
}

- (void)addInstance:(id)service underName:(NSString *)name
{
    NSMutableArray *instances = _multiInstances[name] ? : [NSMutableArray array];
    
    if (_singleInstances[name]) {
        DDLogWarn(@"The given key %@ was already registered as a single instance in the container.", name);
        [instances addObject:_singleInstances[name]];
        [_singleInstances removeObjectForKey:name];
    }
    
    if (_singleCreators[name]) {
        DDLogWarn(@"The given key %@ was already registered as a single creator in the container.", name);
        NSMutableArray *creators = _multiCreators[name] ? : [NSMutableArray array];
        [creators addObject:_singleCreators[name]];
        [_singleCreators removeObjectForKey:name];
        _multiCreators[name] = creators;
    }
    
    [instances addObject:service];
    _multiInstances[name] = instances;
}

- (void)registerCreator:(PLServiceCreatorBlock)creator underProtocol:(Protocol *)protocol
{
    [self registerCreator:creator underName:NSStringFromProtocol(protocol)];
}

- (void)registerCreator:(PLServiceCreatorBlock)creator underName:(NSString *)name
{
    if (_singleInstances[name]) {
        DDLogWarn(@"Replacing the instance %@ with a new creator in the container.", name);
        [_singleInstances removeObjectForKey:name];
    }
    
    if (_singleCreators[name])
        DDLogWarn(@"Replacing the creator %@ with a new instance in the container.", name);
    
    if (_multiInstances[name] || _multiCreators[name]) {
        NSString *reason = [NSString stringWithFormat:@"The given key %@ was already registered as a multi-service in the container.", name];
        @throw [NSException exceptionWithName:@"PLServiceContainerInconsistency" reason:reason userInfo:nil];
    }
    
    _singleCreators[name] = creator;
}

- (void)addCreator:(PLServiceCreatorBlock)creator underProtocol:(Protocol *)protocol
{
    [self addCreator:creator underName:NSStringFromProtocol(protocol)];
}

- (void)addCreator:(PLServiceCreatorBlock)creator underName:(NSString *)name
{
    NSMutableArray *creators = _multiCreators[name] ? : [NSMutableArray array];
    
    if (_singleInstances[name]) {
        DDLogWarn(@"The given key %@ was already registered as a single instance in the container.", name);
        NSMutableArray *instances = _multiInstances[name] ? : [NSMutableArray array];
        [instances addObject:_singleInstances[name]];
        [_singleInstances removeObjectForKey:name];
        _multiInstances[name] = instances;
    }
    
    if (_singleCreators[name]) {
        DDLogWarn(@"The given key %@ was already registered as a single creator in the container.", name);
        [creators addObject:_singleCreators[name]];
        [_singleCreators removeObjectForKey:name];
    }
    
    [creators addObject:creator];
    _multiCreators[name] = creators;
}


- (id)serviceWithName:(NSString *)name
{
    id instance = _singleInstances[name];
    if (instance != nil)
        return instance;
    
    PLServiceCreatorBlock creator = _singleCreators[name];
    if (creator != nil)
        return creator();
    
    return nil;
}

- (NSArray *)servicesWithName:(NSString *)name
{
    NSMutableArray *result = [NSMutableArray array];
    
    id instance = _singleInstances[name];
    if (instance != nil)
        [result addObject:instance];
    
    PLServiceCreatorBlock creator = _singleCreators[name];
    if (creator != nil)
        [result addObject:creator()];
    
    NSArray *instances = _multiInstances[name];
    if (instances != nil)
        [result addObjectsFromArray:instances];
    
    NSArray *creators = _multiCreators[name];
    if (creators != nil) {
        for (PLServiceCreatorBlock creator in creators) {
            [result addObject:creator()];
        }
    }
    
    return result;
}

@end
