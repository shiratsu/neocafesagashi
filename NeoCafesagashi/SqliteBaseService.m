//
//  SqliteBaseService.m
//  BeLuv
//
//  Created by 平塚俊輔 on 11/07/19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SqliteBaseService.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "TableDefine.h"
#import "Common.h"

#define DBFILE @"cafesagashi.db"

@implementation SqliteBaseService

@synthesize checkListAry;
@synthesize bindAry;
@synthesize valueAry;
@synthesize columnAry;
@synthesize insertAry;
@synthesize totalCount;

- (id)init
{
    if(self = [super init]){
        /* initialization code */
		bindAry = [[NSMutableArray alloc] initWithCapacity:0];
		insertAry = [[NSMutableArray alloc] initWithCapacity:0];
		valueAry = [[NSMutableArray alloc] initWithCapacity:0];
		columnAry = [[NSMutableArray alloc] initWithCapacity:0];
		
    }
    return self;
}

#pragma mark -
#pragma mark 取得結果配列を初期化
-(void)initData{
    totalCount=0;
	checkListAry = [[NSMutableArray alloc] init];	
}	

#pragma mark -
#pragma mark 件数を返す
-(int)countCheckListAry{
	return [checkListAry count];
}	


#pragma mark -
#pragma mark データベースインスタンスを返す
/**
 *  DBのインスタンスを返す
 *
 *  @param dbName DBの名称
 *
 *  @return FMDBオブジェクト
 */
- (FMDatabase*)_getDB:(NSString*)dbName {
	
	NSError *dbError;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:dbName];
	BOOL success = [fm fileExistsAtPath:writableDBPath];
	if(!success){
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
		success = [fm copyItemAtPath:defaultDBPath toPath:writableDBPath error:&dbError];
		if(!success){
			NSLog([dbError localizedDescription]);
		}
	}
	// DBに接続
	FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    if (![db open]) {
        @throw [NSException exceptionWithName:@"DBOpenException" reason:@"couldn't open specified db file" userInfo:nil];
    }
	
    return db;
}

#pragma mark -
#pragma mark データ削除
//-(void)deleteTable:(NSString *)tableName 
//            withId:(NSString *)dataId 
//           withKey:(NSString *)key
//      withHolderId:(NSString *)holderId
//            withDb:(FMDatabase *)db
//{
//    FMDatabase* db = [self _getDB:DBFILE];
//    @try {
//		NSString *deleteQuery = [NSString stringWithFormat:@"delete from %@ where %@ = %@",tableName,key,dataId];
//        if (![db executeUpdate:deleteQuery]){
//			
//			
//			@throw [NSException exceptionWithName:@"sqlexception" reason:@"delete error" userInfo:nil];
//			
//		}
//		[self checkTableUpdate:db withHolderId:HolderId];
//		[db commit];
//		[db close];
//	}
//	@catch (NSException * e) {
//		
//		// 例外処理を書く
//		NSLog(@"例外名[%@] 例外の理由[%@]", [e name], [e reason]);
//		
//		// メソッド名とそのメソッドが属するクラス名を表示
//		NSLog(@"%s", __func__);
//		// ソースファイル名と行番号を表示
//		NSLog(@"[%s][%d]", __FILE__, __LINE__);
//		
//		
//		[db rollback];
//		[db close];
//		return NO;
//	}
//	
//	
//	return YES;
//    
//}    
//
#pragma mark -
#pragma mark 削除テーブルを更新
-(void)insertDeleteTable:(NSString *)tableName 
             withAccount:(NSString *)accountId
                  withId:(NSString *)deleteId
                  withDb:(FMDatabase *)db
{
    NSString *sql = [NSString stringWithFormat:@"insert into DeleteTable(AccountId, DeleteId, DeleteTable, LastUpdate) values('%@','%@','%@',current_timestamp)",accountId,deleteId,tableName];
    if (![db executeUpdate:sql]){
        NSException *exception = [NSException exceptionWithName:@"接続エラー"
                                                         reason:@"接続エラー"
                                                       userInfo:nil];
        @throw exception;
    }
    return;
}

#pragma mark - 
#pragma mark where句を作成
- (NSString *)createWhereParam:(NSDictionary *)dict{
	
	NSString *whereParam = @"";
	NSMutableArray *paramAry = [NSMutableArray array];
	for(NSString *key in dict){
        
        NSString *value = [dict objectForKey:key];
        if(![key isEqualToString:@"start"] && ![key isEqualToString:@"results"] && ![key isEqualToString:@"sort"]){
            
            if([key isEqualToString:@"FullTextColumn"]){
                if(value != nil && ![value isEqualToString:@""]){
                    [paramAry addObject:[NSString stringWithFormat:@"%@ match '%@'",key,value]];
                }    
            }else if([key isEqualToString:@"RegisterMonth"]){
                if(value != nil && ![value isEqualToString:@""]){
                    [paramAry addObject:[NSString stringWithFormat:@"date(RegisterDate) between '%@-01' and '%@-31'",value,value]];
                }
            }else if([key isEqualToString:@"LastUpdateMonth"]){
                if(value != nil && ![value isEqualToString:@""]){
                    [paramAry addObject:[NSString stringWithFormat:@"date(LastUpdate) between '%@-01' and '%@-31'",value,value]];
                }                         
            }else{    
                //データが入ってれば
                if(value != nil && ![value isEqualToString:@""]){
                    [paramAry addObject:[NSString stringWithFormat:@"%@ = '%@'",key,value]];
                }
            }    
        }    
			
	}
	if([paramAry count] > 0){
		whereParam = [NSString stringWithFormat:@"where %@",[paramAry componentsJoinedByString:@" and "]];
	}											   
	return whereParam;
}


#pragma mark -
#pragma mark updateのbind,valueを作成
- (void)createBindValueParam:(NSDictionary *)dict withTable:(NSString *)tableName{
	bindAry = [[NSMutableArray alloc] initWithCapacity:0];
    valueAry = [[NSMutableArray alloc] initWithCapacity:0];
    
    //テーブルクラスがあるか確認
    Class tableDefine;
	tableDefine = NSClassFromString(tableName);
    if(tableDefine != nil){
		
		//初期化
		id object = [[tableDefine alloc] init];
		
		[object initEdit];
		
		NSDictionary *editDict = [object inputedit];
        
//        NSLog(@"dict:%@",dict);
//        NSLog(@"editDict:%@",editDict);
        bindAry = [[NSMutableArray alloc] initWithCapacity:0];
        valueAry = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSString *key in dict){
            
            if([[editDict allKeys] containsObject:key]){
                if(![key isEqualToString:@"AlertCheck"]){
                    NSString *value = [dict objectForKey:key];
                    //データが入ってれば
                    if(value != nil && ![value isEqualToString:@""]){
                        [bindAry addObject:[NSString stringWithFormat:@"%@ = ?",key]];
                        [valueAry addObject:value];
                    } 
                }else{
                    NSString *value = [dict objectForKey:key];
                    [bindAry addObject:[NSString stringWithFormat:@"%@ = ?",key]];
                    [valueAry addObject:value];
                }
                
            }    
        }
    }
	return;
}


#pragma mark -
#pragma mark selectする配列を取得
-(NSString *)createSelectColumn:(NSString *)tableName{
	Class tableDefine;
	tableDefine = NSClassFromString(tableName);
	NSString *selectColumn = nil;
	//クラスがあるかどうか確認
	if(tableDefine != nil){
		
		//初期化
		id object = [[tableDefine alloc] init];
		
		columnAry = [object columnAry];
        NSLog(@"column:%@",columnAry);
		selectColumn = [columnAry componentsJoinedByString:@","];
		
		
	}	
	
	return selectColumn;
}



#pragma mark -
#pragma mark insert用の配列を作成
-(void)createInputValueAry:(NSString *)tableName withInputValue:(NSMutableDictionary *)dict{
	
    bindAry = [[NSMutableArray alloc] initWithCapacity:0];
    valueAry = [[NSMutableArray alloc] initWithCapacity:0];
    insertAry = [[NSMutableArray alloc] initWithCapacity:0];
   
    
    Class tableDefine;
	tableDefine = NSClassFromString(tableName);
	
	//クラスがあるかどうか確認
	if(tableDefine != nil){
		
		//初期化
		id object = [[tableDefine alloc] init];
		
		[object initInput];
		
		NSDictionary *inputDict = [object inputmust];
		//NSLog(@"inputDict:%@",inputDict);
		//NSLog(@"dict:%@",dict);
		for (id key in inputDict) {
			
			NSLog(@"key:%@",key);
			int checkFlg = [[inputDict objectForKey:key] intValue];
			
			switch (checkFlg) {
				case 0:	
					if ([[dict allKeys] containsObject:key]) {
						[insertAry addObject:key];
						[bindAry addObject:@"?"];
						[valueAry addObject:[dict objectForKey:key]];
					}
					break;
				case 1:
					if ([dict objectForKey:key] != nil) {
						[insertAry addObject:key];
						[bindAry addObject:@"?"];
						[valueAry addObject:[dict objectForKey:key]];
					}else{
						//必須項目がないのでエラー
                        NSLog(@"必須エラー");
						NSException *exception = [NSException exceptionWithName:@"必須項目エラー"
                                                                         reason:@"必須エラー"
                                                                       userInfo:nil];
                        @throw exception;
					}	
					break;
				case 9:
					[insertAry addObject:key];
					[bindAry addObject:@"?"];
					[valueAry addObject:@"current_timestamp"];
					break;	
				default:
					break;
			}
				
		}	
		
		
	}	
	
	return;
}
                                     

                                     
#pragma mark -                                     
#pragma mark セレクトの件数                                     
-(void)selectTotalCount:(NSMutableString *)queryCount 
              withWhere:(NSString *)queryWhere 
                 withDb:(FMDatabase *)db{
    if(queryWhere != nil){
        if(queryWhere != nil){
            [queryCount appendString:[NSString stringWithFormat:@" %@",queryWhere]];
        }
    }
    
    FMResultSet *rs = [db executeQuery:queryCount];
                     
    //件数を取得
    while ([rs next]) {
        totalCount = [[rs stringForColumn:@"count(1)"] intValue];            
        
    }                 
    NSLog(@"totalCount:%d",totalCount);
                                                     
}

#pragma mark -
#pragma mark リミット句作成
-(NSString *)createLimit:(NSMutableDictionary*)limitItem{
    
    NSLog(@"limitItem：%@",limitItem);
    
	NSString *limit = nil;
    if(limitItem != nil){
        if ([limitItem objectForKey:@"start"] != nil && [limitItem objectForKey:@"results"] != nil) {
            limit = [NSString stringWithFormat:@"LIMIT %@ OFFSET %@",[limitItem objectForKey:@"results"],[limitItem objectForKey:@"start"]];
        }else{
            limit = [NSString stringWithFormat:@"LIMIT 10 OFFSET 0"];
        }
    }
		
	return limit;
}
 
#pragma mark -
#pragma mark 削除処理
- (void)executeDelete:(NSString *)deleteId
        withDeleteKey:(NSString *)key                   
            withTable:(NSString *)tableName 
               withDb:(FMDatabase *)db{
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",tableName,key,deleteId];
    if (![db executeUpdate:deleteSql]){
        NSLog(@"ERROR: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        NSException *exception = [NSException exceptionWithName:@"SQL DELETE ERROR"
                                                         reason:[db lastErrorMessage]
                                                       userInfo:nil];
        @throw exception;
    }
    return;
}                                                        


#pragma mark -
#pragma mark insert処理
- (void)executeInsert:(NSMutableDictionary *)item 
            withTable:(NSString *)tableName 
               withDb:(FMDatabase *)db{
	
	
                   
    NSString *defineName = [NSString stringWithFormat:@"%@Define",tableName];
    //NSLog(@"defineName:%@",defineName);
    //NSLog(@"item:%@",item);
    [self createInputValueAry:defineName withInputValue:item];
                   
    //NSLog(@"insert:%@",insertAry);
    //NSLog(@"bind:%d",[bindAry count]);
    //NSLog(@"valueAry:%@",valueAry);
    
    //NSLog(@"valueAryCount:%d",[valueAry count]);
                   
    if([bindAry count] == 0){
        NSLog(@"test");
        @throw [NSException exceptionWithName:@"invalidArgumentException" reason:@"valid error" userInfo:nil];
    }
                   
    NSString *insertColumn = [insertAry componentsJoinedByString:@","];
                   
    NSString *bindColumn = [bindAry componentsJoinedByString:@","];
                   
    
            
    NSString *insertSql = [NSString stringWithFormat:@"insert into %@("
                                          "%@,LastUpdate"
                                          ") values("
                                          "%@,current_timestamp)",tableName,insertColumn,bindColumn];
    NSLog(@"%@",insertSql);
    if (![db executeUpdate:insertSql withArgumentsInArray:valueAry]){
                       
        NSLog(@"ERROR: %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        NSException *exception = [NSException exceptionWithName:@"SQL実行エラー"
                                                         reason:[db lastErrorMessage]
                                                       userInfo:nil];
        @throw exception;
                
    }
	
	
	return;
}
                                     
                                     

#pragma mark -
#pragma mark 更新系
- (void)executeUpdate:(NSMutableDictionary *)item 
				where:(NSDictionary *)whereItem 
			withTable:(NSString *)tableName 
               withDb:(FMDatabase *)db{
	
	NSLog(@"item:%@",item);
    NSString *defineName = [NSString stringWithFormat:@"%@Define",tableName];
    [self createBindValueParam:item withTable:defineName];
                   
                   
    NSString *bindSql = [bindAry componentsJoinedByString:@","];
                   
                   
    
    NSString *whereSql = [self createWhereParam:whereItem];
    NSString *updateSql = [NSString stringWithFormat:@"update %@ set " 
                                          "%@"
                                          ",LastUpdate = current_timestamp "
                                          "%@",tableName,bindSql,whereSql];
    NSLog(@"update:%@",updateSql);
                   
                   
    if (![db executeUpdate:updateSql withArgumentsInArray:valueAry]){
    
        NSLog(@"ERROR: %d: %@", [db lastErrorCode], [db lastErrorMessage]); 
        NSException *exception = [NSException exceptionWithName:@"SQL UPDATE ERROR"
                                                          reason:[db lastErrorMessage]
                                                        userInfo:nil];
        @throw exception;
                       
    }	
	
	return;
}


#pragma mark -
#pragma mark マスター更新実処理
-(BOOL)masterInsert:(NSMutableArray *)dataAry{
    
    FMDatabase* db = [self _getDB:DBFILE];
    @try {
        NSLog(@"BeGin");
        NSLog(@"%@",dataAry);
		[db beginTransaction];
        for(NSMutableDictionary *master in dataAry)
        {
            if([[master allKeys] containsObject:@"TableName"]){
                
                NSString *tableName = [master objectForKey:@"TableName"];
                
                //削除テーブルじゃなかったら
                if(![tableName isEqualToString:@"DeleteTable"]){
                    
                    [self insertEachTable:master withTable:tableName withDb:db];
                }else{
                    
                    
//                    [self executeDelete:deleteId withDeleteKey:deleteKeyColumn withTable:deleteTable withDb:db];
                    
                }
                
            }else{
                NSException *exception = [NSException exceptionWithName:@"table found error"
                                                                 reason:@"テーブルが見つかりません"
                                                               userInfo:nil];
                @throw exception;
            }
            
        }
    	[db commit];
		[db close];
	}	
	@catch (NSException * e) {
		
		// 例外処理を書く
		NSLog(@"例外名[%@] 例外の理由[%@]", [e name], [e reason]);
		
		// メソッド名とそのメソッドが属するクラス名を表示
		NSLog(@"%s", __func__);
		// ソースファイル名と行番号を表示
		NSLog(@"[%s][%d]", __FILE__, __LINE__);
		
		
		[db rollback];
		[db close];
		return NO;
	}
	return YES;
}

#pragma mark それぞれのテーブルに投入
-(void)insertEachTable:(NSMutableDictionary *)master 
             withTable:(NSString *)tableName 
                withDb:(FMDatabase *)db{
    
    NSString *id1 = nil;
    NSString *id2 = nil;
    NSString *id3 = nil;
    NSMutableArray *whereAry = [NSMutableArray array];
    
    BOOL insertFlag = NO;
    if([tableName isEqualToString:@"WorkAlertCondition"]){
        id1 = [master objectForKey:@"ConditionId"];
        [whereAry addObject:[NSString stringWithFormat:@"ConditionId = '%@'",id1]];
        
    }else if([tableName isEqualToString:@"AlertBasicInfo"]){
        id1 = [master objectForKey:@"AlertBasicId"];
        [whereAry addObject:[NSString stringWithFormat:@"AlertBasicId = '%@'",id1]];  
        
    }else if([tableName isEqualToString:@"WorkAlertData"]){
        id1 = [master objectForKey:@"WorkId"];
        id2 = [master objectForKey:@"AlertBasicId"];
        [whereAry addObject:[NSString stringWithFormat:@"WorkId = '%@'",id1]];
        [whereAry addObject:[NSString stringWithFormat:@"AlertBasicId = '%@'",id2]];
        
    }
    
    //insertかどうかの判断のため、件数を確認
    int count = [self checkCountTable:tableName withWhere:whereAry withDb:db];
    
    NSLog(@"count:%d",count);
    if(count == 0){
        insertFlag = YES;
    }
    //投入なら
    if(insertFlag == YES){
        NSLog(@"id2:%@",id2);
        [self executeInsert:master withTable:tableName withDb:db];
    }else{
        NSMutableDictionary *whereDict = [NSMutableDictionary dictionary];
        if([tableName isEqualToString:@"WorkAlertData"]){
            [whereDict setObject:id1 forKey:@"WorkId"];
            [whereDict setObject:id2 forKey:@"AlertBasicId"];
            
        }else if([tableName isEqualToString:@"WorkAlertCondition"]){
            [whereDict setObject:id1 forKey:@"ConditionId"];
            
        }else if([tableName isEqualToString:@"AlertBasicInf"]){
            [whereDict setObject:id1 forKey:@"AlertBasicId"]; 
            
            
        }
        [self executeUpdate:master where:whereDict withTable:tableName withDb:db];
        
    }
    
}

#pragma mark 件数を取得
-(int)checkCountTable:(NSString *)tableName 
            withWhere:(NSMutableArray *)whereAry 
               withDb:(FMDatabase *)db{
    
    NSString *whereSql = nil;
    int count = 0;
    if([whereAry count] > 0){
		whereSql = [NSString stringWithFormat:@"where %@",[whereAry componentsJoinedByString:@" and "]];
	}
    NSString *query = [NSString stringWithFormat:@"select count(1) from %@ %@",tableName,whereSql];
    FMResultSet *rs = [db executeQuery:query];
    NSLog(@"%@",query);
    //件数を取得
    while ([rs next]) {
        count = [[rs stringForColumn:@"count(1)"] intValue];
        
    }
    //NSLog(@"count:%d",count);
    return count;
    
}

#pragma mark -
#pragma mark 初期処理
- (void)handleDefaultTask:(NSString *)alertBasicId{
    
    NSString *days14Ago = [Common feedAgoDate:0];
    

    NSMutableDictionary *where = [[NSMutableDictionary alloc] init];
    [where setObject:alertBasicId forKey:@"AlertBasicId"];
    
    FMDatabase* db = [self _getDB:DBFILE];
    @try {
		[db beginTransaction];
        
		
        NSString *deleteSql = [NSString stringWithFormat:@"delete from WorkAlertData where AlertBasicId = '%@' and ApplyEndDate < '%@'",alertBasicId,days14Ago];
        NSLog(@"SQL:%@",deleteSql);
        if (![db executeUpdate:deleteSql]){
            NSException *exception = [NSException exceptionWithName:@"SQL実行エラー"
                                                             reason:@"delete error"
                                                           userInfo:nil];
            @throw exception;
        }
        
		[db commit];
		[db close];
	}	
	@catch (NSException * e) {
		
		// 例外処理を書く
		NSLog(@"例外名[%@] 例外の理由[%@]", [e name], [e reason]);
		
		// メソッド名とそのメソッドが属するクラス名を表示
		NSLog(@"%s", __func__);
		// ソースファイル名と行番号を表示
		NSLog(@"[%s][%d]", __FILE__, __LINE__);
		
		
		[db rollback];
		[db close];
		return;
	}
	return;
}



- (void)dealloc {

	
	self.columnAry=nil;
	self.bindAry=nil;
	self.valueAry=nil;
	self.insertAry=nil;
    

}



@end
