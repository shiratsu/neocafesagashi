//
//  Common.m
//  BeLuv
//
//  Created by 平塚 俊輔 on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Common.h"
#import "TableDefine.h"


@implementation Common

+(UIColor*) hexToUIColor:(NSString *)hex alpha:(CGFloat)a{
	NSScanner *colorScanner = [NSScanner scannerWithString:hex];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
	CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
	CGFloat b =  (color & 0x0000FF) /255.0f;
	//NSLog(@"HEX to RGB >> r:%f g:%f b:%f a:%f\n",r,g,b,a);
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

+(UIImage *)scaleAndRotateImage:(UIImage *)image
{
	int kMaxResolution = 320; // Or whatever
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}

#pragma mark -
#pragma mark 現在日時
+(NSArray *)feedNowDate{
	
	//現在時刻を取得
	// フォーマットの定義
	NSDateFormatter *f1 = [[[NSDateFormatter alloc] init] autorelease];
	[f1 setDateFormat:@"YYYY-MM-dd"];
	
	NSDateFormatter *f2 = [[[NSDateFormatter alloc] init] autorelease];
	[f2 setDateFormat:@"YYYY"];
	
	NSDateFormatter *f3 = [[[NSDateFormatter alloc] init] autorelease];
	[f3 setDateFormat:@"MM"];
	
	NSDateFormatter *f4 = [[[NSDateFormatter alloc] init] autorelease];
	[f4 setDateFormat:@"dd"];
    
    NSDateFormatter *f5 = [[[NSDateFormatter alloc] init] autorelease];
	[f5 setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
	
	// 現在時刻を取得
	NSDate* now_date = [NSDate date];
	
	// 型変換：NSDate->NSString
	NSString *now_dateStr = [f1 stringFromDate:now_date];
	NSString *now_yyyy = [f2 stringFromDate:now_date];
	NSString *now_mm = [f3 stringFromDate:now_date];
	NSString *now_dd = [f4 stringFromDate:now_date];
    NSString *datetime = [f5 stringFromDate:now_date];
	
	NSArray *array = 
    [NSArray arrayWithObjects:now_dateStr, now_yyyy, now_mm, now_dd,datetime, nil];
	return array;
	
}	

#pragma mark -
#pragma mark トリムする
+(UIImage *)trimImage:(UIImage *)org 
                withW:(int )width 
                withH:(int )height 
                {
    
    
//    float w = org.size.width;
//    float h = org.size.height;
//    CGRect rect;
//    
//    if (h <= w) {
//        //横長の場合
//        float x = w / 2 - h / 2;
//        float y = 0;
//        rect = CGRectMake(x, y, width, height);
//    } else {
//        //縦長の場合
//        float x = 0;
//        float y = h / 2 - w / 2;
//        rect = CGRectMake(x, y, width, height);
//    }
    
    UIImage *trimImage;
    
    CGRect rect = CGRectMake(0, 0, width, height);  // 切り取る場所とサイズを指定
    UIGraphicsBeginImageContext(rect.size);
    [org drawAtPoint:rect.origin];
    trimImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext(); 
    return trimImage;
}

#pragma mark -
#pragma mark リサイズする
+(UIImage *)resizeImage:(UIImage *)org withW:(int )width withH:(int )height{
    
    CGImageRef imageRef = [org CGImage];  
    size_t w = CGImageGetWidth(imageRef);  
    size_t h = CGImageGetHeight(imageRef);  
    size_t resize_w, resize_h;  
    
    if (w>h) {  
        resize_w = width;  
        resize_h = h * resize_w / w;  
    } else {  
        resize_h = height;  
        resize_w = w * resize_h / h;  
    }  
    
    UIGraphicsBeginImageContext(CGSizeMake(resize_w, resize_h));  
    [org drawInRect:CGRectMake(0, 0, resize_w, resize_h)];  
    org = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();  
    
    return org;
}

#pragma mark -
#pragma mark エンコード情報が書かれたテーブル辞書を取得
+(NSDictionary *)feedTableEncode:(NSString *)tableName{
	
	// tableDefineのクラスオブジェクトを取得
	Class tableDefine;
	tableDefine = NSClassFromString(tableName);
	
	//クラスがあるかどうか確認
	if(tableDefine != nil){
		
		//初期化
		id object = [[tableDefine alloc] init];
		
		[object initEncode];
        
		return [object encode];
		
		// tableDefineがメソッドinitEncodeを実装しているかどうかを確認
		/*
         if ([object respondsToSelectlr:@selector(initEncode)]) {
         //初期化して返却
         [object performSelector:@selector(initEncode)];
         return [object encode];
         }
         */
	}	
	
	return nil;
}

#pragma mark 日付の差分を取得
+(NSTimeInterval)feedDateDiff:(NSString *)now diffDate:(NSString *)diffDate{
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
	[inputDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSDate *dateA = [inputDateFormatter dateFromString:diffDate];
	NSDate *dateB = [inputDateFormatter dateFromString:now];
	NSTimeInterval since;
    since = [dateA timeIntervalSinceDate:dateB];
    return since;
}


#pragma mark 指定した数字分前の日付を取得
+(NSString *)feedAgoDate:(int)ago{
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:ago*24*60*60]; // 
    
    
    NSDateFormatter *f5 = [[[NSDateFormatter alloc] init] autorelease];
	[f5 setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
	
	// 現在時刻を取得
	NSDate* now_date = [NSDate date];
    NSString *datetime = [f5 stringFromDate:date];
    
    return datetime;
    
    
}

@end
