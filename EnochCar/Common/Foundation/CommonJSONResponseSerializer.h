//
//  CommonJSONResponseSerializer.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/25.
//

#import "AFURLResponseSerialization.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const JSONResponseSerializerWithDataKey = @"body";
static NSString * const JSONResponseSerializerWithBodyKey = @"statusCode";


@interface CommonJSONResponseSerializer : AFJSONResponseSerializer

@end

NS_ASSUME_NONNULL_END
