//
//  TableDefine.h
//  BeLuv
//
//  Created by 平塚俊輔 on 11/07/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TableDefine : NSObject {
	
	
	NSMutableDictionary *encode;
	NSMutableDictionary *iunputmust;
    NSMutableDictionary *inputedit;
	NSMutableDictionary *inputoption;
	NSArray *columnAry;
	
}
@property(nonatomic,retain) NSMutableDictionary *encode;
@property(nonatomic,retain) NSMutableDictionary *inputmust;
@property(nonatomic,retain) NSMutableDictionary *inputoption;
@property(nonatomic,retain) NSMutableDictionary *inputedit;
@property(nonatomic,retain) NSArray *columnAry;

-(void)initInput;
-(void)initEncode;
-(void)initColumnAry;
-(void)initEdit;
@end
