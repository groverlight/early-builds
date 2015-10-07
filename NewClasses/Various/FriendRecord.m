//! \file   FriendRecord.m
//! \brief  A class that manages lists of friend records.
//__________________________________________________________________________________________________

#import "FriendRecord.h"
#import <Foundation/Foundation.h>
#import "GlobalParameters.h"
#import "Message.h"
#import "ParseUser.h"
#import "UnreadMessages.h"
//__________________________________________________________________________________________________

#define FRIEND_RECORD_LIST_NAME @"FriendRecordList"
//__________________________________________________________________________________________________

@implementation FriendRecord
{
    ParseUser* User;
}
@synthesize numUnreadMessages;

- (instancetype)initWithUser:(ParseUser*)user andTime:(NSTimeInterval)time
{
    self = [super init];
    if (self != nil)
    {
        if (user == nil)
        {
            NSLog(@"FriendRecord initWithUser nil");
        }
        self.user             = user;
        self.lastActivityTime = time;
        self.fullName         = (user.fullName == nil)? @"<Unassigned>": user.fullName;
        NSLog(@"FriendRecord initWithUser: %f, %@", self.lastActivityTime, self.fullName);
    }
    return self;
}
//__________________________________________________________________________________________________

- (void)encodeWithCoder:(NSCoder*)coder
{
    if (self.user == nil)
    {
        NSLog(@"1 User == nil! -> full name: '%@'", self.fullName);
        [coder encodeObject:nil forKey:@"UserId"];
    }
    else
    {
        [coder encodeObject:self.user.objectId forKey:@"UserId"];
    }
    [coder encodeObject:self.fullName                                     forKey:@"FullName"];
    [coder encodeObject:[NSNumber numberWithDouble:self.lastActivityTime] forKey:@"LastActivityTime"];
}
//__________________________________________________________________________________________________

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super init];
    if (self)
    {
        self.fullName = [coder decodeObjectForKey:@"FullName"];
        id objectId   = [coder decodeObjectForKey:@"UserId"];
        if (objectId == nil)
        {
            self.user = nil;
        }
        else
        {
            [ParseUser findUserWithObjectId:objectId completion:^(ParseUser* user, NSError* error)
             {
                 if (user != nil)
                 {
                     self.user = user;
                 }
                 else
                 {
                     NSLog(@"2 User == nil! -> full name: '%@'", self.fullName);
                 }
             }];
        }
        if (self.fullName == nil)
        {
            self.fullName = @"<unassigned 2>";
        }
        self.lastActivityTime = ((NSNumber*)[coder decodeObjectForKey:@"LastActivityTime"]).doubleValue;
        NSLog(@"FriendRecord initWithCoder: %f, %@", self.lastActivityTime, self.fullName);
    }
    return self;
}
//__________________________________________________________________________________________________

- (void)setUser:(ParseUser*)user
{
    User = user;
    if (user == nil)
    {
        NSLog(@"3 User == nil! -> full name: '%@'", self.fullName);
    }
    else
    {
        self.fullName = User.fullName;
    }
    //  NSLog(@"FriendRecord setRecord: fullName: %@", self.fullName);
}
//__________________________________________________________________________________________________

- (ParseUser*)user
{
    return User;
}
//__________________________________________________________________________________________________

@end
//==================================================================================================

//! A class that manages lists of FriendRecords.
@interface FriendRecordsList: NSObject
{
@public
    NSMutableArray* TimeSortedList;
    NSMutableArray* NameSortedList;
}
//____________________

- (void)clear;
//____________________

- (BOOL)updateForUser:(ParseUser*)user atTime:(NSTimeInterval)time updateOnly:(BOOL)updateOnly;
//____________________

- (void)updateForFriends:(NSArray*)friends;
//____________________

- (void)sortTimeList;
//____________________

- (void)sortNameList;
//____________________

@end
//__________________________________________________________________________________________________

//! A class that manages lists of FriendRecords.
@implementation FriendRecordsList
{
}
//____________________

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        TimeSortedList  = [NSMutableArray arrayWithCapacity:10];
        NameSortedList  = [NSMutableArray arrayWithCapacity:10];
        [self load];
        [self sortTimeList];
        [self sortNameList];
    }
    return self;
}
//__________________________________________________________________________________________________

- (void)clear
{
    [TimeSortedList     removeAllObjects];
    [NameSortedList     removeAllObjects];
}
//__________________________________________________________________________________________________

- (void)sortTimeList
{
    if (TimeSortedList.count == 0)
    {
        [TimeSortedList removeAllObjects];
    }
    else
    {
        [TimeSortedList sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             FriendRecord* record1 = (FriendRecord*)obj1;
             FriendRecord* record2 = (FriendRecord*)obj2;
             if (record1.lastActivityTime > record2.lastActivityTime)
             {
                 return NSOrderedAscending;
             }
             else if (record1.lastActivityTime < record2.lastActivityTime)
             {
                 return NSOrderedDescending;
             }
             else
             {
                 return NSOrderedSame;
             }
         }];
    }
#if 0
    NSLog(@"sortTimeList:");
    for (FriendRecord* record in TimeSortedList)
    {
        NSLog(@"timestamp: %ld, name: %@", (long)record.lastActivityTime, record.fullName);
    }
#endif
}
//__________________________________________________________________________________________________

- (void)sortNameList
{
 [NameSortedList sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {
         FriendRecord* record1 = (FriendRecord*)obj1;
         FriendRecord* record2 = (FriendRecord*)obj2;
         return ([record1.fullName caseInsensitiveCompare:record2.fullName]);
     }];
    
/*#if 0
    NSLog(@"sortNameList:");
    for (FriendRecord* record in NameSortedList)
    {
        NSLog(@"timestamp: %ld, name: %@", (long)record.lastActivityTime, record.fullName);
    }
#endif*/
}
//__________________________________________________________________________________________________

- (void)refreshUnreadMessageCount
{
    UnreadMessages* messages = GetSharedUnreadMessages();
    for (int i = 0; i < TimeSortedList.count; ++i)
    {
        FriendRecord* record = [TimeSortedList objectAtIndex:i];
        record.numUnreadMessages = 0;
        for (Message* msg in messages->Messages)
        {
            if ([record.user.objectId isEqualToString:msg->FromObjectId])
            {
                record.numUnreadMessages++;
            }
        }
    }
}
//__________________________________________________________________________________________________

- (BOOL)updateForUser:(ParseUser*)parseUser atTime:(NSTimeInterval)time updateOnly:(BOOL)updateOnly
{
    BOOL changed = NO;
    FriendRecord* friendRecord = [[FriendRecord alloc] initWithUser:parseUser andTime:time];
    NSInteger index = [TimeSortedList indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                       {
                           FriendRecord* testActivity = (FriendRecord*)obj;
                           if ([friendRecord.user.objectId isEqualToString:testActivity.user.objectId])
                           {
                               return YES;
                           }
                           return NO;
                       }];
    if (index == NSNotFound)
    {
        [NameSortedList addObject:friendRecord];
        [TimeSortedList addObject:friendRecord];
        [self sortNameList];
        changed = YES;
    }
    else
    {
        FriendRecord* foundActivity = [TimeSortedList objectAtIndex:index];
        changed = foundActivity.lastActivityTime < time;
        if (changed)
        {
            [TimeSortedList replaceObjectAtIndex:index withObject:friendRecord];
        }
    }
    if (changed)
    {
        [self sortTimeList];
        [self refreshUnreadMessageCount];
    }
    return changed;
}
//__________________________________________________________________________________________________

- (void)updateForFriends:(NSArray*)friends
{
    //  NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    //  NSLog(@"1 updateActivityForFriends");
    BOOL changed = NO;
    for (NSInteger i = NameSortedList.count - 1; i >= 0; --i)
    {
        //    NSLog(@"2 updateActivityForFriends");
        FriendRecord* nameRecord = [NameSortedList objectAtIndex:i];
        BOOL found = NO;
        for (ParseUser* friend in friends)
        {
            //      NSLog(@"3 updateActivityForFriends: %@", ((ParseUser*)friend).fullName);
            if ([nameRecord.user.objectId isEqualToString:friend.objectId])
            {
                //        NSLog(@"4 updateActivityForFriends");
                found = YES;
                break;
            }
        }
        if (!found)
        {
            //      NSLog(@"5 updateActivityForFriends: %@", record.fullName);
            [NameSortedList removeObject:nameRecord];
            changed = YES;
        }
    }
    for (NSInteger i = TimeSortedList.count - 1; i >= 0; --i)
    {
        //    NSLog(@"2 updateActivityForFriends");
        FriendRecord* timeRecord = [TimeSortedList objectAtIndex:i];
        BOOL found = NO;
        for (ParseUser* friend in friends)
        {
            //      NSLog(@"3 updateActivityForFriends: %@", ((ParseUser*)friend).fullName);
            if ([timeRecord.user.objectId isEqualToString:friend.objectId])
            {
                //        NSLog(@"4 updateActivityForFriends");
                found = YES;
                break;
            }
        }
        if (!found)
        {
            //      NSLog(@"5 updateActivityForFriends: %@", record.fullName);
            [TimeSortedList removeObject:timeRecord];
            changed = YES;
        }
    }
    
    for (ParseUser* friend in friends)
    {
        BOOL found = NO;
        for (NSInteger i = NameSortedList.count - 1; i >= 0; --i)
        {
            //    NSLog(@"6 updateActivityForFriends");
            FriendRecord* record = [NameSortedList objectAtIndex:i];
            //      NSLog(@"7 updateActivityForFriends: %@", ((ParseUser*)friend).fullName);
            if ([record.user.objectId isEqualToString:friend.objectId])
            {
                //        NSLog(@"8 updateActivityForFriends");
                found = YES;
                break;
            }
        }
        if (!found)
        {
            NSLog(@"9 updateActivityForFriends: %@", friend.fullName);
            FriendRecord* friendRecord = [[FriendRecord alloc] initWithUser:friend andTime:0];
            [NameSortedList addObject:friendRecord];
            [TimeSortedList addObject:friendRecord];
            changed = YES;
        }
    }
    
    if (changed)
    {
        //    NSLog(@"10 updateActivityForFriends");
        [self sortTimeList];
        [self sortNameList];
        [self save];
    }
    //  NSLog(@"11 updateActivityForFriends");
}
//__________________________________________________________________________________________________

- (void)load
{
    NSUserDefaults* defaults  = [NSUserDefaults standardUserDefaults];
    NSArray* loadedArray      = [defaults objectForKey:FRIEND_RECORD_LIST_NAME];
    if (loadedArray != nil)
    {
        TimeSortedList = [NSMutableArray arrayWithCapacity:loadedArray.count];
        for (NSData* data in loadedArray)
        {
            FriendRecord* friendRecord;
            @try
            {
                friendRecord = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
            @catch (NSException* exception)
            {
                NSLog(@"FriendRecord load: exception in [NSKeyedUnarchiver unarchiveObjectWithData:] %@", exception);
                friendRecord = nil;
            }
            if ((friendRecord != nil) && ((friendRecord.user != nil) || (friendRecord.fullName != nil)))
            {
                // Check for duplicates. Should never happen, but reality doesn't always follow programmer's intents.
                BOOL found = NO;
                for (FriendRecord* record in TimeSortedList)
                {
                    if (((record.user != nil) && (record.user == friendRecord.user)) || [record.objectId isEqualToString:friendRecord.objectId])
                    {
                        found = YES;
                        break;
                    }
                }
                if (!found)
                {
                    [TimeSortedList addObject:friendRecord];
                }
            }
        }
    }
    else
    {
        TimeSortedList = [NSMutableArray arrayWithCapacity:10];
    }
    NameSortedList = [NSMutableArray arrayWithArray:TimeSortedList];
}
//__________________________________________________________________________________________________

- (void)save
{
    // First check that all users are not null.
    for (FriendRecord* friendRecord in TimeSortedList)
    {
        if ((friendRecord.user == nil) && (friendRecord.fullName == nil))
        { // Do not save if any pair of user and fullName is null!
            return;
        }
    }
    NSUserDefaults* defaults  = [NSUserDefaults standardUserDefaults];
    NSMutableArray* saveArray = [NSMutableArray arrayWithCapacity:TimeSortedList.count];
    //  NSLog(@"FriendRecord save");
    for (FriendRecord* friendRecord in TimeSortedList)
    {
        //      NSLog(@"3 (%@) User: %p -> fullName: '%@'", Name, friendRecord.user, friendRecord.fullName);
        if (friendRecord.user != nil)
        {
            NSData* data = [NSKeyedArchiver archivedDataWithRootObject:friendRecord];
            [saveArray addObject:data];
        }
    }
    [defaults setObject:saveArray forKey:FRIEND_RECORD_LIST_NAME];
}
//__________________________________________________________________________________________________

@end
//==================================================================================================

//! Get the shared (singleton) FriendRecordsListt object.
static FriendRecordsList* GetSharedActivityList(void)
{
    static FriendRecordsList* SharedFriendRecordsList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      SharedFriendRecordsList = [FriendRecordsList new];
                  });
    return SharedFriendRecordsList;
}
//__________________________________________________________________________________________________

//! Add a friendRecord in the Activity and SendTo lists if not currently present. Update the list otherwise.
void UpdateFriendRecordListForUser(ParseUser* user, NSTimeInterval time)
{
    FriendRecordsList* records = GetSharedActivityList();
    [records updateForUser:user atTime:time updateOnly:NO];
    [records save];
}
//__________________________________________________________________________________________________

//! Update the global friendRecord list if the from users are already present. Add them otherwise.
void UpdateFriendRecordListForMessages(UnreadMessages* messages, BlockBoolAction completion)
{
    BOOL __block        changed = NO;
    FriendRecordsList*  records = GetSharedActivityList();
    for (Message* message in messages->Messages)
    {
        changed |= [records updateForUser:message->FromUser atTime:message->Timestamp updateOnly:NO];
    }
    [records refreshUnreadMessageCount];
    if (changed)
    {
        [records save];
    }
    completion(changed);
}
//__________________________________________________________________________________________________

//! Update the friendRecord entries for users that are added to or removed from all lists.
void UpdateFriendRecordListForFriends(NSArray* friends)
{
    [GetSharedActivityList() updateForFriends:friends];
}
//__________________________________________________________________________________________________

//! Return the list of friendRecord to be displayed in the recent list.
NSArray* GetTimeSortedFriendRecords(void)
{
    return GetSharedActivityList()->TimeSortedList;
}
//__________________________________________________________________________________________________

//! Return the list of friendRecord to be displayed in the global list.
NSArray* GetNameSortedFriendRecords(void)
{
    return GetSharedActivityList()->NameSortedList;
}
//__________________________________________________________________________________________________

//! Refresh the list of friends to be displayed in the A_Z view.
void RefreshAllFriends(BlockAction completion)
{
    ParseUser* currentUser = GetCurrentParseUser();
    [currentUser loadFriendsListWithCompletion:^(NSArray* friends, NSError *error)
     {
         UpdateFriendRecordListForFriends(friends);
         completion();
     }];
}
//__________________________________________________________________________________________________