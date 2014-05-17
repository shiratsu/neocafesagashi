//
//  Common.h
//  BeLuv
//
//  Created by 平塚 俊輔 on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Common : NSObject {

}
+(UIColor*) hexToUIColor:(NSString *)hex alpha:(CGFloat)a;
+(UIImage *)scaleAndRotateImage:(UIImage *)image;
+(NSArray *)feedNowDate;
+(UIImage *)trimImage:(UIImage *)org 
                withW:(int )width 
                withH:(int )height;
+(UIImage *)resizeImage:(UIImage *)org withW:(int )width withH:(int )height;
+(NSDictionary *)feedTableEncode:(NSString *)tableName;
+(NSTimeInterval)feedDateDiff:(NSString *)now diffDate:(NSString *)diffDate;

+(NSString *)feedAgoDate:(int)ago;

@end
