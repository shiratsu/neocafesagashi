//
//  TableDefine.m
//  BeLuv
//
//  Created by 平塚俊輔 on 11/07/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TableDefine.h"


@implementation TableDefine
@synthesize encode;
@synthesize inputmust;
@synthesize inputedit;
@synthesize inputoption;
@synthesize columnAry;

- (id)init
{
    if(self = [super init]){
        /* initialization code */
		encode = [[NSMutableDictionary alloc] initWithCapacity:0];
		inputmust = [[NSMutableDictionary alloc] initWithCapacity:0];
        inputedit = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return self;
}


#pragma mark エンコード系
-(void)initEncode{
	
}

#pragma mark 必須入力系
-(void)initInput{
	

	
}

#pragma mark 更新系
-(void)initEdit{
	

	
}	



@end
