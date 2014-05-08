//
//  PLActivity.m
//  Player
//
//  Created by Tomas Vana on 08/05/14.
//  Copyright (c) 2014 Tomas Vana. All rights reserved.
//

#import "PLActivity.h"
#import "PLPromise.h"

@implementation PLActivity

- (PLPromise *)performActivity
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

@end
