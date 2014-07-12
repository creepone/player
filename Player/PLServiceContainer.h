#import <Foundation/Foundation.h>

typedef id (^PLServiceCreatorBlock)();

#define PLResolve(PROTO) ((id<PROTO>)[[PLServiceContainer sharedContainer] serviceWithName:NSStringFromProtocol(@protocol(PROTO))])
#define PLResolveMany(PROTO) ([[PLServiceContainer sharedContainer] servicesWithName:NSStringFromProtocol(@protocol(PROTO))])

@interface PLServiceContainer : NSObject

+ (PLServiceContainer *)sharedContainer;

/**
 Registers the given service as a single instance under the key defined by the name of the given protocol.
 */
- (void)registerInstance:(id)service underProtocol:(Protocol *)protocol;

/**
 Registers the given service as a single instance under the given key.
 */
- (void)registerInstance:(id)service underName:(NSString *)name;

/**
 Adds the given service into the list of instances and creators under the key defined by the name of the given protocol.
 */
- (void)addInstance:(id)service underProtocol:(Protocol *)protocol;

/**
 Adds the given service into the list of instances and creators under the given key.
 */
- (void)addInstance:(id)service underName:(NSString *)name;

/**
 Registers the given service creator as a single creator under the key defined by the name of the given protocol.
 */
- (void)registerCreator:(PLServiceCreatorBlock)creator underProtocol:(Protocol *)protocol;

/**
 Registers the given service creator as a single creator under the given key.
 */
- (void)registerCreator:(PLServiceCreatorBlock)creator underName:(NSString *)name;

/**
 Adds the given service creator into the list of instances and creators under the key defined by the name of the given protocol.
 */
- (void)addCreator:(PLServiceCreatorBlock)creator underProtocol:(Protocol *)protocol;

/**
 Adds the given service creator into the list of instances and creators under the given key.
 */
- (void)addCreator:(PLServiceCreatorBlock)creator underName:(NSString *)name;


/**
 Delivers a single service stored under the given key.
 */
- (id)serviceWithName:(NSString *)name;

/**
 Delivers all the services stored under the given key.
 */
- (NSArray *)servicesWithName:(NSString *)name;

@end
