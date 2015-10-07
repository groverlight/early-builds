
//! \file   ParseUser.m
//! \brief  Parse class containing data about an user object.
//__________________________________________________________________________________________________

#import <Parse/PFObject+Subclass.h>

#import "Blocks.h"
#import "Parse.h"
#import "ParseUser.h"
//__________________________________________________________________________________________________

//! Get the shared (singleton) FriendRecord.h array object.
NSMutableArray* GetSharedFriendsList(void)
{
  static NSMutableArray* SharedFriendsList = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^
  {
    SharedFriendsList = [NSMutableArray arrayWithCapacity:20];
  });
  return SharedFriendsList;
}
//__________________________________________________________________________________________________

//! Parse class containing data about an user object.
@implementation ParseUser
{
}
@dynamic fullName;
@dynamic phoneNumber;
@dynamic lastActivityTimestamp;
@dynamic friends;

//____________________

+ (void)load
{
  [self registerSubclass];
}
//__________________________________________________________________________________________________

- (void)dealloc
{
}
//__________________________________________________________________________________________________

//! Update the last activity timestamp of the user.
- (void)updateTimestamp:(BlockBoolErrorAction)completion
{
  self.lastActivityTimestamp = [[NSDate date] timeIntervalSince1970];
  [self saveInBackgroundWithBlock:^(BOOL success, NSError *error)
  {
    completion(success, error);
  }];
}
//__________________________________________________________________________________________________

//! Load the friends list.
- (void)loadFriendsListWithCompletion:(BlockArrayErrorAction)completion
{
  NSInteger       __block fetchCount  = self.friends.count;
  NSMutableArray* __block friends     = GetSharedFriendsList();
  if (fetchCount == 0)
  {
    completion(friends, nil);
  }
  else
  {
    [friends removeAllObjects];
    NSLog(@"0 findUserWithObjectId: num friends: %d (%d)", (int)self.friends.count, (int)friends.count);
    for (NSString* friendObjectId in self.friends)
    {
//      NSLog(@"currentUser: %p, friendObjectId: %@", GetCurrentParseUser(), friendObjectId);
      [ParseUser findUserWithObjectId:friendObjectId completion:^(ParseUser* user, NSError* error)
      {
//        NSLog(@"1 findUserWithObjectId: index: %ld, NSNotFOund: %ld, friendObjectId: %@", (long)[friends indexOfObject:user], (long)NSNotFound, friendObjectId);
        if (user != nil)
        {
//          NSLog(@"2 findUserWithObjectId: friendObjectId: %@", friendObjectId);
          [friends addObject:user];
        }
        --fetchCount;
        if (fetchCount == 0)
        {
//          NSLog(@"3 findUserWithObjectId: num friends: %d (%d)", (int)self.friends.count, (int)friends.count);
          completion(friends, nil);
        }
      }];
    }
  }
}
//__________________________________________________________________________________________________

//! Retrieve the friends list.
- (NSArray*)getFriendsList
{
  return GetSharedFriendsList();
}
//__________________________________________________________________________________________________

//! Retrieve a loaded friend.
- (ParseUser*)getFriend:(NSString*)friendObjectId
{
  NSArray* friends = GetSharedFriendsList();
  NSLog(@"getFriend: %@, friendObjectId: %@", friends, friendObjectId);
  for (ParseUser* user in friends)
  {
    if ([user.objectId isEqualToString:friendObjectId])
    {
      NSLog(@"getFriend: Found: %@", user.objectId);
      return user;
    }
  }
  NSLog(@"getFriend: Not found");
  return nil;
}
//__________________________________________________________________________________________________

//! Add a new friend to the friends list.
- (void)addFriend:(ParseUser*)newFriend completion:(BlockBoolErrorAction)completion
{
  NSInteger index = [self.friends indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL* stop)
  {
    return ([obj isEqual:newFriend.objectId]);
  }];

  if ((self.friends == nil) || (index == NSNotFound))
  {
    if (self.friends != nil)
    {
      self.friends = [self.friends arrayByAddingObject:newFriend.objectId];
    }
    else
    {
      self.friends = [NSArray arrayWithObject:newFriend.objectId];
    }
//    NSLog(@"self: %p, currentUser: %p", self, GetCurrentParseUser());
    [self saveInBackgroundWithBlock:^(BOOL success, NSError* save_error)
    {
      completion(success, save_error);
    }];
  }
  else
  {
    completion(YES, nil);
  }
}
//__________________________________________________________________________________________________

- (void)removeFriend:(ParseUser*)friend fromUser:(ParseUser*)user
{
  NSLog(@"1 removeFriend: %@ (%@) FromUser: %@ (%@)", friend.username, friend.fullName, user.username, user.fullName);
  BOOL found = NO;
  NSMutableArray* array = [NSMutableArray arrayWithCapacity:user.friends.count];
  for (NSString* objectId in user.friends)
  {
    NSLog(@"2 removeFriendFromUser: %@, %@", friend.objectId, objectId);
    if ([objectId isEqualToString:friend.objectId])
    {
      NSLog(@"3 removeFriendFromUser: found");
      found = YES;
    }
    else
    {
      NSLog(@"4 removeFriendFromUser: keep %@", objectId);
      [array addObject:objectId];
    }
  }
  NSLog(@"5 removeFriendFromUser");
  if (found)
  {
    NSLog(@"6 removeFriendFromUser");
    user.friends = array;
    [user save];
    NSMutableArray* friends = GetSharedFriendsList();
    for (NSInteger i = friends.count -1; i >= 0; --i)
    {
      ParseUser* friendUser = friends[i];
      if ([friendUser.objectId isEqualToString:friend.objectId])
      {
        NSLog(@"getFriend: Found: %@", user.objectId);
        [friends removeObject:friendUser];
      }
    }
  }
}
//__________________________________________________________________________________________________

- (void)removeFriend:(ParseUser*)friend fromUser:(ParseUser*)user completion:(BlockBoolErrorAction)completion
{
//  NSLog(@"1 removeFriend: %@ (%@) FromUser: %@ (%@)", friend.username, friend.fullName, user.username, user.fullName);
  BOOL found = NO;
  NSMutableArray* array = [NSMutableArray arrayWithCapacity:user.friends.count];
  for (NSString* objectId in user.friends)
  {
//    NSLog(@"2 removeFriendFromUser: %@, %@", friend.objectId, objectId);
    if ([objectId isEqualToString:friend.objectId])
    {
//      NSLog(@"3 removeFriendFromUser: found");
      found = YES;
    }
    else
    {
//      NSLog(@"4 removeFriendFromUser: keep %@", objectId);
      [array addObject:objectId];
    }
  }
//  NSLog(@"5 removeFriendFromUser");
  if (found)
  {
//    NSLog(@"6 removeFriendFromUser");
    user.friends = array;
    [user saveInBackgroundWithBlock:^(BOOL success, NSError *error)
    {
//      NSLog(@"7 removeFriendFromUser");
      completion(success, error);
    }];
    NSMutableArray* friends = GetSharedFriendsList();
    for (NSInteger i = friends.count -1; i >= 0; --i)
    {
      ParseUser* friendUser = friends[i];
      if ([friendUser.objectId isEqualToString:friend.objectId])
      {
        NSLog(@"getFriend: Found: %@", user.objectId);
        [friends removeObject:friendUser];
      }
    }
  }
  else
  {
//    NSLog(@"8 removeFriendFromUser");
    completion(NO, nil);
  }
}
//__________________________________________________________________________________________________

//! Asynchronously remove a friend from the friends list.
- (void)removeFriend:(ParseUser*)friend completion:(BlockBoolErrorAction)completion
{
  [self removeFriend:friend fromUser:self completion:^(BOOL selfSuccess, NSError* selfError)
  {
    completion(selfSuccess, selfError);
  }];
}
//__________________________________________________________________________________________________

//! Synchronously remove a friend from the friends list.
- (void)removeFriend:(ParseUser*)friend
{
  [self removeFriend:friend fromUser:self];
}
//__________________________________________________________________________________________________

//! Test if a user is a friend.
- (BOOL)isFriend:(ParseUser*)user
{
  for (NSString* friend in self.friends)
  {
    if ([user.objectId isEqualToString:friend])
    {
      return YES;
    }
  }
  return NO;
}
//__________________________________________________________________________________________________

+ (void)findUserWithObjectId:(NSString*)objectId completion:(BlockUserErrorAction)completion
{
  PFQuery* query = [ParseUser query];
//  NSLog(@"findUserWithObjectId: %@", objectId);
  [query getObjectInBackgroundWithId:objectId block:^(PFObject* foundUser, NSError *error)
  {
    ParseUser* user = (ParseUser*)foundUser;
//    NSLog(@"findUserWithObjectId: %@", user);
    if (user.fullName == nil)
    {
      user.fullName = [NSString stringWithFormat:@"(%@)", user.username];
    }
    completion(user, error);
  }];
}
//__________________________________________________________________________________________________

+ (void)findUsersWithUsername:(NSString*)username completion:(BlockArrayErrorAction)completion
{
  PFQuery* query = [ParseUser query];
  [query whereKey:@"username" equalTo:username];
  [query findObjectsInBackgroundWithBlock:^(NSArray* users, NSError* error)
  {
    for (ParseUser* user in users)
    {
      if (user.fullName == nil)
      {
        user.fullName = [NSString stringWithFormat:@"(%@)", user.username];
      }
    }
    completion(users, error);
  }];
}
//__________________________________________________________________________________________________

//! Retrieve all user objects whose username starts with the specified string.
+ (void)findUsersWithUsernameStartingWith:(NSString*)string completion:(BlockArrayErrorAction)completion
{
  PFQuery* query = [ParseUser query];
  [query whereKey:@"username" hasPrefix:string];
  [query findObjectsInBackgroundWithBlock:^(NSArray* users, NSError* error)
  {
    for (ParseUser* user in users)
    {
      if (user.fullName == nil)
      {
        user.fullName = [NSString stringWithFormat:@"(%@)", user.username];
      }
    }
    completion(users, error);
  }];
}
//__________________________________________________________________________________________________

+ (void)findUsersWithPhoneNumber:(NSString*)phoneNumber completion:(BlockArrayErrorAction)completion
{
  PFQuery* query = [ParseUser query];
  [query whereKey:@"phoneNumber" equalTo:phoneNumber];
  [query findObjectsInBackgroundWithBlock:^(NSArray* users, NSError* error)
  {
    for (ParseUser* user in users)
    {
      if (user.fullName == nil)
      {
        user.fullName = [NSString stringWithFormat:@"(%@)", user.username];
      }
    }
    completion(users, error);
  }];
}
//__________________________________________________________________________________________________

+ (void)testUserExistenceWithUsername:(NSString*)username completion:(BlockBoolErrorAction)completion
{
  [self findUsersWithUsername:username completion:^(NSArray* users, NSError* error)
  {
    completion((users.count > 0), error);
  }];
}
//__________________________________________________________________________________________________

+ (void)testUserExistenceWithPhoneNumber:(NSString*)phoneNumber completion:(BlockBoolErrorAction)completion
{
  [self findUsersWithPhoneNumber:phoneNumber completion:^(NSArray* users, NSError* error)
  {
    completion((users.count > 0), error);
  }];
}
//__________________________________________________________________________________________________

//! Signs up the user asynchronously. Make sure that password and username are set. This will also enforce that the username isn’t already taken. This will also cache the user locally so that calls to currentUser will use the latest logged in user.
+ (void)signUp:(NSString*)username password:(NSString*)password completion:(BlockBoolErrorAction)completion
{
  ParseUser* user = [ParseUser object];
  user.username   = username;
  user.password   = password;
  [user signUpInBackgroundWithBlock:^(BOOL success, NSError*error)
  {
    completion(success, error);
  }];
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________

ParseUser* GetCurrentParseUser(void)
{
  ParseUser* user = [ParseUser currentUser];
  if (user == nil)
  {
    user = user;
    NSLog(@"GetCurrentParseUser: %p", user);
  }
  return user;
}
//__________________________________________________________________________________________________
