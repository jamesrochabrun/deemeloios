//
//  Store.m
//  Deemelo
//
//  Created by Pablo Branchi on 6/7/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "Store.h"

@implementation Store

- (NSString *)description
{
    return [NSString stringWithFormat:@"< Store: storeID: %d, name: %@, address: %@, latitude: %@, longitud: %@, city: %@, province: %@, region: %@, country: %@ >", _storeID, _name, _address, _latitude, _longitude, _city, _province, _region, _country];
}

@end
