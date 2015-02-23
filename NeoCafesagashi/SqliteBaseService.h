//
//  SqliteBaseService.h
//  BeLuv
//
//  Created by 平塚俊輔 on 11/07/19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface SqliteBaseService : NSObject {
	NSMutableArray *checkListAry;
	NSMutableArray *bindAry;
	NSMutableArray *valueAry;
	NSMutableArray *insertAry;
	
	NSMutableArray *columnAry;
    
    int totalCount;
	
	
}
@property(nonatomic) NSMutableArray *checkListAry;
@property(nonatomic,retain) NSMutableArray *insertAry;
@property(nonatomic,retain) NSMutableArray *bindAry;
@property(nonatomic,retain) NSMutableArray *valueAry;
@property(nonatomic,retain) NSMutableArray *columnAry;
@property(nonatomic,assign) int totalCount;

- (FMDatabase*)_getDB:(NSString*)dbName;

-(void)initData;
-(NSString *)createSelectColumn:(NSString *)tableName;
-(void)createInputValueAry:(NSString *)tableName 
            withInputValue:(NSMutableDictionary *)dict;

-(void)createBindValueParam:(NSDictionary *)dict;
-(NSString *)createWhereParam:(NSDictionary *)dict;


-(NSString *)createLimit:(NSMutableDictionary*)limitItem;
-(void)selectTotalCount:(NSMutableString *)queryCount 
              withWhere:(NSString *)queryWhere 
                 withDb:(FMDatabase *)db;

//-(void)deleteTable:(NSString *)tableName 
//            withId:(NSString *)dataId 
//           withKey:(NSString *)key
//      withHolderId:(NSString *)holderId
//            withDb:(FMDatabase *)db;

- (void)executeInsert:(NSMutableDictionary *)item 
            withTable:(NSString *)tableName 
               withDb:(FMDatabase *)db;

- (void)executeUpdate:(NSMutableDictionary *)item 
				where:(NSDictionary *)whereItem 
			withTable:(NSString *)tableName 
               withDb:(FMDatabase *)db;

-(void)insertDeleteTable:(NSString *)tableName 
              withAccount:(NSString *)accountId
                  withId:(NSString *)deleteId
                  withDb:(FMDatabase *)db;


- (void)executeDelete:(NSString *)deleteId
        withDeleteKey:(NSString *)key                   
            withTable:(NSString *)tableName 
               withDb:(FMDatabase *)db;

-(int)checkCountTable:(NSString *)tableName 
            withWhere:(NSMutableArray *)whereAry 
               withDb:(FMDatabase *)db;
-(void)insertEachTable:(NSMutableDictionary *)master 
             withTable:(NSString *)tableName 
                withDb:(FMDatabase *)db;
-(BOOL)masterInsert:(NSMutableArray *)dataAry;

- (void)handleDefaultTask:(NSString *)alertBasicId;

@end
