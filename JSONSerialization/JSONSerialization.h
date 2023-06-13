//
//  JSONSerialization.h
//  JSONSerialization
//
//  Created by mac on 2023/6/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSONSerialization : NSObject
+ (nullable id)JSONObjectWithData:(NSData *)data error:(NSError **)error;
+ (nullable id)JSONObjectWithString:(NSString *)json error:(NSError **)error;
+ (nullable id)JSONObjectWithcString:(const char *)cjson error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
