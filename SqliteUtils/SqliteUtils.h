//
//  This is free and unencumbered software released into the public domain.
//
//  Anyone is free to copy, modify, publish, use, compile, sell, or
//  distribute this software, either in source code form or as a compiled
//  binary, for any purpose, commercial or non-commercial, and by any
//  means.

//  In jurisdictions that recognize copyright laws, the author or authors
//  of this software dedicate any and all copyright interest in the
//  software to the public domain. We make this dedication for the benefit
//  of the public at large and to the detriment of our heirs and
//  successors. We intend this dedication to be an overt act of
//  relinquishment in perpetuity of all present and future rights to this
//  software under copyright law.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
//  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  For more information, please refer to <http://unlicense.org>
//
//  Created by Effective Like ABoss
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SqliteUtils : NSObject

/**
 * Block to be called when a database row is ready
 * @author David Costa Gonçalves
 *
 * @param statement sqlite statement
 * @param formatter an NSDateFormatter to be used to read a date from a database column
 * @return Return YES if the query can stop execution
 */
typedef BOOL (^OnDatabaseRowReady)(NSDateFormatter *formatter, sqlite3_stmt *statement);


/**
 * Block to be called for binding the parameters of the select sql query
 * @author David Costa Gonçalves
 *
 * @param statement sqlite statement
 * @param formatter an NSDateFormatter to be used to bind a date to a database column
 * @return Return NO if the query can stop execution if a error ocorred
 */
typedef BOOL (^OnPrepareDatabaseRead)(NSDateFormatter *formatter, sqlite3_stmt *statement);


/**
 * Block to be called for binding the parameters of the insert/update/delete sql query
 * @author David Costa Gonçalves
 *
 * @param statement sqlite statement
 * @param formatter an NSDateFormatter to be used to bind a date to a database column
 * @return Return NO if the query can stop execution if a error ocorred
 */
typedef BOOL (^OnPrepareDatabaseExecute)(NSDateFormatter *formatter, sqlite3_stmt *statement);


/**
 * Block to be called to retrieve the last inserted row id
 * @author David Costa Gonçalves
 *
 * @param affectedRows the number of affected rows
 * @param rowId the new row id
 */
typedef void (^OnDatabaseExecuteNewRowId)(int affectedRows, NSNumber *rowId);


/**
 * Block to be called for binding the parameters of the multiple insert/update/delete sql queryss
 * @author David Costa Gonçalves
 *
 * @param statement sqlite statement
 * @param formatter an NSDateFormatter to be used to bind a date to a database column
 * @param index the number of the query to execute
 * @return Return NO if the query can stop execution if a error ocorred
 */
// Return YES if the query can execute, NO if it an error ocorred and can't execute
typedef BOOL (^OnPrepareMultipleDatabaseExecute)(NSDateFormatter *formatter, sqlite3_stmt *statement, NSUInteger index);

/**
 * Block to be called to retrieve the last inserted row id
 * @author David Costa Gonçalves
 *
 * @param affectedRows the number of affected rows
 * @param rowId the new row id
 * @param index the number of the query to execute
 */
typedef void (^OnMultipleDatabaseExecuteNewRowId)(int affectedRows, NSNumber *rowId, NSUInteger index);


/**
 * Run a insert/delete/update query
 * Ex: INSERT INTO TEST (name) VALUES (?);
 * EX: DELETE FROM TEST WHERE id=?;
 *
 * @author David Costa Gonçalves
 *
 * @param query sql select query
 * @param databasePath database name and location
 * @param onPrepareDatabaseExecute block to be executed to bind the sql parameters to the query
 * @return the number of affected rows
 */
+(int)executeQuery:(NSString*)query databasePath:(NSString*)databasePath onPrepareDatabaseExecute:(OnPrepareDatabaseExecute)onPrepareDatabaseExecute;


/**
 * Run a insert query and returns last inserted row id generated
 * Ex: INSERT INTO TEST (name) VALUES (?);
 *
 * @author David Costa Gonçalves
 *
 * @param query sql select query
 * @param databasePath database name and location
 * @param onPrepareDatabaseExecute block to be executed to bind the sql parameters to the query
 * @param onDatabaseExecuteNewRowId block to be executed when a database row id is generated
 * @return the number of affected rows
 */
+(int)executeQuery:(NSString*)query databasePath:(NSString*)databasePath onPrepareDatabaseExecute:(OnPrepareDatabaseExecute)onPrepareDatabaseExecute checkLastRowId:(OnDatabaseExecuteNewRowId)onDatabaseExecuteNewRowId;


/**
 * Run a insert query and returns last inserted row id generated
 * Ex: INSERT INTO TEST (name) VALUES (?);
 *
 * @author David Costa Gonçalves
 *
 * @param query sql select query
 * @param numberOfQuerys the number of queries to execute
 * @param databasePath database name and location
 * @param onPrepareMultipleDatabaseExecute block to be executed to bind the sql parameters to a query
 * @param onMultipleDatabaseExecuteNewRowId block to be executed when a database row id is generated
 * @return the number of affected rows
 */
+(int)executeMultipleQuerys:(NSString*)query numberOfQuerys:(NSUInteger)numberOfQuerys databasePath:(NSString*)databasePath onPrepareMultipleDatabaseExecute:(OnPrepareMultipleDatabaseExecute)onPrepareMultipleDatabaseExecute checkLastRowId:(OnMultipleDatabaseExecuteNewRowId)onMultipleDatabaseExecuteNewRowId;


/**
 * Run a select query
 * Ex: SELECT * FROM test;
 *
 * @author David Costa Gonçalves
 *
 * @param query sql select query
 * @param databasePath database name and location
 * @param onDatabaseRowReady block to be executed when a a row is ready
 */
+(void)runSelectQuery:(NSString*)query databasePath:(NSString*)databasePath onDatabaseRowReady:(OnDatabaseRowReady)onDatabaseRowReady;

/**
 * Run a select query 
 * Ex: SELECT * FROM test;
 * Ex: SELECT * FROM test WHERE id=?;
 *
 * @author David Costa Gonçalves
 *
 * @param query sql select query
 * @param databasePath database name and location
 * @param onDatabaseRowReady block to be executed when a a row is ready
 * @param onPrepareDatabaseRead block to bind the sql parameters to the query
 */
+(void)runSelectQuery:(NSString*)query databasePath:(NSString*)databasePath onDatabaseRowReady:(OnDatabaseRowReady)onDatabaseRowReady onPrepareDatabaseRead:(OnPrepareDatabaseRead)onPrepareDatabaseRead;





/**
 * Reads an int value from a sqlite statement at the given index
 * @author David Costa Gonçalves
 *
 * @param statement sqlite statement
 * @param i column index starts at zero
 * @return The int value at the given index
 */
+(NSNumber*)getInt:(sqlite3_stmt*)statement columnIndex:(int)i;

/**
 * Reads an float value from a sqlite statement at the given index
 * @author David Costa Gonçalves
 *
 * @param statement sqlite statement
 * @param i column index starts at zero
 * @return The float value at the given index
 */
+(NSNumber*)getReal:(sqlite3_stmt*)statement columnIndex:(int)i;

/**
 * Reads an NSString value from a sqlite statement at the given index
 * @author David Costa Gonçalves
 *
 * @param statement sqlite statement
 * @param i column index starts at zero
 * @return The NSString value at the given index
 */
+(NSString*)getString:(sqlite3_stmt*)statement columnIndex:(int)i;

/**
 * Reads an NSDate value from a sqlite statement at the given index
 * @author David Costa Gonçalves
 *
 * @param statement sqlite statement
 * @param i column index starts at zero
 * @param formatter NSDateFormatter to create an NSDate from the database
 * @return The NSDate value at the given index
 */
+(NSDate*)getDate:(sqlite3_stmt*)statement columnIndex:(int)i withFormatter:(NSDateFormatter*)formatter;






/**
 * Binds an int value to a sqlite statement at the given index
 * @author David Costa Gonçalves
 *
 * @param statement sqlite statement
 * @param i column index starts at 1
 * @param value the value to bind
 * @return The operation success value
 */
+(BOOL)bindInt:(sqlite3_stmt*)statement columnIndex:(int)i value:(NSNumber*)value;

/**
 * Binds an float value to a sqlite statement at the given index
 * @author David Costa Gonçalves
 *
 * @param statement sqlite statement
 * @param i column index starts at 1
 * @param value the value to bind
 * @return The operation success value
 */
+(BOOL)bindReal:(sqlite3_stmt*)statement columnIndex:(int)i value:(NSNumber*)value;

/**
 * Binds an NSString value to a sqlite statement at the given index
 * @author David Costa Gonçalves
 *
 * @param statement sqlite statement
 * @param i column index starts at 1
 * @param value the value to bind
 * @return The operation success value
 */
+(BOOL)bindString:(sqlite3_stmt*)statement columnIndex:(int)i value:(NSString*)value;

/**
 * Binds an NSDate value to a sqlite statement at the given index
 * @author David Costa Gonçalves
 *
 * @param statement sqlite statement
 * @param i column index starts at 1
 * @param formatter NSDateFormatter to create an NSString from a NSDate
 * @param value the value to bind
 * @return The operation success value
 */
+(BOOL)bindDate:(sqlite3_stmt*)statement columnIndex:(int)i value:(NSDate*)value withFormatter:(NSDateFormatter*)formatter;






/**
 * Creates a new sqlitedatabase at given path name using the create statement
 * @author David Costa Gonçalves
 *
 * @param databasePath database name and location
 * @param statement sql statement to execute in the new database
 */
+(void)createDataBase:(NSString*)databasePath createStatement:(NSString*)statement;

/**
 * Creates a new sqlitedatabase at given path name using the create statements
 * @author David Costa Gonçalves
 *
 * @param databasePath database name and location
 * @param statements sql statements to execute in the new database
 */
+(void)createDataBase:(NSString*)databasePath createStatements:(NSArray<NSString*>*)statements;

/**
 * Copys a database from the application bundle into a new writable folder
 * @author David Costa Gonçalves
 *
 * @param dataBaseFileName the database name in the application resources
 * @param directory the directory to put the database copy
 * @param errorHandler can be nil, is executed if an error occurs
 */
+(void)copyDatabase:(NSString*)dataBaseFileName intoDirectory:(NSString*)directory errorHandler:(void(^)(NSError *error))errorHandler;

/**
 * Copys a database from the application bundle into the application documents directory
 * @author David Costa Gonçalves
 *
 * @param dataBaseFileName the database name in the application resources
 * @param errorHandler can be nil, is executed if an error occurs
 */
+(void)copyIntoDocumentsDirectoryDatabase:(NSString*)dataBaseFileName errorHandler:(void(^)(NSError *error))errorHandler;

@end
