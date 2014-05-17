//
//  NeoCafesagashiSpec.m
//  NeoCafesagashi
//
//  Created by HIRATSUKA SHUNSUKE on 2014/04/18.
//  Copyright (c) 2014年 HIRATSUKA SHUNSUKE. All rights reserved.
//

#import "Kiwi.h"

SPEC_BEGIN(MathSpec)

describe(@"Math", ^{
    it(@"is pretty cool", ^{
        NSUInteger a = 16;
        NSUInteger b = 26;
        [[theValue(a + b) should] equal:theValue(42)];
    });
});

SPEC_END


SPEC_BEGIN(MathSpec2)

describe(@"Math", ^{
    it(@"is pretty cool", ^{
        NSUInteger a = 20;
        NSUInteger b = 26;
        [[theValue(a + b) should] equal:theValue(46)];
    });
});

SPEC_END