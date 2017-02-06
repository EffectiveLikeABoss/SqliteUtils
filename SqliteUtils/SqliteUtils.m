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

#import "SqliteUtils.h"

@implementation SqliteUtils

+(int)executeQuery:(NSString*)query databasePath:(NSString*)databasePath onPrepareDatabaseExecute:(OnPrepareDatabaseExecute)onPrepareDatabaseExecute{
    return [SqliteUtils executeQuery:query
                        databasePath:databasePath
            onPrepareDatabaseExecute:onPrepareDatabaseExecute
                      checkLastRowId:nil];
}

+(int)executeQuery:(NSString*)query databasePath:(NSString*)databasePath onPrepareDatabaseExecute:(OnPrepareDatabaseExecute)onPrepareDatabaseExecute checkLastRowId:(OnDatabaseExecuteNewRowId)onDatabaseExecuteNewRowId {

    int affectedRows=0;
    
    sqlite3 *sqlite3Database;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //this is the sqlite's format
    
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        
        sqlite3_stmt *compiledStatement;
        
        
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, [query UTF8String], -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            
            BOOL canExecute=YES;
            if (onPrepareDatabaseExecute) {
                canExecute=onPrepareDatabaseExecute(formatter, compiledStatement);
            }
            
            if (canExecute) {
                
                if (sqlite3_step(compiledStatement) != SQLITE_ERROR) {
                    // Keep the affected rows.
                    affectedRows = sqlite3_changes(sqlite3Database);
                    
                    if (onDatabaseExecuteNewRowId) {
                        sqlite_int64 lastRowId=sqlite3_last_insert_rowid(sqlite3Database);
                        onDatabaseExecuteNewRowId(affectedRows, [NSNumber numberWithLongLong:lastRowId]);
                    }
                    
                } else {
                    NSLog(@"executeQuery - DB Error sqlite3_step: %s", sqlite3_errmsg(sqlite3Database));
                }
            }
            
        } else {
            NSLog(@"executeQuery - DB Error: %s", sqlite3_errmsg(sqlite3Database));
        }
        
        
        sqlite3_finalize(compiledStatement);
    }
    
    
    sqlite3_close(sqlite3Database);
    
    return affectedRows;

}










+(int)executeMultipleQuerys:(NSString*)query numberOfQuerys:(NSUInteger)numberOfQuerys databasePath:(NSString*)databasePath onPrepareMultipleDatabaseExecute:(OnPrepareMultipleDatabaseExecute)onPrepareMultipleDatabaseExecute checkLastRowId:(OnMultipleDatabaseExecuteNewRowId)onMultipleDatabaseExecuteNewRowId{
    int totalAffectedRows=0;
    
    
    sqlite3 *sqlite3Database;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //this is the sqlite's format
    
    
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        
        sqlite3_stmt *compiledStatement = NULL;
        
        for (NSUInteger i=0; i<numberOfQuerys; ++i) {
            
            BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, [query UTF8String], -1, &compiledStatement, NULL);
            if(prepareStatementResult == SQLITE_OK) {
                
                BOOL canExecute=YES;
                if (onPrepareMultipleDatabaseExecute) {
                    canExecute=onPrepareMultipleDatabaseExecute(formatter, compiledStatement, i);
                }
                
                if (canExecute) {
                    
                    if (sqlite3_step(compiledStatement) != SQLITE_ERROR) {
                        
                        int affectedRows = sqlite3_changes(sqlite3Database);
                        totalAffectedRows += affectedRows;
                        
                        if (onMultipleDatabaseExecuteNewRowId) {
                            sqlite_int64 lastRowId=sqlite3_last_insert_rowid(sqlite3Database);
                            onMultipleDatabaseExecuteNewRowId(affectedRows, [NSNumber numberWithLongLong:lastRowId], i);
                        }
                        
                    } else {
                        
                        NSLog(@"executeMultipleQuerys - DB Error sqlite3_step: %s", sqlite3_errmsg(sqlite3Database));
                    }
                }
                
            } else {
                
                NSLog(@"executeMultipleQuerys - DB Error: %s", sqlite3_errmsg(sqlite3Database));
            }
            
            sqlite3_reset(compiledStatement);
            sqlite3_clear_bindings(compiledStatement);
        }
        
        if (compiledStatement != NULL) {
            
            sqlite3_finalize(compiledStatement);
        }
    }
    
    
    sqlite3_close(sqlite3Database);
    
    return totalAffectedRows;
}


+(void)runSelectQuery:(NSString*)query databasePath:(NSString*)databasePath onDatabaseRowReady:(OnDatabaseRowReady)onDatabaseRowReady onPrepareDatabaseRead:(OnPrepareDatabaseRead)onPrepareDatabaseRead{
    if (!onDatabaseRowReady) {
        return;
    }
    
    sqlite3 *sqlite3Database;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //this is the sqlite's format
    
    // Open the database.
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        sqlite3_stmt *compiledStatement;
        
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, [query UTF8String], -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            
            BOOL canExecute=YES;
            if (onPrepareDatabaseRead) {
                canExecute=onPrepareDatabaseRead(formatter, compiledStatement);
            }
            
            if (canExecute) {
                while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    if (onDatabaseRowReady(formatter, compiledStatement)) {
                        break;
                    }
                }
            }
            
        } else {
            NSLog(@"runSelectQuery - '%s'", sqlite3_errmsg(sqlite3Database));
        }
        
        sqlite3_finalize(compiledStatement);
    }
    
    sqlite3_close(sqlite3Database);
}

+(void)runSelectQuery:(NSString*)query databasePath:(NSString*)databasePath onDatabaseRowReady:(OnDatabaseRowReady)onDatabaseRowReady{
    [SqliteUtils runSelectQuery:query
                   databasePath:databasePath
             onDatabaseRowReady:onDatabaseRowReady
          onPrepareDatabaseRead:nil];
}




+(NSNumber*)getInt:(sqlite3_stmt*)statement columnIndex:(int)i{
    char *dbDataAsChars = (char *)sqlite3_column_text(statement, i);
    
    // If there are contents in the currenct column (field) then add them to the current row array.
    if (dbDataAsChars != NULL && sqlite3_column_type(statement, i) != SQLITE_NULL) {
        return [NSNumber numberWithInt: sqlite3_column_int(statement, i)];
    }
    return nil;
}

+(NSNumber*)getReal:(sqlite3_stmt*)statement columnIndex:(int)i{
    char *dbDataAsChars = (char *)sqlite3_column_text(statement, i);
    
    // If there are contents in the currenct column (field) then add them to the current row array.
    if (dbDataAsChars != NULL && sqlite3_column_type(statement, i) != SQLITE_NULL) {
        return [NSNumber numberWithDouble: sqlite3_column_double(statement, i)];
    }
    return nil;
}

+(NSString*)getString:(sqlite3_stmt*)statement columnIndex:(int)i{
    char *dbDataAsChars = (char *)sqlite3_column_text(statement, i);
    
    // If there are contents in the currenct column (field) then add them to the current row array.
    if (dbDataAsChars != NULL && sqlite3_column_type(statement, i) != SQLITE_NULL) {
        return [NSString stringWithUTF8String:dbDataAsChars];
    }
    return nil;
}

+(NSDate*)getDate:(sqlite3_stmt*)statement columnIndex:(int)i withFormatter:(NSDateFormatter*)formatter{
    char *dbDataAsChars = (char *)sqlite3_column_text(statement, i);
    
    // If there are contents in the currenct column (field) then add them to the current row array.
    if (dbDataAsChars != NULL && sqlite3_column_type(statement, i) != SQLITE_NULL) {
        return [formatter dateFromString:[NSString stringWithUTF8String:dbDataAsChars]];
    }
    return nil;
}



+(BOOL)bindInt:(sqlite3_stmt*)statement columnIndex:(int)i value:(NSNumber*)value{
    if (!value) {
        return (sqlite3_bind_null(statement, i) == SQLITE_OK);
    }
    return (sqlite3_bind_int(statement, i, value.intValue) == SQLITE_OK);
}

+(BOOL)bindReal:(sqlite3_stmt*)statement columnIndex:(int)i value:(NSNumber*)value{
    if (!value) {
        return (sqlite3_bind_null(statement, i) == SQLITE_OK);
    }
    return (sqlite3_bind_double(statement, i, value.doubleValue) == SQLITE_OK);
}

+(BOOL)bindString:(sqlite3_stmt*)statement columnIndex:(int)i value:(NSString*)value{
    if (!value) {
        return (sqlite3_bind_null(statement, i) == SQLITE_OK);
    }
    return (sqlite3_bind_text(statement, i, [value UTF8String], -1, NULL) == SQLITE_OK);
}

+(BOOL)bindDate:(sqlite3_stmt*)statement columnIndex:(int)i value:(NSDate*)value withFormatter:(NSDateFormatter*)formatter{
    if (!value) {
        return (sqlite3_bind_null(statement, i) == SQLITE_OK);
    }
    return (sqlite3_bind_text(statement, i, [[formatter stringFromDate:value] UTF8String], -1, NULL) == SQLITE_OK);
}



+(void)createDataBase:(NSString*)databasePath createStatement:(NSString*)statement{
    sqlite3 *database;
    int openDatabaseResult = sqlite3_open([databasePath UTF8String], &database);
    
    if(openDatabaseResult == SQLITE_OK) {
        const char *sqlStatement=[statement UTF8String];
        char *error;
        if(sqlite3_exec(database, sqlStatement, NULL, NULL, &error) != SQLITE_OK) {
            NSLog(@"createDataBase - error createDataBase '%s'", error);
        } else {
            NSLog(@"createDataBase - Creating database '%@'", databasePath);
        }
        
    } else {
        NSLog(@"createDataBase - Error creating database '%@'", databasePath);
    }
    sqlite3_close(database);
}

+(void)createDataBase:(NSString*)databasePath createStatements:(NSArray<NSString*>*)statements{
    sqlite3 *database;
    int openDatabaseResult = sqlite3_open([databasePath UTF8String], &database);
    
    if(openDatabaseResult == SQLITE_OK) {
        
        for (NSString *statement in statements) {
            const char *sqlStatement=[statement UTF8String];
            char *error;
            if(sqlite3_exec(database, sqlStatement, NULL, NULL, &error) != SQLITE_OK) {
                NSLog(@"createDataBase - error createDataBase '%s'", error);
                return;
            }
        }
        NSLog(@"createDataBase - Creating database '%@'", databasePath);
        
    } else {
        NSLog(@"createDataBase - Error creating database '%@'", databasePath);
    }
    sqlite3_close(database);
}

+(void)copyDatabase:(NSString*)dataBaseFileName intoDirectory:(NSString*)directory errorHandler:(void(^)(NSError *error))errorHandler{
    // Check if the database file exists in the documents directory.
    NSString *destinationPath = [directory stringByAppendingPathComponent:dataBaseFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // The database file does not exist in the documents directory, so copy it from the main bundle now.
        NSLog(@"copyDatabase - Copying database: %@", destinationPath);
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dataBaseFileName];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        // Check if any error occurred during copying
        if (error != nil && errorHandler) {
            errorHandler(error);
        }
    }
}

+(void)copyIntoDocumentsDirectoryDatabase:(NSString*)dataBaseFileName errorHandler:(void(^)(NSError *error))errorHandler{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    [SqliteUtils copyDatabase:dataBaseFileName intoDirectory:documentsDirectory errorHandler:errorHandler];
}

@end
