//
//  SqliteWrapper.h
//  TagSearch
//
//  Created by N Sankar on 14/10/15.
//  Copyright © 2015 N Sankar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SqliteWrapper : NSObject {
    NSString *databaseName;
    NSString *databasePath;
}

/*
 to acess the databasepath and databasename through out the application
 */
@property(nonatomic,strong) NSString *databaseName,*databasePath;


-(BOOL) createDatabase:(NSString *) dbName;

-(NSMutableArray*)executeQuery:(NSString*)readCommand : (NSArray*)inputs;

-(void)executeQuery:(NSString*)query;

-(void)executeBatchQueries:(NSMutableArray *)arrayOfQueries;

-(void)executePreparedStatementWithQueryArray : (NSArray*)sqlQueries : (NSArray*)parameterArray;

-(NSArray*)executeAnyQuery : (NSString*)query;

@end
