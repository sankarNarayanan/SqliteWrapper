//
//  SqliteWrapper.m
//  TagSearch
//
//  Created by N Sankar on 14/10/15.
//  Copyright © 2015 N Sankar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqliteWrapper.h"
#import <sqlite3.h>

#define ENABLEFORIEGNKEYSUPPORT @"PRAGMA foreign_keys = ON;"
#define FORIEGNKEYSUPPORTFAILED @"failed to set the foreign_key pragma"
#define DEFAULT_VALUE @"dflt_value"

@implementation SqliteWrapper

@synthesize databaseName,databasePath;


- (id)init:(NSString *)dbName
{
    [self createDatabase:dbName];
    self.databaseName=[NSString stringWithFormat:@"%@",dbName];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    self.databasePath = [[NSString alloc]initWithFormat:@"%@",[documentsDir stringByAppendingPathComponent:dbName]];
    return self;
}

-(BOOL) createDatabase:(NSString *) dbName
{
    @try {
        BOOL success;
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [documentPaths objectAtIndex:0];
        databasePath = [[NSString alloc]initWithFormat:@"%@",[documentsDir stringByAppendingPathComponent:dbName]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        success = [fileManager fileExistsAtPath:databasePath];
        if(success)
        {
            return YES;
        }
        else
        {
            NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
            if([fileManager fileExistsAtPath:databasePathFromApp])
            {
                [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
                return YES;
            }
            else
            {
                sqlite3 *database;
                if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
                {
                    NSString *queryString = [NSString stringWithFormat:ENABLEFORIEGNKEYSUPPORT];
                    const char *queryChar = [queryString UTF8String];
                    char *errmsg;
                    if (sqlite3_exec(database, queryChar , 0, NULL, &errmsg) != SQLITE_OK)
                    {
                        NSLog(FORIEGNKEYSUPPORTFAILED);
                    }
                    sqlite3_close(database);
                    return YES;
                }
                else
                {
                    return NO;
                }
            }
        }
    }
    @catch (NSException *exp) {
        
    }
}

-(NSMutableArray*)executeQuery:(NSString*)readCommand : (NSArray*)inputs
{
    @try{
        NSMutableArray *tableDataArray=[[NSMutableArray alloc] init];
        sqlite3 *database;
        if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        {
            NSString *queryString = [NSString stringWithFormat:ENABLEFORIEGNKEYSUPPORT];
            const char *queryChar = [queryString UTF8String];
            char *errmsg;
            if (sqlite3_exec(database, queryChar , 0, NULL, &errmsg) != SQLITE_OK)
            {
                NSLog(FORIEGNKEYSUPPORTFAILED);
            }
            const char *sqlStatement = [readCommand UTF8String];
            sqlite3_stmt *compiledStatement;
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
            {
                for(int inputCount = 0; inputCount < [inputs count] ; inputCount ++ )
                {
                    sqlite3_bind_text(compiledStatement, inputCount, [[inputs objectAtIndex:inputCount] UTF8String], -1, SQLITE_TRANSIENT);
                }
                while(sqlite3_step(compiledStatement) == SQLITE_ROW)
                {
                    int count = sqlite3_column_count (compiledStatement);
                    
                    NSMutableDictionary *record=[[NSMutableDictionary alloc] init];
                    
                    for(int index=0;index<count;index++)
                    {
                        [record setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, index)] forKey:[NSString stringWithUTF8String:(char *)sqlite3_column_name(compiledStatement, index)]];
                    }
                    
                    [tableDataArray addObject:record];
                }
            }
        }
        sqlite3_close(database);
        return tableDataArray;
    }
    @catch (NSException * exp) {
        
    }
}


-(void)executeQuery:(NSString*)query
{
    @try{
        NSString *finalUpdateCommand=query;
        sqlite3 *database;
        if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        {
            NSString *queryString = [NSString stringWithFormat:ENABLEFORIEGNKEYSUPPORT];
            const char *queryCharNew = [queryString UTF8String];
            char *errmsgNew;
            if (sqlite3_exec(database, queryCharNew , 0, NULL, &errmsgNew) != SQLITE_OK)
            {
                NSLog(FORIEGNKEYSUPPORTFAILED);
            }
            NSString *query = [NSString stringWithFormat:ENABLEFORIEGNKEYSUPPORT];
            const char *queryChar = [query UTF8String];
            char *errmsg;
            if (sqlite3_exec(database, queryChar , 0, NULL, &errmsg) != SQLITE_OK)
            {
                NSLog(FORIEGNKEYSUPPORTFAILED);
            }
            const char *sqlStatement = [finalUpdateCommand UTF8String];
            sqlite3_stmt *compiledStatement;
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
            {
                while(sqlite3_step(compiledStatement) == SQLITE_ROW)
                {
                    
                }
                sqlite3_finalize(compiledStatement);
            }
            else
            {
                NSLog(@"error: %s\n",sqlite3_errmsg(database));
            }
        }
        sqlite3_close(database);
    }
    @catch (NSException * exp) {
        
    }
}

-(void)executeBatchQueries:(NSMutableArray *)arrayOfQueries
{
    sqlite3 *database;
    BOOL status1=FALSE;
    char *error;
    if(![arrayOfQueries count]==0)
    {
        @try
        {
            if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
            {
                sqlite3_exec(database, "BEGIN", 0, 0, 0);
                NSString *query = [NSString stringWithFormat:ENABLEFORIEGNKEYSUPPORT];
                const char *queryChar = [query UTF8String];
                char *errmsg;
                if (sqlite3_exec(database, queryChar , 0, NULL, &errmsg) != SQLITE_OK)
                {
                    NSLog(FORIEGNKEYSUPPORTFAILED);
                }
                for(int recordNum=0;recordNum<[arrayOfQueries count];recordNum++)
                {
                    NSString *queryString=[NSString stringWithFormat:@"%@",[arrayOfQueries objectAtIndex:recordNum]];
                    if (!sqlite3_exec(database, [queryString UTF8String], NULL, NULL, &error) == SQLITE_OK)
                    {
                        NSLog(@"Error: %s", error);
                    }
                }
                sqlite3_exec(database, "COMMIT", 0, 0, 0);
                status1=TRUE;
            }
            
            else {
                sqlite3_exec(database, "ROLLBACK", 0, 0, 0);
            }
        }
        @catch(NSException *exception)
        {
            
        }
        @finally
        {
            
        }
    }
    
}


-(void)executePreparedStatementWithQueryArray : (NSArray*)sqlQueries : (NSArray*)parameterArray
{
    sqlite3 *database = NULL;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        NSString *queryString = [NSString stringWithFormat:ENABLEFORIEGNKEYSUPPORT];
        const char *queryChar = [queryString UTF8String];
        char *errmsg;
        if (sqlite3_exec(database, queryChar , 0, NULL, &errmsg) != SQLITE_OK)
        {
            NSLog(FORIEGNKEYSUPPORTFAILED);
        }
        for(int queryCount = 0; queryCount < [sqlQueries count];queryCount++)
        {
            NSString *sql = (NSString*)[sqlQueries objectAtIndex:queryCount];
            NSArray *params = (NSArray*)[parameterArray objectAtIndex:queryCount];
            sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, NULL);
            sqlite3_stmt *statement;
            const char *query = [sql UTF8String];
            if(sqlite3_prepare_v2(database, query, -1, &statement, NULL) == SQLITE_OK)
            {
                //BIND the params!
                int count =0;
                for (id param in params ) {
                    count++;
                    if ((!param) || ((NSNull *)param == [NSNull null])) {
                        sqlite3_bind_null(statement, count);
                    }
                    
                    // FIXME - someday check the return codes on these binds.
                    else if ([param isKindOfClass:[NSData class]]) {
                        const void *bytes = [param bytes];
                        if (!bytes) {
                            // it's an empty NSData object, aka [NSData data].
                            // Don't pass a NULL pointer, or sqlite will bind a SQL null instead of a blob.
                            bytes = "";
                        }
                        sqlite3_bind_blob(statement, count, bytes, (int)[param length], SQLITE_STATIC);
                    }
                    else if ([param isKindOfClass:[NSDate class]]) {
                        sqlite3_bind_double(statement, count, [param timeIntervalSince1970]);
                    }
                    else if ([param isKindOfClass:[NSNumber class]]) {
                        
                        if (strcmp([param objCType], @encode(BOOL)) == 0) {
                            sqlite3_bind_int(statement, count, ([param boolValue] ? 1 : 0));
                        }
                        else if (strcmp([param objCType], @encode(int)) == 0) {
                            sqlite3_bind_int64(statement, count, [param longValue]);
                        }
                        else if (strcmp([param objCType], @encode(long)) == 0) {
                            sqlite3_bind_int64(statement, count, [param longValue]);
                        }
                        else if (strcmp([param objCType], @encode(long long)) == 0) {
                            sqlite3_bind_int64(statement, count, [param longLongValue]);
                        }
                        else if (strcmp([param objCType], @encode(unsigned long long)) == 0) {
                            sqlite3_bind_int64(statement, count, (long long)[param unsignedLongLongValue]);
                        }
                        else if (strcmp([param objCType], @encode(float)) == 0) {
                            sqlite3_bind_double(statement, count, [param floatValue]);
                        }
                        else if (strcmp([param objCType], @encode(double)) == 0) {
                            sqlite3_bind_double(statement, count, [param doubleValue]);
                        }
                        else {
                            sqlite3_bind_text(statement, count, [[param description] UTF8String], -1, SQLITE_STATIC);
                        }
                    }
                    else {
                        sqlite3_bind_text(statement, count, [[param description] UTF8String], -1, SQLITE_STATIC);
                    }
                }
                if (sqlite3_step(statement) != SQLITE_DONE)
                {
                    printf("Commit Failed!\n");
                    NSLog(@"%s: sqlite3_prepare error: %s ", __FUNCTION__, sqlite3_errmsg(database));
                }
                sqlite3_clear_bindings(statement);
                sqlite3_reset(statement);
            }
        }
        sqlite3_exec(database, "END TRANSACTION", NULL, NULL, NULL);
    }
    sqlite3_close(database);
}

-(NSArray*)executeAnyQuery : (NSString*)query
{
    
    NSMutableArray *tableDataArray=[[NSMutableArray alloc] init];
    sqlite3 *database;
    NSString *readCommand=[NSString stringWithFormat:@"%@",query];
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *query = [NSString stringWithFormat:ENABLEFORIEGNKEYSUPPORT];
        const char *queryChar = [query UTF8String];
        char *errmsg;
        if (sqlite3_exec(database, queryChar , 0, NULL, &errmsg) != SQLITE_OK)
        {
            NSLog(FORIEGNKEYSUPPORTFAILED);
        }
        
        
        const char *sqlStatement = [readCommand UTF8String];
        
        sqlite3_stmt *compiledStatement;
        
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
            {
                int count = sqlite3_column_count (compiledStatement);
                
                NSMutableDictionary *record=[[NSMutableDictionary alloc] init];
                
                for(int index=0;index<count;index++)
                {
                    if(![[NSString stringWithUTF8String:(char *)sqlite3_column_name(compiledStatement, index)] isEqualToString:DEFAULT_VALUE])
                    {
                        [record setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, index)] forKey:[NSString stringWithUTF8String:(char *)sqlite3_column_name(compiledStatement, index)]];
                    }
                }
                
                [tableDataArray addObject:record];
            }
        }
    }
    sqlite3_close(database);
    return tableDataArray;
}


@end
