# SqliteUtils
Sqlite helper functions

# Usuage

**Executing a single insert**
```
[SqliteUtils executeQuery:@"INSERT INTO test (name) VALUES (?);" databasePath:@"test.db" onPrepareDatabaseExecute:^BOOL(NSDateFormatter *formatter, sqlite3_stmt *statement) {
  return [SqliteUtils bindString:statement columnIndex:1 value:@"José"];
}];
```


**Executing a select**
```
NSMutableArray *results = [[NSMutableArray alloc] init];
    [SqliteUtils runSelectQuery:@"SELECT name FROM test;" databasePath:@"test.db" onDatabaseRowReady:^BOOL(NSDateFormatter *formatter, sqlite3_stmt *statement) {
        [results addObject:[SqliteUtils getString:statement columnIndex:0]];
        return NO;
    }];
```

**Executing a select with parameters**
```
NSMutableArray *results = [[NSMutableArray alloc] init];
[SqliteUtils runSelectQuery:@"SELECT name FROM test WHERE age = ?;" databasePath:@"test.db" onDatabaseRowReady:^BOOL(NSDateFormatter *formatter, sqlite3_stmt *statement) {
  [results addObject:[SqliteUtils getString:statement columnIndex:0]];
  return NO;
} onPrepareDatabaseRead:^BOOL(NSDateFormatter *formatter, sqlite3_stmt *statement) {
  return [SqliteUtils bindInt:statement columnIndex:1 value:@55];
}];
```

**Executing a multiple insert**
```
NSArray<NSString*> *names = @[
                                 @"João",
                                 @"Luís",
                                 @"Carlos"
                                 ];
[SqliteUtils executeMultipleQuerys:@"INSERT INTO test (name) VALUES (?);" numberOfQuerys:names.count databasePath:@"test.db" onPrepareMultipleDatabaseExecute:^BOOL(NSDateFormatter *formatter, sqlite3_stmt *statement, NSUInteger index) {
  return [SqliteUtils bindString:statement columnIndex:1 value:[names objectAtIndex:index]];
} checkLastRowId:^(int affectedRows, NSNumber *rowId, NSUInteger index) {
  if (affectedRows != 0) {
  NSLog(@"last row id %lu", (unsigned long)index);
  }
}];
```
