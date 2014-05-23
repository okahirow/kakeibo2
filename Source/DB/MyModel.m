//
//  MyModel.m
//  kakeibo
//
//  Created by hiro on 11/03/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyModel.h"
#import "CommonAPI.h"
#import "GoogleCalender.h"


@implementation MyModel{
	NSDate* last_save_date;
}

- (id) init{
	if((self = [super init])){
		//Model作成
		[self init_model];
		last_save_date = [NSDate date];
		
		//初回起動時
		NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
		if([settings boolForKey:@"IS_FIRST_EXEC"] == true){
			[settings setBool:false forKey:@"IS_FIRST_EXEC"];
			
			//デフォルトのカテゴリを追加
			[self add_default_category];
		}
	}
	
	return self;
}


//■■　CoreData用　■■
@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;

static NSString *const MODEL_NAME = @"MyDB";
static NSString *const DB_NAME = @"MyDB.sqlite";


//アプリケーションのDocumentsディレクトリへのパスを返す
-(NSString*) applicationDocumentsDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


//NSManagedObjectContextをインスタンス化して返す
-(void) init_model{
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:MODEL_NAME ofType:@"mom"]];
    NSURL *storeURL = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:DB_NAME]];
    NSError *error = nil;
	
    // NSManagedObjectModel をインスタンス化
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	
    // NSPersistentStoreCoordinator をインスタンス化
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
	
    // NSManagedObjectContext をインスタンス化
    if (self.persistentStoreCoordinator != nil) {
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
}


//モデルを保存
-(void) save_model{
	NSError *error;
	if (managedObjectContext != nil) {
		if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Update to handle the error appropriately.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
		
		last_save_date = [NSDate date];
		
		//DB変更を通知する
		NSNotification *n = [NSNotification notificationWithName:@"DB_UPDATE" object:self];
		[[NSNotificationCenter defaultCenter] postNotification:n];
	}
}

//持っているデータが古いか調べる
-(BOOL) is_old_data:(NSDate*)data_date{
	NSComparisonResult ret = [last_save_date compare:data_date];
	if(ret == NSOrderedAscending || ret == NSOrderedSame){
		return NO;
	}
	else{
		return YES;
	}
}

//■■　カテゴリー用　■■
//カテゴリリストの取得
- (NSArray*) get_category_list_with_pred:(NSPredicate*)predicate{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBCategory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	
    NSArray *sortDescriptors;
    sortDescriptors = @[desc];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	// 取得条件の設定
    [fetchRequest setPredicate:predicate];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
						 initWithFetchRequest:fetchRequest
						 managedObjectContext:[self managedObjectContext]
						 sectionNameKeyPath:nil
						 cacheName:nil];
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}

- (NSArray*) get_show_income_category_list{
	NSPredicate* pred = [NSPredicate predicateWithFormat:@"diff_type != %@ And cur.is_income == YES", @"del"];
	
	return [self get_category_list_with_pred:pred];
}

- (NSArray*) get_show_outcome_category_list{
	NSPredicate* pred = [NSPredicate predicateWithFormat:@"diff_type != %@ And cur.is_income == NO", @"del"];
	
	return [self get_category_list_with_pred:pred];
}

//カテゴリーを追加(tmpで)
-(void) add_category2:(Category_Data*)data{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	int next_tmp_cat_id = [settings integerForKey:@"NEXT_TMP_CAT_ID"];
	
	int show_category_num;
	if(data.is_income){
		show_category_num = [[self get_show_income_category_list] count];
	}
	else{
		show_category_num = [[self get_show_outcome_category_list] count];
	}
	
	DBCategory_Data* cur_data = [NSEntityDescription insertNewObjectForEntityForName:@"DBCategory_Data" inManagedObjectContext:self.managedObjectContext];
	[cur_data set_data:data];
	
	DBCategory_Data* org_data = [NSEntityDescription insertNewObjectForEntityForName:@"DBCategory_Data" inManagedObjectContext:self.managedObjectContext];
	
	DBCategory* category = [NSEntityDescription insertNewObjectForEntityForName:@"DBCategory" inManagedObjectContext:self.managedObjectContext];
	category.cat_id = next_tmp_cat_id;
	category.index = show_category_num;
	category.diff_type = @"add";
	category.cur = cur_data;
	category.org = org_data;
	
	[settings setInteger:next_tmp_cat_id - 1 forKey:@"NEXT_TMP_CAT_ID"];
	
	[self save_model];
}

//カテゴリーを追加(tmpではなく完全に追加)
-(void) add_category2_actuary:(Category_Data*)data cat_id:(NSInteger)cat_id index:(NSInteger)index{
	DBCategory_Data* cur_data = [NSEntityDescription insertNewObjectForEntityForName:@"DBCategory_Data" inManagedObjectContext:self.managedObjectContext];
	[cur_data set_data:data];
	
	DBCategory_Data* org_data = [NSEntityDescription insertNewObjectForEntityForName:@"DBCategory_Data" inManagedObjectContext:self.managedObjectContext];
	[org_data set_data:data];
	
	DBCategory* category = [NSEntityDescription insertNewObjectForEntityForName:@"DBCategory" inManagedObjectContext:self.managedObjectContext];
	category.cat_id = cat_id;
	category.index = index;
	category.diff_type = @"";
	category.cur = cur_data;
	category.org = org_data;
	
	[self save_model];
}

//カテゴリーの削除
- (void) del_category2:(DBCategory*)target{
	NSInteger cat_id = target.cat_id;
	
	//tmpIDの場合
	if(cat_id < 0){
		//削除する
		[self.managedObjectContext deleteObject:target];
	}
	//本IDの場合
	else{
		target.index = -1;
		target.diff_type = @"del";
		target.cur.name = @"";
	}
	
	//並び順をつけなおす
	NSArray* show_category_list;
	if(target.cur.is_income == YES){
		show_category_list = [self get_show_income_category_list];
	}
	else{
		show_category_list = [self get_show_outcome_category_list];
	}
	for(NSInteger i = 0; i < [show_category_list count]; i++){
		DBCategory* category = show_category_list[i];
		
		category.index = i;
	}
	
	[self save_model];
}

//カテゴリーの並び替え
-(void) swap_category2:(BOOL)is_income from_index:(NSInteger)from_index to_index:(NSInteger)to_index{
	NSArray* show_category_list;
	if(is_income == YES){
		show_category_list = [self get_show_income_category_list];
	}
	else{
		show_category_list = [self get_show_outcome_category_list];
	}
	
	if(from_index >= [show_category_list count] || to_index >= [show_category_list count]){
		return;
	}
	
	if(from_index == to_index){
		return;
	}
	
	DBCategory* from_category = show_category_list[from_index];
	from_category.index = to_index;
	
	if(from_index > to_index){
		for(NSInteger i = to_index; i < from_index; i++){
			DBCategory* category = show_category_list[i];
			category.index = category.index + 1;
		}
	}
	else{
		for(NSInteger i = from_index + 1; i <= to_index; i++){
			DBCategory* category = show_category_list[i];
			category.index = category.index - 1;
		}
	}
	
	[g_model_ save_model];
}

//同名カテゴリがー存在するか確認する
- (BOOL) is_exist_category2:(NSString*)name without:(DBCategory*)without{
	NSPredicate* pred;
	
	if(without == nil){
		pred = [NSPredicate predicateWithFormat:@"diff_type != %@ And cur.name == %@", @"del", name];
	}
	else{
		pred = [NSPredicate predicateWithFormat:@"diff_type != %@ And cur.name == %@ And cat_id != %d", @"del", name, without.cat_id];
	}
	
	if([[self get_category_list_with_pred:pred] count] > 0){
		return YES;
	}
	else{
		return NO;
	}
}




//--------- old ----------------
//全カテゴリーの数
-(NSInteger) get_all_category_num{
	return [[self get_all_category_list] count];
}


//表示するカテゴリーの数
-(NSInteger) get_show_category_num{
	return [[self get_show_category_list] count];	
}


//デフォルトのカテゴリを追加
-(void) add_default_category{
	if([self get_all_category_num] == 0){
		Category_Data* data = [[Category_Data alloc] init];
		data.name = NSLocalizedString(@"STR-106", nil);
		data.is_income = NO;
		data.is_sepalator = NO;
		[self add_category2_actuary:data cat_id:0 index:0];
		
		data = [[Category_Data alloc] init];
		data.name = NSLocalizedString(@"STR-107", nil);
		data.is_income = NO;
		data.is_sepalator = NO;
		[self add_category2_actuary:data cat_id:1 index:1];
		
		data = [[Category_Data alloc] init];
		data.name = NSLocalizedString(@"STR-108", nil);
		data.is_income = NO;
		data.is_sepalator = NO;
		[self add_category2_actuary:data cat_id:2 index:2];
		
		data = [[Category_Data alloc] init];
		data.name = NSLocalizedString(@"STR-109", nil);
		data.is_income = NO;
		data.is_sepalator = NO;
		[self add_category2_actuary:data cat_id:3 index:3];
		
		data = [[Category_Data alloc] init];
		data.name = NSLocalizedString(@"STR-110", nil);
		data.is_income = NO;
		data.is_sepalator = NO;
		[self add_category2_actuary:data cat_id:4 index:4];
		
		data = [[Category_Data alloc] init];
		data.name = NSLocalizedString(@"STR-111", nil);
		data.is_income = NO;
		data.is_sepalator = NO;
		[self add_category2_actuary:data cat_id:5 index:5];
	}
}


//全カテゴリーのリストを取得
-(NSArray*) get_all_category_list{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBCategory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	
    NSArray *sortDescriptors;
    sortDescriptors = @[desc];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                          initWithFetchRequest:fetchRequest
                          managedObjectContext:[self managedObjectContext]
                          sectionNameKeyPath:nil
                          cacheName:nil];  
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}



//表示するカテゴリーのリストを取得
-(NSArray*) get_show_category_list{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBCategory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	
    NSArray *sortDescriptors;
    sortDescriptors = @[desc];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"diff_type != %@", @"del"];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                          initWithFetchRequest:fetchRequest
                          managedObjectContext:[self managedObjectContext]
                          sectionNameKeyPath:nil
                          cacheName:nil];  
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}


//指定したDiffTypeのカテゴリーのリストを取得
- (NSArray*) get_category_list_with_diff_type:(NSString*)diff_type{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBCategory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	
    NSArray *sortDescriptors;
    sortDescriptors = @[desc];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"diff_type == %@", diff_type];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                          initWithFetchRequest:fetchRequest
                          managedObjectContext:[self managedObjectContext]
                          sectionNameKeyPath:nil
                          cacheName:nil];  
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}

//IDでカテゴリを取得
- (DBCategory*) get_category_with_id:(NSInteger) cat_id{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBCategory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	
    NSArray *sortDescriptors;
    sortDescriptors = @[desc];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"cat_id == %d", cat_id];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                          initWithFetchRequest:fetchRequest
                          managedObjectContext:[self managedObjectContext]
                          sectionNameKeyPath:nil
                          cacheName:nil];  
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	if([resultsController.fetchedObjects count] > 0){
		return (resultsController.fetchedObjects)[0];
	}
	else{
		return nil;
	}
}

//カテゴリーを追加
-(void) add_category:(NSString*)name{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	int next_tmp_cat_id = [settings integerForKey:@"NEXT_TMP_CAT_ID"];
	
	int show_category_num = [self get_show_category_num];
	
	DBCategory* category = [NSEntityDescription insertNewObjectForEntityForName:@"DBCategory" inManagedObjectContext:self.managedObjectContext];
	[category setValue:@(next_tmp_cat_id) forKey:@"cat_id"];
	[category setValue:@(show_category_num) forKey:@"index"];
	[category setValue:@"add" forKey:@"diff_type"];
	[category setValue:@"" forKey:@"org.name"];
	[category setValue:name forKey:@"cur.name"];

	[settings setInteger:next_tmp_cat_id - 1 forKey:@"NEXT_TMP_CAT_ID"];
		
	[self save_model];
}


//カテゴリーを追加(tmpではなく完全に追加)
- (void) add_category_actuary:(NSString*)name cat_id:(NSInteger)cat_id index:(NSInteger)index{
	DBCategory_Data* cur_data = [NSEntityDescription insertNewObjectForEntityForName:@"DBCategory_Data" inManagedObjectContext:self.managedObjectContext];
	cur_data.name = name;
	
	DBCategory_Data* org_data = [NSEntityDescription insertNewObjectForEntityForName:@"DBCategory_Data" inManagedObjectContext:self.managedObjectContext];
	org_data.name = name;
	
	DBCategory* category = [NSEntityDescription insertNewObjectForEntityForName:@"DBCategory" inManagedObjectContext:self.managedObjectContext];
	category.cat_id = cat_id;
	category.index = index;
	category.diff_type = @"";
	
	category.cur = cur_data;
	category.org = org_data;
	
	[self save_model];
}


//カテゴリーの並び替え
-(void) swap_category:(NSInteger)from_index to_index:(NSInteger)to_index{
	NSArray* show_category_list = [self get_show_category_list];
	
	if(from_index >= [show_category_list count] || to_index >= [show_category_list count]){
		return;
	}
	
	if(from_index == to_index){
		return;
	}
	
	DBCategory* from_category = show_category_list[from_index];
	from_category.index = to_index;
	
	if(from_index > to_index){
		for(NSInteger i = to_index; i < from_index; i++){
			DBCategory* category = show_category_list[i];
			category.index = category.index + 1;
		}
	}
	else{
		for(NSInteger i = from_index + 1; i <= to_index; i++){
			DBCategory* category = show_category_list[i];
			category.index = category.index - 1;
		}		
	}
	
	[g_model_ save_model];
}


//カテゴリーの削除
- (void) del_category:(DBCategory*)target{
	NSInteger cat_id = target.cat_id;
	
	//tmpIDの場合
	if(cat_id < 0){
		//削除する
		[self.managedObjectContext deleteObject:target];
	}
	//本IDの場合
	else{
		target.index = -1;
		target.diff_type = @"del";
		target.cur.name = @"";
	}
	
	//並び順をつけなおす
	NSArray* show_category_list = [self get_show_category_list];
	for(NSInteger i = 0; i < [show_category_list count]; i++){
		DBCategory* category = show_category_list[i];
		
		category.index = i;
	}	
	
	[self save_model];
}


//カテゴリを本当に削除
- (void) del_category_actuary:(DBCategory*)target{
	[self.managedObjectContext deleteObject:target];
	[self save_model];
}


//全カテゴリーの削除
- (void) del_all_category_actuary{
	NSArray* all_category_list = [self get_all_category_list];
	
	for(NSInteger i = 0; i < [all_category_list count]; i ++){		
		[self.managedObjectContext deleteObject:all_category_list[i]];
	}
	
	[self save_model];
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	[settings setInteger:-1 forKey:@"NEXT_TMP_CAT_ID"];
}

//同名カテゴリがー存在するか確認する
- (bool) is_exist_category:(NSString*) name{
	NSArray* category_list = [self get_show_category_list];
	
	for(int i=0; i<[category_list count]; i++){
		DBCategory* category = category_list[i];
		
		if([category.cur.name isEqualToString:name] == true){
			return true;
		}
	}
	
	return false;
}


//■■　履歴用　■■
- (void) add_history2:(History_Data*)data{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	int next_tmp_his_id = [settings integerForKey:@"NEXT_TMP_HIS_ID"];
	
	DBHistory_Data* cur_data = [NSEntityDescription insertNewObjectForEntityForName:@"DBHistory_Data" inManagedObjectContext:self.managedObjectContext];
	[cur_data set_data:data];
	
	DBHistory_Data* org_data = [NSEntityDescription insertNewObjectForEntityForName:@"DBHistory_Data" inManagedObjectContext:self.managedObjectContext];
	
	DBHistory* history = [NSEntityDescription insertNewObjectForEntityForName:@"DBHistory" inManagedObjectContext:self.managedObjectContext];
	history.diff_type = @"add";
	history.his_id = next_tmp_his_id;
	history.cur = cur_data;
	history.org = org_data;
	
	[settings setInteger:next_tmp_his_id - 1 forKey:@"NEXT_TMP_HIS_ID"];
	
	[self save_model];
	
	
	GoogleCalender* cal = [GoogleCalender shared_obj];
	[cal add_history:data];
}

- (void) add_history3:(History_Data*)data{
	//通常イベント
	if(data.period.type == ONE_DAY){
		DBEvent_Normal* db_event = [NSEntityDescription insertNewObjectForEntityForName:@"DBEvent_Normal" inManagedObjectContext:self.managedObjectContext];

		db_event.date = data.period.start_date;

		db_event.category = data.category;
		db_event.val = data.val;
		db_event.person = data.person;
		
		db_event.eTag = nil;
		db_event.html_link = nil;
		db_event.memo = data.memo;
		
		db_event.sync_status = @"tmp_added";
		db_event.event_status = @"confirmed";
		
		db_event.identifier = nil;
		
		db_event.last_update = [NSDate date];
	}
	//繰り返しイベント
	else{
		DBEvent_Recurrence* db_event = [NSEntityDescription insertNewObjectForEntityForName:@"DBEvent_Recurrence" inManagedObjectContext:self.managedObjectContext];
		
		db_event.date = data.period.start_date;
		
		db_event.category = data.category;
		db_event.val = data.val;
		db_event.person = data.person;
		
		db_event.eTag = nil;
		db_event.html_link = nil;
		db_event.memo = data.memo;
		
		db_event.sync_status = @"tmp_added";
		db_event.event_status = @"confirmed";
		
		db_event.identifier = nil;
		
		db_event.last_update = [NSDate date];
		
		db_event.recurrence = [data recurrence_string];
		
		[db_event parse_recurrence:self.managedObjectContext];
	}
	
	[self save_model];
}




//--------- old ----------------
- (NSInteger) get_all_history_num{
	return [[self get_all_history_list] count];
}


- (NSInteger) get_show_history_num{
	return [[self get_show_history_list] count];
}


- (NSArray*) get_all_history_list{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBHistory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"year_cur" ascending:NO];
	NSSortDescriptor *desc2;
    desc2 = [[NSSortDescriptor alloc] initWithKey:@"month_cur" ascending:NO];
	NSSortDescriptor *desc3;
    desc3 = [[NSSortDescriptor alloc] initWithKey:@"day_cur" ascending:NO];
	
    NSArray *sortDescriptors;
    sortDescriptors = @[desc1, desc2, desc3];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                          initWithFetchRequest:fetchRequest
                          managedObjectContext:[self managedObjectContext]
                          sectionNameKeyPath:nil
                          cacheName:nil];  
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}


- (NSArray*) get_show_history_list{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBHistory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"year_cur" ascending:NO];
	NSSortDescriptor *desc2;
    desc2 = [[NSSortDescriptor alloc] initWithKey:@"month_cur" ascending:NO];
	NSSortDescriptor *desc3;
    desc3 = [[NSSortDescriptor alloc] initWithKey:@"day_cur" ascending:NO];
	
    NSArray *sortDescriptors;
    sortDescriptors = @[desc1, desc2, desc3];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"diff_type != %@", @"del"];	
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                          initWithFetchRequest:fetchRequest
                          managedObjectContext:[self managedObjectContext]
                          sectionNameKeyPath:nil
                          cacheName:nil];  
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}


- (NSArray*) get_history_list_with_diff_type:(NSString*)diff_type{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBHistory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"year_cur" ascending:NO];
	NSSortDescriptor *desc2;
    desc2 = [[NSSortDescriptor alloc] initWithKey:@"month_cur" ascending:NO];
	NSSortDescriptor *desc3;
    desc3 = [[NSSortDescriptor alloc] initWithKey:@"day_cur" ascending:NO];
	
    NSArray *sortDescriptors;
    sortDescriptors = @[desc1, desc2, desc3];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"diff_type == %@", diff_type];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                          initWithFetchRequest:fetchRequest
                          managedObjectContext:[self managedObjectContext]
                          sectionNameKeyPath:nil
                          cacheName:nil];  
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}


- (DBHistory*) get_history_with_id:(NSInteger) his_id{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBHistory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"his_id == %d", his_id];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                          initWithFetchRequest:fetchRequest
                          managedObjectContext:[self managedObjectContext]
                          sectionNameKeyPath:nil
                          cacheName:nil];  
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	if([resultsController.fetchedObjects count] > 0){
		return (resultsController.fetchedObjects)[0];
	}
	else{
		return nil;
	}
}


- (NSArray*) get_history_list_with_pred:(NSPredicate*)predicate{
	//NSLog(@"get_history_list_with_pred:%@", predicate);
	
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBHistory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"year_cur" ascending:NO];
	NSSortDescriptor *desc2;
    desc2 = [[NSSortDescriptor alloc] initWithKey:@"month_cur" ascending:NO];
	NSSortDescriptor *desc3;
    desc3 = [[NSSortDescriptor alloc] initWithKey:@"day_cur" ascending:NO];
		
    NSArray *sortDescriptors;
    sortDescriptors = @[desc1, desc2, desc3];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	// 取得条件の設定
    [fetchRequest setPredicate:predicate];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                          initWithFetchRequest:fetchRequest
                          managedObjectContext:[self managedObjectContext]
                          sectionNameKeyPath:nil
                          cacheName:nil];  
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}

- (NSArray*) get_history_list_with_pred_cat_order:(NSPredicate*)predicate{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBHistory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"category_cur" ascending:YES];
	
    NSArray *sortDescriptors;
    sortDescriptors = @[desc1];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	// 取得条件の設定
    [fetchRequest setPredicate:predicate];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                          initWithFetchRequest:fetchRequest
                          managedObjectContext:[self managedObjectContext]
                          sectionNameKeyPath:nil
                          cacheName:nil];  
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}


- (void) add_history:(NSInteger)year month:(NSInteger)month day:(NSInteger)day category:(NSString*)category val:(NSInteger)val memo:(NSString*)memo{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	int next_tmp_his_id = [settings integerForKey:@"NEXT_TMP_HIS_ID"];
		
	DBHistory* history = [NSEntityDescription insertNewObjectForEntityForName:@"DBHistory" inManagedObjectContext:self.managedObjectContext];
	[history setValue:@"add" forKey:@"diff_type"];
	[history setValue:@(next_tmp_his_id) forKey:@"his_id"];
	
	[history setValue:@0 forKey:@"year_org"];
	[history setValue:@(year) forKey:@"year_cur"];
	[history setValue:@0 forKey:@"month_org"];
	[history setValue:@(month) forKey:@"month_cur"];
	[history setValue:@0 forKey:@"day_org"];
	[history setValue:@(day) forKey:@"day_cur"];
	[history setValue:@"" forKey:@"category_org"];
	[history setValue:category forKey:@"category_cur"];
	[history setValue:@0 forKey:@"val_org"];
	[history setValue:@(val) forKey:@"val_cur"];
	[history setValue:@"" forKey:@"memo_org"];
	[history setValue:memo forKey:@"memo_cur"];
	
	[settings setInteger:next_tmp_his_id - 1 forKey:@"NEXT_TMP_HIS_ID"];
	
	[self save_model];
}


- (void) add_history_actuary:(NSInteger)his_id year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day category:(NSString*)category val:(NSInteger)val memo:(NSString*)memo{	
	DBHistory* history = [NSEntityDescription insertNewObjectForEntityForName:@"DBHistory" inManagedObjectContext:self.managedObjectContext];
	[history setValue:@"" forKey:@"diff_type"];
	[history setValue:@(his_id) forKey:@"his_id"];
	
	[history setValue:@(year) forKey:@"year_org"];
	[history setValue:@(year) forKey:@"year_cur"];
	[history setValue:@(month) forKey:@"month_org"];
	[history setValue:@(month) forKey:@"month_cur"];
	[history setValue:@(day) forKey:@"day_org"];
	[history setValue:@(day) forKey:@"day_cur"];
	[history setValue:category forKey:@"category_org"];
	[history setValue:category forKey:@"category_cur"];
	[history setValue:@(val) forKey:@"val_org"];
	[history setValue:@(val) forKey:@"val_cur"];
	[history setValue:memo forKey:@"memo_org"];
	[history setValue:memo forKey:@"memo_cur"];
	
	[self save_model];
}


- (void) del_history:(DBHistory*)target{
	NSInteger his_id = target.his_id;
	
	//tmpIDの場合
	if(his_id < 0){
		//削除する
		[self.managedObjectContext deleteObject:target];
	}
	//本IDの場合
	else{
		target.diff_type = @"del";
		target.cur.year = 0;
		target.cur.month = 0;
		target.cur.day = 0;
		target.cur.category = @"";
		target.cur.val = 0;
		target.cur.memo = @"";
	}
	
	[self save_model];
}


- (void) del_history_actuary:(DBHistory*)target{
	[self.managedObjectContext deleteObject:target];
	[self save_model];
}


- (void) del_all_history_actuary{
	NSArray* all_history_list = [self get_all_history_list];
	
	for(NSInteger i = 0; i < [all_history_list count]; i ++){		
		[self.managedObjectContext deleteObject:all_history_list[i]];
	}
	
	[self save_model];
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	[settings setInteger:-1 forKey:@"NEXT_TMP_HIS_ID"];
}


//■■　カスタム集計方法用　■■
//全カスタム集計方法の数
-(NSInteger) get_all_custom_ana_num{
	return [[self get_all_custom_ana_list] count];	
}


//表示するカスタム集計方法の数
-(NSInteger) get_show_custom_ana_num{
	return [[self get_show_custom_ana_list] count];	
}


//全カスタム集計方法のリストを取得
-(NSArray*) get_all_custom_ana_list{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBCustomAna" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	
    NSArray *sortDescriptors;
    sortDescriptors = @[desc];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                          initWithFetchRequest:fetchRequest
                          managedObjectContext:[self managedObjectContext]
                          sectionNameKeyPath:nil
                          cacheName:nil];  
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}



//表示するカスタム集計方法のリストを取得
-(NSArray*) get_show_custom_ana_list{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBCustomAna" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	
    NSArray *sortDescriptors;
    sortDescriptors = @[desc];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"diff_type != %@", @"del"];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                          initWithFetchRequest:fetchRequest
                          managedObjectContext:[self managedObjectContext]
                          sectionNameKeyPath:nil
                          cacheName:nil];  
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}


//使用するカスタム集計方法のリストを取得
-(NSArray*) get_use_custom_ana_list{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBCustomAna" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	
    NSArray *sortDescriptors;
    sortDescriptors = @[desc];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"is_show == %d And diff_type != %@", TRUE, @"del"];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                          initWithFetchRequest:fetchRequest
                          managedObjectContext:[self managedObjectContext]
                          sectionNameKeyPath:nil
                          cacheName:nil];  
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}


//指定したDiffTypeのカスタム集計方法のリストを取得
- (NSArray*) get_custom_ana_list_with_diff_type:(NSString*)diff_type{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBCustomAna" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	
    NSArray *sortDescriptors;
    sortDescriptors = @[desc];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"diff_type == %@", diff_type];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                          initWithFetchRequest:fetchRequest
                          managedObjectContext:[self managedObjectContext]
                          sectionNameKeyPath:nil
                          cacheName:nil];  
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}

//IDでカテゴリを取得
- (DBCustomAna*) get_custom_ana_with_id:(NSInteger) ana_id{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBCustomAna" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	
    NSArray *sortDescriptors;
    sortDescriptors = @[desc];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"ana_id == %d", ana_id];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                          initWithFetchRequest:fetchRequest
                          managedObjectContext:[self managedObjectContext]
                          sectionNameKeyPath:nil
                          cacheName:nil];  
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	if([resultsController.fetchedObjects count] > 0){
		return (resultsController.fetchedObjects)[0];
	}
	else{
		return nil;
	}
}


//カスタム集計方法を追加
-(void) add_custom_ana:(NSString*)name formula:(NSString*)formula unit:(NSString*)unit is_show:(BOOL)is_show{
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	int next_tmp_ana_id = [settings integerForKey:@"NEXT_TMP_ANA_ID"];
	
	int show_custom_ana_num = [self get_show_custom_ana_num];
	
	DBCustomAna* custom_ana = [NSEntityDescription insertNewObjectForEntityForName:@"DBCustomAna" inManagedObjectContext:self.managedObjectContext];
	[custom_ana setValue:@(next_tmp_ana_id) forKey:@"ana_id"];
	[custom_ana setValue:@(show_custom_ana_num) forKey:@"index"];
	[custom_ana setValue:@"add" forKey:@"diff_type"];
	[custom_ana setValue:@"" forKey:@"org.name"];
	[custom_ana setValue:name forKey:@"cur.name"];
	[custom_ana setValue:@"" forKey:@"formula_org"];
	[custom_ana setValue:formula forKey:@"formula_cur"];
	[custom_ana setValue:@"" forKey:@"unit_org"];
	[custom_ana setValue:unit forKey:@"unit_cur"];
	[custom_ana setValue:@(is_show) forKey:@"is_show"];
	
	[settings setInteger:next_tmp_ana_id - 1 forKey:@"NEXT_TMP_ANA_ID"];
	
	[self save_model];
}


//カスタム集計方法を追加(tmpではなく完全に追加)
- (void) add_custom_ana_actuary:(NSString*)name formula:(NSString*)formula unit:(NSString*)unit is_show:(BOOL)is_show ana_id:(NSInteger)ana_id index:(NSInteger)index{	
	DBCustomAna* custom_ana = [NSEntityDescription insertNewObjectForEntityForName:@"DBCustomAna" inManagedObjectContext:self.managedObjectContext];
	[custom_ana setValue:@(ana_id) forKey:@"ana_id"];
	[custom_ana setValue:@(index) forKey:@"index"];
	[custom_ana setValue:@"" forKey:@"diff_type"];
	[custom_ana setValue:name forKey:@"org.name"];
	[custom_ana setValue:name  forKey:@"cur.name"];
	[custom_ana setValue:formula forKey:@"formula_org"];
	[custom_ana setValue:formula forKey:@"formula_cur"];
	[custom_ana setValue:unit forKey:@"unit_org"];
	[custom_ana setValue:unit forKey:@"unit_cur"];
	[custom_ana setValue:@(is_show) forKey:@"is_show"];
	
	[self save_model];
}


//カスタム集計方法の並び替え
-(void) swap_custom_ana:(NSInteger)from_index to_index:(NSInteger)to_index{
	NSArray* show_custom_ana_list = [self get_show_custom_ana_list];
	
	if(from_index >= [show_custom_ana_list count] || to_index >= [show_custom_ana_list count]){
		return;
	}
	
	if(from_index == to_index){
		return;
	}
	
	DBCustomAna* from_custom_ana = show_custom_ana_list[from_index];
	from_custom_ana.index = to_index;
	
	if(from_index > to_index){
		for(NSInteger i = to_index; i < from_index; i++){
			DBCustomAna* custom_ana = show_custom_ana_list[i];
			custom_ana.index = custom_ana.index + 1;
		}
	}
	else{
		for(NSInteger i = from_index + 1; i <= to_index; i++){
			DBCustomAna* custom_ana = show_custom_ana_list[i];
			custom_ana.index = custom_ana.index - 1;
		}		
	}
	
	[g_model_ save_model];
}


//カスタム集計方法の削除
- (void) del_custom_ana:(DBCustomAna*)target{
	NSInteger ana_id = target.ana_id;
	
	//tmpIDの場合
	if(ana_id < 0){
		//削除する
		[self.managedObjectContext deleteObject:target];
	}
	//本IDの場合
	else{
		target.index = -1;
		target.diff_type = @"del";
		target.cur.name = @"";
	}
	
	//並び順をつけなおす
	NSArray* show_custom_ana_list = [self get_show_custom_ana_list];
	for(NSInteger i = 0; i < [show_custom_ana_list count]; i++){
		DBCustomAna* custom_ana = show_custom_ana_list[i];
		
		custom_ana.index = i;
	}	
	
	[self save_model];
}


//カテゴリを本当に削除
- (void) del_custom_ana_actuary:(DBCustomAna*)target{
	[self.managedObjectContext deleteObject:target];
	[self save_model];
}


//全カスタム集計方法の削除
- (void) del_all_custom_ana_actuary{
	NSArray* all_custom_ana_list = [self get_all_custom_ana_list];
	
	for(NSInteger i = 0; i < [all_custom_ana_list count]; i ++){		
		[self.managedObjectContext deleteObject:all_custom_ana_list[i]];
	}
	
	[self save_model];
	
	NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
	[settings setInteger:-1 forKey:@"NEXT_TMP_ANA_ID"];
}



//イベント用
- (void) add_event:(GDataEntryCalendarEvent*)event{
/*
	NSString* end = [[times[0] endTime] stringValue];
	GDataRecurrence* rec = [event recurrence];
	NSString* recurrence = [[event recurrence] stringValue];
	GDataOriginalEvent* org = [event originalEvent];
	NSString* url = [org href];
	BOOL is_deleted = [event isDeleted];
	
	NSString* identifier = [event identifier];
	NSURL* edit_link = [[event editLink] URL];
	NSURL* feed_link = [[event feedLink] URL];
	NSString* xml = [[event XMLDocument].rootElement XMLString];
	NSLog(@"%@\n\n", xml);
	
	GDataEventStatus* status = [event eventStatus];
	if([[status stringValue] isEqualToString:kGDataEventStatusCanceled] == YES){
		//削除されたイベント
	}
	
	if(org != nil){
		//[self.service fetchEntryWithURL:[NSURL URLWithString:url] delegate:self didFinishSelector:@selector(did_get_org_event:entry:error:)];
	}


	//@property (nonatomic, retain) NSSet *recurrence_exceptions;
	//@property (nonatomic, retain) DBEvent *org_event;
*/
	DBEvent* db_event;
	
	NSString* title = [[event title] stringValue];
	NSArray* title_elems = [title componentsSeparatedByString:@"@"];
	if([title_elems count] < 2){
		return;
	}
	
	GDataRecurrence* recu = [event recurrence];
	GDataOriginalEvent* org = [event originalEvent];
	
	//繰り返しイベント
	if(recu != nil){
		DBEvent_Recurrence* tmp_db_event = [NSEntityDescription insertNewObjectForEntityForName:@"DBEvent_Recurrence" inManagedObjectContext:self.managedObjectContext];
		
		tmp_db_event.recurrence = [recu stringValue];
		
		BOOL ret = [tmp_db_event parse_recurrence:self.managedObjectContext];
		if(ret == NO){
			[self.managedObjectContext deleteObject:tmp_db_event];
			return;
		}
		
		db_event = tmp_db_event;
	}
	else{
		//繰り返しの例外
		if(org != nil){
			DBEvent_Exception* tmp_db_event = [NSEntityDescription insertNewObjectForEntityForName:@"DBEvent_Exception" inManagedObjectContext:self.managedObjectContext];
			
			NSString* org_id = [org originalID];
			DBEvent_Recurrence* org_event = [self get_event_recurrence:org_id];
			if(org_event != nil){
				tmp_db_event.org_event = org_event;
			}
			else{
				//元の繰り返しイベントが削除されているので、追加しない。
				[self.managedObjectContext deleteObject:tmp_db_event];
				
				return;
			}
			
			tmp_db_event.org_date = [[[org originalStartTime] startTime] date];
			
			db_event = tmp_db_event;
		}
		//通常イベント
		else{
			DBEvent_Normal* tmp_db_event = [NSEntityDescription insertNewObjectForEntityForName:@"DBEvent_Normal" inManagedObjectContext:self.managedObjectContext];
			
			db_event = tmp_db_event;
		}
		
		NSArray* times = [event times];
		if([times count] > 0){
			GDataWhen* when = times[0];
			GDataDateTime* time = [when startTime];
			db_event.date = [time date];
		}

	}
	
	db_event.category = title_elems[0];
	db_event.val = [title_elems[1] intValue];
	if([title_elems count] >= 3){
		db_event.person = title_elems[2];
	}
	else{
		db_event.person = @"";
	}
	
	db_event.eTag = [event ETag];
	db_event.html_link = [[[event editLink] URL] absoluteString];
	db_event.memo = [[event content] stringValue];
	
	db_event.sync_status = @"synced";
	
	NSArray* event_status_elems = [[[event eventStatus] stringValue] componentsSeparatedByString:@"."];
	db_event.event_status = [event_status_elems lastObject];
	
	NSArray* id_elems = [[event identifier] componentsSeparatedByString:@"/"];
	db_event.identifier = [id_elems lastObject];
	
	db_event.last_update = [[event updatedDate] date];
	
	[self save_model];
}

- (NSArray*) get_all_event_list{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBEvent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	
    [fetchRequest setSortDescriptors:@[desc1]];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
						 initWithFetchRequest:fetchRequest
						 managedObjectContext:[self managedObjectContext]
						 sectionNameKeyPath:nil
						 cacheName:nil];
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}

- (NSArray*) get_all_event_normal_list{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBEvent_Normal" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	
    [fetchRequest setSortDescriptors:@[desc1]];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
						 initWithFetchRequest:fetchRequest
						 managedObjectContext:[self managedObjectContext]
						 sectionNameKeyPath:nil
						 cacheName:nil];
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}

- (NSArray*) db_event_normal_show_list_with_start:(NSDate*)start_date end:(NSDate*)end_date{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBEvent_Normal" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	
    [fetchRequest setSortDescriptors:@[desc1]];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"(date >= %@) and (date <= %@) and (event_status != %@)", start_date, end_date, @"canceled"];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
						 initWithFetchRequest:fetchRequest
						 managedObjectContext:[self managedObjectContext]
						 sectionNameKeyPath:nil
						 cacheName:nil];
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}

- (NSArray*) get_all_event_recurrence_list{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBEvent_Recurrence" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	
    [fetchRequest setSortDescriptors:@[desc1]];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
						 initWithFetchRequest:fetchRequest
						 managedObjectContext:[self managedObjectContext]
						 sectionNameKeyPath:nil
						 cacheName:nil];
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}

- (NSArray*) db_event_recurrence_show_list_with_start:(NSDate*)start_date{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBEvent_Recurrence" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	
    [fetchRequest setSortDescriptors:@[desc1]];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"(date >= %@) and (event_status != %@)", start_date, @"canceled"];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
						 initWithFetchRequest:fetchRequest
						 managedObjectContext:[self managedObjectContext]
						 sectionNameKeyPath:nil
						 cacheName:nil];
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}

- (NSArray*) get_all_event_exception_list{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBEvent_Exception" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	
    [fetchRequest setSortDescriptors:@[desc1]];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
						 initWithFetchRequest:fetchRequest
						 managedObjectContext:[self managedObjectContext]
						 sectionNameKeyPath:nil
						 cacheName:nil];
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}

- (void) del_all_event_actuary{
	NSArray* all_event_list = [self get_all_event_list];
	
	for(NSInteger i = 0; i < [all_event_list count]; i ++){
		[self.managedObjectContext deleteObject:all_event_list[i]];
	}
	
	[self save_model];
}

- (DBEvent_Recurrence*) get_event_recurrence:(NSString*)identifier{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBEvent_Recurrence" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:@[desc1]];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
						 initWithFetchRequest:fetchRequest
						 managedObjectContext:[self managedObjectContext]
						 sectionNameKeyPath:nil
						 cacheName:nil];
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	if([resultsController.fetchedObjects count] == 0){
		return nil;
	}
	else{
		return resultsController.fetchedObjects[0];
	}
}

- (NSArray*) event_instance_list_with_start:(NSDate*)start_date end:(NSDate*)end_date{
	NSMutableArray* event_instance_list = [[NSMutableArray alloc] init];
	
	NSArray* db_event_normal_list = [self db_event_normal_show_list_with_start:start_date end:end_date];
	for(DBEvent* event in db_event_normal_list){
		[event_instance_list addObject:[event event]];
	}
	
	NSArray* db_event_recurrence_list = [self db_event_recurrence_show_list_with_start:start_date];
	for(DBEvent_Recurrence* event in db_event_recurrence_list){
		NSArray* event_list = [event event_list_with_start:start_date end:end_date];
		
		[event_instance_list addObjectsFromArray:event_list];
	}
	
	NSSortDescriptor* desc = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	[event_instance_list sortUsingDescriptors:@[desc]];
	
	return event_instance_list;
}

- (DBEvent*) get_event_with_id:(NSString*)identifier{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBEvent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:@[desc1]];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
						 initWithFetchRequest:fetchRequest
						 managedObjectContext:[self managedObjectContext]
						 sectionNameKeyPath:nil
						 cacheName:nil];
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	if([resultsController.fetchedObjects count] == 0){
		return nil;
	}
	else{
		return resultsController.fetchedObjects[0];
	}
}

- (void) del_event_actually:(DBEvent*)event{
	[self.managedObjectContext deleteObject:event];
}

- (void) del_normal_event:(DBEvent_Normal*)event{
	//ローカルにしかないeventの場合
	if([event.sync_status isEqualToString:@"tmp_added"] == YES){
		//完全削除
		[self del_event_actually:event];
	}
	//GoogleCalにあるeventの場合
	else{
		event.event_status = @"canceled";
		event.sync_status = @"tmp_deleted";
		event.last_update = [NSDate date];
	}
	
	[self save_model];
}

- (void) del_exception_event:(DBEvent_Exception*)event{
	//ローカルにしかないeventの場合
	if([event.sync_status isEqualToString:@"tmp_added"] == YES){
		//繰り返しの例外(削除)に変える
		event.event_status = @"canceled";
		event.last_update = [NSDate date];
	}
	//GoogleCalにあるeventの場合
	else{
		//繰り返しの例外は一旦削除する
		event.event_status = @"canceled";
		event.sync_status = @"tmp_deleted";
		event.last_update = [NSDate date];
	}
	
	[self save_model];
}

- (void) del_recurrence_event_one_day:(DBEvent_Recurrence*)event date:(NSDate*)date{
	//例外イベント(１日削除)の追加
	DBEvent_Exception* db_event = [NSEntityDescription insertNewObjectForEntityForName:@"DBEvent_Exception" inManagedObjectContext:self.managedObjectContext];
	
	db_event.org_event = event;
	
	db_event.date = date;
	db_event.org_date = date;
	db_event.category = event.category;
	db_event.val = event.val;
	db_event.person = event.person;
	
	db_event.eTag = nil;
	db_event.html_link = nil;
	db_event.memo = event.memo;
	
	db_event.sync_status = @"tmp_added";
	db_event.event_status = @"canceled";
	
	db_event.identifier = nil;
	
	db_event.last_update = [NSDate date];
	
	[self save_model];
}

- (void) del_recurrence_event_all:(DBEvent_Recurrence*)event{
	//ローカルにしかないeventの場合
	if([event.sync_status isEqualToString:@"tmp_added"] == YES){
		//完全削除
		[self del_event_actually:event];
	}
	//GoogleCalにあるeventの場合
	else{
		event.event_status = @"canceled";
		event.sync_status = @"tmp_deleted";
		event.last_update = [NSDate date];
		
		//例外も全て削除
		for(DBEvent_Exception* exception_event in event.exceptions){
			[self del_event_actually:exception_event];
		}
	}
	
	[self save_model];
}

- (void) del_recurrent_event_from_date:(DBEvent_Recurrence*)event date:(NSDate*)date{
	//繰り返しをその日までに変更する
	event.sync_status = @"tmp_edited";
	event.last_update = [NSDate date];
	
	//指定日の前日までにする
	[event set_until_date:[NSDate dateWithTimeInterval:-3600*24 sinceDate:date]];
	
	//指定日以降の例外を削除
	for(DBEvent_Exception* exception_event in event.exceptions){
		NSComparisonResult date_comp = [CommonAPI compare_date:date date2:exception_event.org_date];
		if(date_comp == NSOrderedSame || date_comp == NSOrderedAscending){
			[self del_event_actually:exception_event];
		}
	}
	
	[self save_model];
}


- (void) update_event_actually:(GDataEntryCalendarEvent*)event{
	
}

- (NSArray*) get_local_added_event{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBEvent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	
    [fetchRequest setSortDescriptors:@[desc1]];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"sync_status = %@", @"tmp_added"];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
						 initWithFetchRequest:fetchRequest
						 managedObjectContext:[self managedObjectContext]
						 sectionNameKeyPath:nil
						 cacheName:nil];
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}

- (NSArray*) get_local_edited_event{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBEvent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	
    [fetchRequest setSortDescriptors:@[desc1]];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"sync_status = %@", @"tmp_edited"];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
						 initWithFetchRequest:fetchRequest
						 managedObjectContext:[self managedObjectContext]
						 sectionNameKeyPath:nil
						 cacheName:nil];
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}

- (NSArray*) get_local_deleted_event{
	// DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBEvent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
	
	// ソート条件配列を作成
    NSSortDescriptor *desc1;
    desc1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	
    [fetchRequest setSortDescriptors:@[desc1]];
	
	// 取得条件の設定
	NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"sync_status = %@", @"tmp_deleted"];
    [fetchRequest setPredicate:pred];
	
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
						 initWithFetchRequest:fetchRequest
						 managedObjectContext:[self managedObjectContext]
						 sectionNameKeyPath:nil
						 cacheName:nil];
	
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return resultsController.fetchedObjects;
}

- (void) edit_normal_event:(DBEvent_Normal*)event history_data:(History_Data*)new_data{
	//変更後も単体イベントの場合
	if(new_data.period.type == ONE_DAY){
		//ローカルにしかないeventの場合
		if([event.sync_status isEqualToString:@"tmp_added"] == YES){
			//データだけ上書き
			[event set_data:new_data];
		}
		//GoogleCalにあるeventの場合
		else{
			event.sync_status = @"tmp_edited";
			
			[event set_data:new_data];
		}
	}
	//変更後が繰り返しイベントの場合
	else{
		DBEvent_Recurrence* recc_event = [NSEntityDescription insertNewObjectForEntityForName:@"DBEvent_Recurrence" inManagedObjectContext:self.managedObjectContext];
		[recc_event set_data:new_data];
		
		//ローカルにしかないeventの場合
		if([event.sync_status isEqualToString:@"tmp_added"] == YES){
			recc_event.sync_status = @"tmp_added";
			recc_event.event_status = @"confirmed";
		}
		//GoogleCalにあるeventの場合
		else{
			recc_event.sync_status = @"tmp_edited";
			recc_event.event_status = @"confirmed";
			
			recc_event.eTag = event.eTag;
			recc_event.identifier = event.identifier;
			recc_event.html_link = event.html_link;
		}
		
		[self del_event_actually:event];
	}
	
	[self save_model];
}

- (void) edit_exception_event:(DBEvent_Exception*)event history_data:(History_Data*)new_data{
	//変更後も単体イベントの場合
	if(new_data.period.type == ONE_DAY){
		//ローカルにしかないeventの場合
		if([event.sync_status isEqualToString:@"tmp_added"] == YES){
			//データだけ上書き
			[event set_data:new_data];
		}
		//GoogleCalにあるeventの場合
		else{
			event.sync_status = @"tmp_edited";
			
			[event set_data:new_data];
		}
	}
	//変更後が繰り返しイベントの場合
	else{
		//エラー
		assert(0);
	}
	
	[self save_model];
}

- (void) edit_recurrence_event_all:(DBEvent_Recurrence*)event history_data:(History_Data*)new_data{
	//変更後が単体イベントの場合
	if(new_data.period.type == ONE_DAY){
		//エラー
		assert(0);
	}
	//変更後も繰り返しイベントの場合
	else{
		//ローカルにしかないeventの場合
		if([event.sync_status isEqualToString:@"tmp_added"] == YES){
			[event set_data:new_data];
		}
		//GoogleCalにあるeventの場合
		else{
			event.sync_status = @"tmp_edited";
			
			[event set_data:new_data];
		}
	}
	
	[self save_model];
}

- (void) edit_recurrence_event_one_day:(DBEvent_Recurrence*)event history_data:(History_Data*)new_data org_date:(NSDate*)org_date{
	//例外イベント(１日変更)の追加
	DBEvent_Exception* db_event = [NSEntityDescription insertNewObjectForEntityForName:@"DBEvent_Exception" inManagedObjectContext:self.managedObjectContext];
	[db_event set_data:new_data];
	
	db_event.org_event = event;
	db_event.org_date = org_date;
	
	db_event.sync_status = @"tmp_added";
	db_event.event_status = @"confirmed";
	
	[self save_model];
}

- (void) edit_recurrence_event_from_date:(DBEvent_Recurrence*)event history_data:(History_Data*)new_data date:(NSDate*)date{
	//繰り返しをその日までに変更する
	event.sync_status = @"tmp_edited";
	event.last_update = [NSDate date];
	
	int org_rrule_count = event.rrule_count;
	NSDate* org_rrule_until = event.rrule_until;
	
	//指定日の前日までにする
	[event set_until_date:[NSDate dateWithTimeInterval:-3600*24 sinceDate:date]];
	
	//指定日以降の例外を削除
	for(DBEvent_Exception* exception_event in event.exceptions){
		NSComparisonResult date_comp = [CommonAPI compare_date:date date2:exception_event.org_date];
		if(date_comp == NSOrderedSame || date_comp == NSOrderedAscending){
			[self del_event_actually:exception_event];
		}
	}
	
	//指定日からの繰り返しイベントを追加
	//繰り返しの期間が変更されていない場合
#warning tbd
	if(1){
		//指定日から元の最終日までの繰り返しイベントを追加
		[self add_history3:new_data];
	}
	//繰り返しの期間が変更されている場合
	else{
		//指定日から新しい繰り返しイベントを追加
		[self add_history3:new_data];
	}
	
	[self save_model];
}

@end
