
//! \file   AppViewController.m
//! \brief  The main ViewController of the application.
//__________________________________________________________________________________________________

#import "AppViewController.h"

#import "FriendRecord.h"
#import "Alert.h"
#import "BaseView.h"
#import "GlobalParameters.h"
#import "InitGlobalParameters.h"
#import "NavigationView.h"
#import "Parse.h"
#import "Tools.h"
#import "TypingView.h"
#import "UnreadMessages.h"
#import "ViewStackView.h"
//__________________________________________________________________________________________________

#define BE_YOUR_BEST_FRIEND 0 //!< Define to 1 to declare the current user to be his own friend.
//__________________________________________________________________________________________________

static AppViewController* MainViewController = nil;
//__________________________________________________________________________________________________

//! The main ViewController of the application.
@interface AppViewController ()
{
@public
  GlobalParameters* GlobalParams;   //!< Pointer to the global parameters object.
}
//____________________

//@property (strong, nonatomic) IBOutlet CardNavigationView* cardNavigator;  //!< The view where everything is happening.
//____________________

@end
//__________________________________________________________________________________________________

@implementation AppViewController
{
  ViewStackView*  ViewStack;
  NavigationView* NavView;
  BOOL            LoadingMessages;
}
//@synthesize cardNavigator;
//____________________

- (instancetype)init
{
  self = [super init];
  if (self != nil)
  {
    LoadingMessages = NO;
  }
  return self;
}
//__________________________________________________________________________________________________

//! Tell if the status bar should be displayed or not.
- (BOOL)prefersStatusBarHidden
{
  return YES;
}
//__________________________________________________________________________________________________

- (void)loadReceivedMessages:(BlockBoolAction)completion
{
  // Load messages only if we are not currently loading them.
//  NSLog(@"1 loadReceivedMessages");
  if (!LoadingMessages)
  {
    LoadingMessages = YES;
//    NSLog(@"2 loadReceivedMessages");
    [NavView loadReceivedMessages:^(BOOL hasNewData)
    {
//      NSLog(@"3 loadReceivedMessages");
      LoadingMessages = NO;
      completion(hasNewData);
    }];
  }
//  NSLog(@"4 loadReceivedMessages");
}
//__________________________________________________________________________________________________

- (void)loginDone:(BOOL)newUser
{
  LoggedIn = YES;
  set_myself;
#if BE_YOUR_BEST_FRIEND
  ParseUser* currentUser = GetCurrentParseUser();
  // Add ourself as friend to be able to test push notifications with a single user. Do nothing if we are already in the friends list.
  [currentUser addFriend:currentUser completion:^(BOOL success, NSError *error)
  {
#endif
    [GetCurrentParseUser() loadFriendsListWithCompletion:^(NSArray* friends, NSError* loadError)
    {
      get_myself;
      if (loadError == nil)
      {
        UpdateFriendRecordListForFriends(friends);
        [myself loadReceivedMessages:^(BOOL hasNewData)
        {
          [NavView updateFriendsLists];
        }];

        if (newUser)
        {
          if (!ParseCheckPermissionForRemoteNotifications())
          {
            Alert(NSLocalizedString(@"Want Notifications?", @""), NSLocalizedString(@"To be alerted when your friends message you, please allow push notifications", @""), NSLocalizedString(@"OK", @""), nil, ^(NSInteger pressedButton)
            {
              ParseRegisterForRemoteNotifications(^(BOOL notificationsAreEnabled)
              {
              });
            });
          }
        }
        else
        {
          ParseRegisterForRemoteNotifications(^(BOOL notificationsAreEnabled)
          {
            if (!notificationsAreEnabled)
            {
              Alert(NSLocalizedString(@"Want Notifications?", @""), NSLocalizedString(@"To be alerted when your friends message you, please allow push notifications", @""), NSLocalizedString(@"OK", @""), nil, ^(NSInteger pressedButton)
              {
              });
            }
          });
        }
      }
      else
      {
        NSLog(@"Failed to load the friends : %@, %@", loadError, GetCurrentParseUser());
      }
    }];
#if BE_YOUR_BEST_FRIEND
  }];
#endif
}
//__________________________________________________________________________________________________

- (void)loadView
{
//  NSLog(@"1 loadView");
  MainViewController = self;
  // The global parameters should be set as soon as possible, at last before loading the user interface.
  GlobalParams = InitGlobalParameters(self);
//  NSLog(@"2 loadView");

  // The global parameters have been initialized. Now we can load the User Interface.
  [super loadView];
//  NSLog(@"3 loadView");

  ViewStack = [ViewStackView sharedInstance];
  self.view = ViewStack;
//  NSLog(@"4 loadView");
  NavView = [NavigationView new];
  NavView.frame = CGRectMake(0, 0, GetScreenWidth(), GetScreenHeight());
  set_myself;
//  NSLog(@"5 loadView");
  NavView->PleaseBlurByThisFactorAction = ^(CGFloat blurFactor)
  {
    get_myself;
    [myself->ViewStack blurWithFactor:blurFactor];
  };
  NavView->PleaseFlashForDuration = ^(CGFloat duration, BlockAction completion)
  {
    get_myself;
    [myself->ViewStack flashForDuration:duration completion:completion];
  };

//  NSLog(@"6 loadView");
  [ViewStack setTextViewContent:NavView animated:NO fromLeft:YES];
  [ViewStack activate];
//  NSLog(@"7 loadView");
}
//__________________________________________________________________________________________________

//! The UI has been loaded, do whatever else is required.
- (void)viewDidLoad
{
//  NSLog(@"1 viewDidLoad");
  [super viewDidLoad];
//  NSLog(@"2 viewDidLoad");

  // Parse stuff.
  ParseInitialization(^(PFUser* user, BOOL newUser, BOOL restart, NSError *error)
  {
    [NavView updateFriendsLists];
    if (error == nil)
    {
      if (newUser)
      {
        [NavView showLoginFromStart:restart];
      }
      else
      {
        [NavView ScrollToTypingPageAnimated:NO];
        GlobalParams.loginDone(NO);
      }
    }
    else
    {
      NSLog(@"Parse initialization completed, but failed: %@, %@", user, error);
    }
  });
}
//__________________________________________________________________________________________________

- (void)viewWillAppear:(BOOL)animated
{
}
//__________________________________________________________________________________________________

- (void)viewDidAppear:(BOOL)animated
{
}
//__________________________________________________________________________________________________

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  CGRect bounds = self.view.bounds;
  ViewStack.frame = bounds;
}
//__________________________________________________________________________________________________

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
}
//__________________________________________________________________________________________________

- (void)handleRemoteNotification:(NSString*)notificationMessage
{
}
//__________________________________________________________________________________________________

//! The application did just become active.
- (void)applicationDidBecomeActive
{
  NSLog(@"applicationDidBecomeActive");
  if ((GetCurrentParseUser() != nil) && MainViewController->LoggedIn)
  {
    [self loadReceivedMessages:^(BOOL hasNewData)
    { // Do nothing!
      [NavView updateFriendsLists];
    }];
    if (ViewStack != nil)
    {
      [ViewStack restoreLiveView];
    }
  }
  else
  {
    [ViewStack showLiveViewAnimated:NO];
  }
}
//__________________________________________________________________________________________________

//! The application will become inactive.
- (void)applicationWillResignActive
{
//  NSLog(@"applicationWillResignActive");
  if (ViewStack != nil)
  {
    [ViewStack cleanupLiveView];
  }
}
//__________________________________________________________________________________________________

//! Perform background data fetch.
- (void)performBackgroundFetch:(BlockBoolAction)completion
{
//  NSLog(@"performBackgroundFetch Start");
  [self loadReceivedMessages:^(BOOL hasNewData)
  {
//    NSLog(@"performBackgroundFetch End: %d\n\n", hasNewData);
    completion(hasNewData);
  }];
}
//__________________________________________________________________________________________________

@end

//! Present in a custom view the data contained in the remote notification userInfo dictionary.
void DidReceiveRemoteNotification(NSDictionary* userInfo, BlockBoolAction completion)
{
//  NSLog(@"1 DidReceiveRemoteNotification");
  if (MainViewController != nil)
  {
//    NSLog(@"2 DidReceiveRemoteNotification");
    NSDictionary* aps = [userInfo objectForKey:@"aps"];
    id alert = [aps objectForKey:@"alert"];
    if ([alert isKindOfClass:[NSDictionary class]])
    {
      alert = [alert objectForKey:@"body"];
    }
    [MainViewController handleRemoteNotification:alert];
  }
  else
  {
    ParseDidReceiveRemoteNotification(userInfo);
  }
//  NSLog(@"3 DidReceiveRemoteNotification");
  [MainViewController loadReceivedMessages:^(BOOL hasNewData)
  {
//    NSLog(@"4 DidReceiveRemoteNotification");
    completion(hasNewData);
  }];
}
//__________________________________________________________________________________________________

//! The application did just become active.
void ApplicationDidBecomeActive(void)
{
//  NSLog(@"ApplicationDidBecomeActive");
  if (MainViewController != nil)
  {
    [MainViewController applicationDidBecomeActive];
  }
}
//__________________________________________________________________________________________________

//! The application wil become inactive.
void ApplicationWillResignActive(void)
{
//  NSLog(@"ApplicationWillResignActive");
  if (MainViewController != nil)
  {
    [MainViewController applicationWillResignActive];
  }
}
//__________________________________________________________________________________________________

//! Perform background data fetch.
void PerformBackgroundFetch(BlockBoolAction completion)
{
  if (MainViewController != nil)
  {
    [MainViewController performBackgroundFetch:^(BOOL hasNewData)
    {
      completion(hasNewData);
    }];
  }
  else
  {
    completion(NO);
  }
}
//__________________________________________________________________________________________________
