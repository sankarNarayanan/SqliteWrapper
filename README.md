# SqliteWrapper
This is a re usable snippet containing Sqlite wrapper with a sample application.

1. To use the library please pass a data base to the method -(BOOL) createDatabase:(NSString *) dbName.

once this is done the database will be created in app sandbox.

2. To execute a single query with which is not a fetch operation, the following method can be used.

-(void)executeQuery:(NSString*)query

2. To execute a single query including fetch operation, the following method can be used. This is for using 
the same as a prepared statement.

a. Query will have query with question marks.
b. Option will have array of list to be substituted.

-(NSMutableArray*)executeQuery:(NSString*)readCommand : (NSArray*)inputs

3. To execute a single query with fetch operation, with out prepared statement. use the following method:

-(NSArray*)executeAnyQuery : (NSString*)query

4. To execute batch query execution with an array of queries, use the following method:

-(void)executeBatchQueries:(NSMutableArray *)arrayOfQueries

5. To execute batch query execution with 

a. Array of queries as one parameters with question mark symbols in query (prepared statements)
b. Anaother array containing list of array elements to be substituted for each query in previous array.

It will be matched by index. 

Ex. First index of query array will be substituted with values of array in values array in the first index, likewise..

Use the following method:

-(void)executePreparedStatementWithQueryArray : (NSArray*)sqlQueries : (NSArray*)parameterArray
