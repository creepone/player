//
//  PLActivity.h
//  Player
//
//  Created by Tomas Vana on 08/05/14.
//  Copyright (c) 2014 Tomas Vana. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLPromise;

@interface PLActivity : NSObject

/**
* The image of the icon to be shown in the activity view.
*/
@property (nonatomic, strong) UIImage *image;

/**
* The title to be shown under the icon in the activity view.
*/
@property (nonatomic, strong) NSString *title;

/**
* @abstract
* Asynchronously performs whatever logic this activity entails.
*/
- (PLPromise *)performActivity;

@end