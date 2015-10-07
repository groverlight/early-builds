
//! \file   NavigationView.m
//! \brief  BaseView based class that manages the navigation between the main views.
//__________________________________________________________________________________________________

#import "NavigationView.h"
#import "ActivityFriendSelectionView.h"
#import "AzFriendSelectionView.h"
#import "FriendRecord.h"
#import "FriendSelectionView.h"
#import "GlobalParameters.h"
#import "HeaderBarView.h"
#import "Interpolation.h"
#import "LoginView.h"
#import "PagedScrollView.h"
#import "Parse.h"
#import "PlayerView.h"
#import "SendToFriendSelectionView.h"
#import "TypingView.h"
#import "Tools.h"
#import "UnreadMessages.h"
//__________________________________________________________________________________________________

//! \brief  BaseView based class that manages the navigation between the main views.
@interface NavigationView()
{
  ActivityFriendSelectionView*  ActivityListView;
  AzFriendSelectionView*        AzFriendsListView;
  SendToFriendSelectionView*    SendToListView;
  HeaderBarView*                HeaderBar;
  PagedScrollView*              ScrollView;
  TypingView*                   TypingMessageView;
  BaseView*                     FriendsBundleView;
  LoginView*                    Login;
  PlayerView*                   Player;
  BlockBoolAction               PreviewChunkCompletionAction;
  BlockBoolAction               PlayerChunkCompletionAction;
  CGPoint                       FinalPlayerPoint;
  Message*                      MessageToSend;
  Message*                      MessageToPlay;
  NSInteger                     PreviewingForFriend;
  NSInteger                     PlayingForFriend;
  CGFloat                       LeftVerticalOffset;
  CGFloat                       MidVerticalOffset;
  CGFloat                       RightVerticalOffset;
  BOOL                          StartSending;
  BOOL                          PreviewEndPostponed;
}
@end
//__________________________________________________________________________________________________

static NavigationView* Myself;
//__________________________________________________________________________________________________


//! \brief  UIView based class that manages navigation through a stack of card views.
@implementation NavigationView

//! Initialize the object however it has been created.
-(void)Initialize
{
  Myself = self;
//  NSLog(@"1 Initialize");
  [super Initialize];
  StartSending        = NO;
  PreviewEndPostponed = NO;
//  NSLog(@"2 Initialize");
  HeaderBar         = [HeaderBarView                new];
//  NSLog(@"3 Initialize");
  ScrollView        = [PagedScrollView              new];
//  NSLog(@"4 Initialize");
  ActivityListView  = [ActivityFriendSelectionView  new];
//  NSLog(@"5 Initialize");
  TypingMessageView = [TypingView                   new];
//  NSLog(@"6 Initialize");
  FriendsBundleView = [BaseView                     new];
//  NSLog(@"7 Initialize");
  AzFriendsListView = [AzFriendSelectionView        new];
//  NSLog(@"8 Initialize");
  SendToListView    = [SendToFriendSelectionView    new];
//  NSLog(@"9 Initialize");
  Login             = [LoginView                    new];
//  NSLog(@"10 Initialize");
  Player            = [PlayerView                   new];
//  NSLog(@"11 Initialize");

  LeftVerticalOffset  = 0.0;
  MidVerticalOffset   = 0.0;
  RightVerticalOffset = 0.0;

  GlobalParameters* parameters = GetGlobalParameters();
  ScrollView.bounces           = parameters.navigatorScrollViewBounces;

  [self addSubview:ScrollView];
  [self addSubview:HeaderBar];
  [self addSubview:Login];
  [self addSubview:Player];
  [ScrollView addPageView:ActivityListView];
  [ScrollView addPageView:TypingMessageView];
  [ScrollView addPageView:FriendsBundleView];
  [FriendsBundleView  addSubview:AzFriendsListView];
  [FriendsBundleView  addSubview:SendToListView];

  ScrolledToRecentActivityPage = ^
  { // Default action: do nothing!
  };
  ScrolledToTypingPage = ^
  { // Default action: do nothing!
  };
  ScrolledToFriendsPage = ^
  { // Default action: do nothing!
      
  };
  PleaseBlurByThisFactorAction = ^(CGFloat blurFactor)
  { // Default action: do nothing!
  };
  PleaseFlashForDuration = ^(CGFloat duration, BlockAction completion)
  { // Default action: do nothing!
  };

  set_myself;
  HeaderBar->ItemSelectedAction = ^(NSInteger index)
  {
    get_myself;
    [myself->ScrollView ScrollToPageAtIndex:index animated:YES];
  };

  TypingMessageView->PleaseFlashForDuration = ^(CGFloat duration, BlockAction completion)
  {
    get_myself;
    myself->PleaseFlashForDuration(duration, completion);
  };

  TypingMessageView->GoButtonPressed = ^
  {
    get_myself;
//    NSLog(@"-------- GoButtonPressed! --------");
    [myself ScrollToSendToPageAnimated:YES];
//    [myself->TypingMessageView clearText];
  };

  ScrollView->ScrolledToPageAction = ^(NSInteger page)
  {
//    NSLog(@"ScrollView->ScrolledToPageAction");
    get_myself;
    switch (page)
    {
    case 0:
      [[UIResponder currentFirstResponder] resignFirstResponder];
      {
        [UIView animateWithDuration:0.2 animations:^
        {
          myself.top = myself->LeftVerticalOffset;
        }];
      }
      myself->ScrolledToRecentActivityPage();
      break;
    case 1:
      {
        [UIView animateWithDuration:0.2 animations:^
        {
          myself.top = myself->MidVerticalOffset;
        }];
      }
      myself->ScrolledToTypingPage();
      [myself->TypingMessageView activate];
      [myself activateFriendsListView];
      break;
    case 2:
      {
          
          myself.top = myself->RightVerticalOffset;
       /*   NSLog(@"Activity: %p, typing: %p, AZ: %p, Send: %p", myself->ActivityListView, myself->TypingMessageView, myself->AzFriendsListView, myself->SendToListView);*/
        [UIView animateWithDuration:0.2 animations:^
        {
          myself.top = myself->RightVerticalOffset;
        } completion:^(BOOL finished)
        {
          [[UIResponder currentFirstResponder] resignFirstResponder];
          if (myself->AzFriendsListView.alpha > 0.0)
          {
            [myself->AzFriendsListView activate];
          }
          else
          {
            [myself->SendToListView activate];
          }
        }];
      }
      myself->ScrolledToFriendsPage();
      break;
    default:
      break;
    }
  };

  ScrollView->ScrollingTouchUp = ^(NSInteger page)
  {
    get_myself;
    [myself->HeaderBar SelectItemAtIndex:page];
  };

  ScrollView->ScrollingWithPageFractionAction = ^(CGFloat pageFraction)
  {
    get_myself;
    if (pageFraction < 1.0)
    {
      myself->PleaseBlurByThisFactorAction(1.0 - pageFraction);
      myself.top = InterpolateFloat(pageFraction, myself->LeftVerticalOffset, myself->MidVerticalOffset);
    }
    else
    {
      myself->PleaseBlurByThisFactorAction(pageFraction - 1.0);
      myself.top = InterpolateFloat(pageFraction - 1, myself->MidVerticalOffset, myself->RightVerticalOffset);
    }
    if (myself->ScrollView->Scrolling)
    {
      [myself->HeaderBar scrollUnderlineByFactor:pageFraction];
    }
  };

  AzFriendsListView->PleaseUpdateFriendLists = ^
  {
    get_myself;
    RefreshAllFriends(^
    {
      [myself updateFriendsLists];
      UnreadMessages* unreadMsgs = GetSharedUnreadMessages();
      ParseSetBadge(unreadMsgs->Messages.count);  // Update the icon badge number with the number of unread messages.
      if (unreadMsgs->Messages.count > 0)
      {
        [myself bounceLeftItemDot];
      }
      else
      {
        [myself hideLeftItemDot];
      }
    });
  };

  AzFriendsListView->MoveParentByVerticalOffset = ^(CGFloat verticalOffset, BlockAction completion)
  {
    get_myself;
    myself->RightVerticalOffset = verticalOffset;
    [UIView animateWithDuration:0.2 animations:^
    {
      myself.top = verticalOffset;
    } completion:^(BOOL finished)
    {
      completion();
    }];
  };

  AzFriendsListView->TouchTapped = ^(NSInteger tableIndex)
  {
    get_myself;
    myself->ScrollView.scrollView.scrollEnabled = NO;
//    NSLog(@"AzFriendsListView->TouchTapped disable scroll: %d", myself->ScrollView.scrollView.scrollEnabled);
    [myself->AzFriendsListView showMenuForFriendIndex:tableIndex completion:^
    {
      if (!myself->ScrollView.scrollView.scrollEnabled)
      {
        myself->ScrollView.scrollView.scrollEnabled = YES;
//        NSLog(@"AzFriendsListView->TouchTapped enable scroll: %d", myself->ScrollView.scrollView.scrollEnabled);
      }
    }];
  };

  AzFriendsListView->TouchStarted = ^(CGPoint point, NSInteger tableIndex)
  {
  };

  AzFriendsListView->TouchEnded = ^(CGPoint point, NSInteger tableIndex)
  {
    get_myself;
    if (!myself->ScrollView.scrollView.scrollEnabled)
    {
      myself->ScrollView.scrollView.scrollEnabled = YES;
//      NSLog(@"1 AzFriendsListView->TouchEnded enable scroll: %d", myself->ScrollView.scrollView.scrollEnabled);
    }
    [myself->AzFriendsListView showMenuForFriendIndex:tableIndex completion:^
    {
      if (!myself->ScrollView.scrollView.scrollEnabled)
      {
        myself->ScrollView.scrollView.scrollEnabled = YES;
//        NSLog(@"2 AzFriendsListView->TouchEnded enable scroll: %d", myself->ScrollView.scrollView.scrollEnabled);
      }
    }];
  };

  AzFriendsListView->AddFriendStarted = ^
  {
    get_myself;
    [myself->AzFriendsListView clearPendingFriendsList];
    myself->ScrollView.scrollView.scrollEnabled = NO;
//    NSLog(@"AzFriendsListView->EditionStarted disable scroll: %d", myself->ScrollView.scrollView.scrollEnabled);
  };

  AzFriendsListView->FriendsAdded = ^
  {
    get_myself;
    [myself updateFriendsLists];
    if (!myself->ScrollView.scrollView.scrollEnabled)
    {
      myself->ScrollView.scrollView.scrollEnabled = YES;
//      NSLog(@"AzFriendsListView->FriendsAdded enable scroll: %d", myself->ScrollView.scrollView.scrollEnabled);
    }
  };

  ActivityListView->RefreshRequest = ^
  {
    get_myself;
//    NSLog(@"ActivityListView->RefreshRequest");
    [myself loadReceivedMessages:^(BOOL hasNewData)
    { // Do nothing!
    }];
  };

  ActivityListView->TouchTapped = ^(NSInteger tableIndex)
  {
  };

  ActivityListView->TouchStarted = ^(CGPoint point, NSInteger tableIndex)
  {
    get_myself;
    myself->ScrollView.scrollView.scrollEnabled = NO;
    NSLog(@"ActivityListView->TouchStarted disable scroll: %d", myself->ScrollView.scrollView.scrollEnabled);
  };

  ActivityListView->TouchEnded = ^(CGPoint point, NSInteger tableIndex)
  {
    NSLog(@"1 ActivityListView->TouchEnded");
    FinalPlayerPoint = point;
    get_myself;
    if (!myself->ScrollView.scrollView.scrollEnabled)
    {
      myself->ScrollView.scrollView.scrollEnabled = YES;
//      NSLog(@"ActivityListView->TouchEnded enable scroll: %d", myself->ScrollView.scrollView.scrollEnabled);
    }
    NSLog(@"2 ActivityListView->TouchEnded");
    [myself hidePlayer];
    NSLog(@"3 ActivityListView->TouchEnded");
    [myself->Player stopPlayer];
    NSLog(@"4 ActivityListView->TouchEnded");
  };

  ActivityListView->ProgressCancelled = ^(CGPoint point, NSInteger tableIndex)
  {
    get_myself;
    myself->ScrollView.scrollView.scrollEnabled = YES;
    NSLog(@"ActivityListView->ProgressCancelled enable scroll: %d", myself->ScrollView.scrollView.scrollEnabled);
  };

  ActivityListView->ProgressCompleted = ^(CGPoint point, NSInteger tableIndex)
  {
    PlayingForFriend = tableIndex;
    FinalPlayerPoint = point;
    get_myself;
    UnreadMessages* messages = GetSharedUnreadMessages();
    myself->MessageToPlay = [messages getFirstMessageFromUser:[myself->ActivityListView getFriendAtIndex:tableIndex]];
    if (myself->MessageToPlay != nil)
    {
      [myself->Player prepareForFirstChunkWithMessage:myself->MessageToPlay];
      [myself->Player showAnimatedFromPoint:point andInitialRadius:parameters.friendStateViewCircleRadius completion:^
      {
//        NSLog(@"ActivityListView->ProgressCompleted showAnimatedFromPoint completed!");
        [myself->Player displayFirstChunk:myself->PlayerChunkCompletionAction];
      }];
    }
  };

  SendToListView->TouchTapped = ^(NSInteger tableIndex)
  {
  };

  SendToListView->TouchStarted = ^(CGPoint point, NSInteger tableIndex)
  {
    get_myself;
    myself->ScrollView.scrollView.scrollEnabled = NO;
//    NSLog(@"SendToListView->TouchStarted disable scroll: %d", myself->ScrollView.scrollView.scrollEnabled);
  };

  SendToListView->TouchEnded = ^(CGPoint point, NSInteger tableIndex)
  {
    get_myself;
    myself->FinalPlayerPoint = point;
    if (myself->StartSending)
    {
      myself->PreviewEndPostponed = YES;
    }
    else
    {
      if (!myself->ScrollView.scrollView.scrollEnabled)
      {
        myself->ScrollView.scrollView.scrollEnabled = YES;
      }
      NSLog(@"SendToListView->TouchEnded enable scroll: %d", myself->ScrollView.scrollView.scrollEnabled);
     
      [myself hidePlayer];
      [myself->Player stopPlayer];
    }
  };

  SendToListView->ProgressCancelled = ^(CGPoint point, NSInteger tableIndex)
  {
    get_myself;
    myself->ScrollView.scrollView.scrollEnabled = YES;
    NSLog(@"SendToListView->ProgressCancelled enable scroll: %d", myself->ScrollView.scrollView.scrollEnabled);
    
  };

  SendToListView->ProgressCompleted = ^(CGPoint point, NSInteger tableIndex)
  {
    NSLog(@"SendToListView->ProgressCompleted: %f, %f", point.x, point.y);
    get_myself;
    myself->StartSending = YES;
    myself->PreviewingForFriend = tableIndex;
    myself->FinalPlayerPoint = point;
    myself->MessageToSend = [myself->TypingMessageView buildTheMessage];

    ParseUser* friend = [myself->SendToListView getFriendAtIndex:myself->PreviewingForFriend];
    myself->MessageToSend->FromUser = GetCurrentParseUser();
    myself->MessageToSend->ToUser   = friend;
    [myself->SendToListView clearSelection];
    UpdateFriendRecordListForUser(friend, myself->MessageToSend->Timestamp);
    [myself updateFriendsLists];
    ParseSendMessage(myself->MessageToSend, ^(BOOL success, NSError *error)
    {
      NSLog(@"2 ParseSendMessage success: %d, error: %@", success, error);
      if (success)
      {
         NSString * result = [[myself->MessageToSend->Texts valueForKey:@"description"] componentsJoinedByString:@""];
          NSLog(@"%@", [NSString stringWithFormat:GetGlobalParameters().parseNotificationFormatString, GetCurrentParseUser().fullName, result]);
        ParseSendPushNotificationToUser(friend.objectId, [NSString stringWithFormat:GetGlobalParameters().parseNotificationFormatString, GetCurrentParseUser().fullName, result]);
      }
      else
      {
        NSLog(@"Failed to save animation with error: %@", error);
      }
    });
    [myself->TypingMessageView clearText];

    [myself->Player prepareForFirstChunkWithMessage:myself->MessageToSend];
    [myself->Player showAnimatedFromPoint:point andInitialRadius:parameters.friendStateViewCircleRadius completion:^
    {
      NSLog(@"SendToListView->ProgressCompleted showAnimatedFromPoint completed!");
      [Myself->Player displayFirstChunk:myself->PreviewChunkCompletionAction];
      Myself->StartSending = NO;
      if (Myself->PreviewEndPostponed)
      {
        NSLog(@"SendToListView->ProgressCompleted PreviewEndPostponed: Player:%p", myself->Player);
        [Myself hidePlayer];
        [Myself->Player stopPlayer];
        Myself->PreviewChunkCompletionAction(YES);
        Myself->PreviewEndPostponed = NO;
      }
    }];
  };

  PreviewChunkCompletionAction = ^(BOOL done)
  {
    get_myself;
    NSLog(@"1 PreviewChunkCompletionAction done: %d", done);
    if (done)
    {
      myself->ScrollView.scrollView.scrollEnabled = YES;
      NSLog(@"3 PreviewChunkCompletionAction enable scroll: %d", myself->ScrollView.scrollView.scrollEnabled);
      [myself hidePlayer];
    }
    else
    {
      NSLog(@"4 PreviewChunkCompletionAction displayNextChunk");
      [myself->Player displayNextChunk:myself->PreviewChunkCompletionAction];
    }
  };

  PlayerChunkCompletionAction = ^(BOOL done)
  {
    get_myself;
//    NSLog(@"PlayerChunkCompletionAction");
    if (done)
    {
      if (!myself->ScrollView.scrollView.scrollEnabled)
      {
        UnreadMessages* messages = GetSharedUnreadMessages();
        [messages deleteMessage:myself->MessageToPlay];
        ParseSetBadge(messages->Messages.count);  // Update the icon badge number with the number of unread messages.
        if (messages->Messages.count == 0)
        {
          [myself hideLeftItemDot];
        }
        UpdateFriendRecordListForMessages(messages, ^(BOOL changed)
        {
          [myself updateFriendsLists];
          ParseDeleteMessage(myself->MessageToPlay, ^(BOOL success, NSError* error)
          {
            if (error != nil)
            {
              NSLog(@"ParseDeleteMessage failed with error: %@", error);
            }
          });
        });
      }
      myself->ScrollView.scrollView.scrollEnabled = YES;
      NSLog(@"PlayerChunkCompletionAction enable scroll: %d", myself->ScrollView.scrollView.scrollEnabled);
      [myself hidePlayer];
    }
    else
    {
      [myself->Player displayNextChunk:myself->PlayerChunkCompletionAction];
    }
  };

  Login.loginDoneAction = ^(BOOL newUser)
  {
    get_myself;
    GetGlobalParameters().loginDone(newUser);
//    [myself->OverlayView showHomeCardAnimated:NO];
    [myself ScrollToTypingPageAnimated:NO];
    [myself->HeaderBar  showAnimated:YES];
    [myself->Login      hideAnimated:YES];
  };

  [Login hideAnimated:NO];
}
//__________________________________________________________________________________________________

- (void)hidePlayer
{
  [self ScrollToActivityPageAnimated:NO];
  [Player hideAnimatedToPoint:FinalPlayerPoint andInitialRadius:GetGlobalParameters().friendStateViewCircleRadius completion:^
  {
    NSLog(@"[NavigationView HidePlayer] -> hideAnimatedToPoint completed!");
  }];
}
//__________________________________________________________________________________________________

- (void)dealloc
{
  [self cleanup];
}
//__________________________________________________________________________________________________

- (void)cleanup
{
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
//  NSLog(@"CardNavigationOverlayView layoutSubviews");
  [super layoutSubviews];
  CGRect frame            = self.bounds;
  frame.size              = [HeaderBar sizeThatFits:frame.size];
  HeaderBar.frame         = frame;
  frame.size.height       = self.bounds.size.height;
  ScrollView.frame        = frame;
  Player.frame            = frame;
  Login.frame             = frame;
  frame                   = FriendsBundleView.bounds;
  AzFriendsListView.frame = frame;
  SendToListView.frame    = frame;

}
//__________________________________________________________________________________________________

- (void)activateFriendsListView
{
  AzFriendsListView.hidden  = NO;
  SendToListView.hidden     = YES;
}
//__________________________________________________________________________________________________

- (void)activateSendToListView
{
  AzFriendsListView.hidden  = YES;
  SendToListView.hidden     = NO;
}
//__________________________________________________________________________________________________

- (void)ScrollToPageAtIndex:(NSInteger)pageIndex animated:(BOOL)animated
{
  [ScrollView ScrollToPageAtIndex:pageIndex animated:animated];
  [HeaderBar SelectItemAtIndex:pageIndex];
}
//__________________________________________________________________________________________________

- (void)ScrollToActivityPageAnimated:(BOOL)animated
{
  [ActivityListView updateFriendsLists];
  [self ScrollToPageAtIndex:0 animated:animated];
}
//__________________________________________________________________________________________________

- (void)ScrollToAzPageAnimated:(BOOL)animated
{
  [AzFriendsListView updateFriendsLists];
  [self activateFriendsListView];
  [self ScrollToPageAtIndex:2 animated:animated];
}
//__________________________________________________________________________________________________

- (void)ScrollToSendToPageAnimated:(BOOL)animated
{
  [SendToListView updateFriendsLists];
  [self activateSendToListView];
  [self ScrollToPageAtIndex:2 animated:animated];
}
//__________________________________________________________________________________________________

- (void)ScrollToTypingPageAnimated:(BOOL)animated
{
  [self ScrollToPageAtIndex:1 animated:animated];
}
//__________________________________________________________________________________________________

- (void)bounceLeftItemDot
{
  [HeaderBar bounceLeftItemDot];
}
//__________________________________________________________________________________________________

- (void)hideLeftItemDot
{
  [HeaderBar hideLeftItemDot];
}
//__________________________________________________________________________________________________

- (void)showPlayerFromPoint:(CGPoint)point andRadius:(CGFloat)radius completion:(BlockAction)completion
{
  [Player showAnimatedFromPoint:point andInitialRadius:radius completion:completion];
}
//__________________________________________________________________________________________________

- (void)showLoginFromStart:(BOOL)fromStart
{
  [HeaderBar  hideAnimated:YES];
  [Login      showAnimated:YES fromStart:fromStart];
}
//__________________________________________________________________________________________________

- (void)hideLogin
{
  [HeaderBar showAnimated:YES];
  [Login hideAnimated:YES];
}
//__________________________________________________________________________________________________

- (void)updateFriendsLists
{
  [ActivityListView   updateFriendsLists];
  [SendToListView     updateFriendsLists];
  [AzFriendsListView  updateFriendsLists];
}
//__________________________________________________________________________________________________

- (void) locallySaveMessageArrayInBackground
{
  LocallySaveMessageArray();
}
//__________________________________________________________________________________________________

- (void)loadReceivedMessages:(BlockBoolAction)completion
{
  NSLog(@"-- loadReceivedMessages");
  ParseLoadMessageArray(^
  {
    NSLog(@"-0 loadReceivedMessages");
    ActivityListView.busy = YES;
  }, ^(BOOL changed, NSError* loadError)
  {
    NSLog(@"00 loadReceivedMessages change: %d", changed);
    if (changed)
    {
      [self performSelectorInBackground:@selector(locallySaveMessageArrayInBackground) withObject:nil];
    }
    NSLog(@"00.1 loadReceivedMessages change: %d", changed);
    UnreadMessages* messages = GetSharedUnreadMessages();
    NSLog(@"00.2 loadReceivedMessages change: %d", changed);
    ParseLoadUsersForMessages(messages, ^
    {
      UnreadMessages* unreadMsgs = GetSharedUnreadMessages();
      ParseSetBadge(unreadMsgs->Messages.count);  // Update the icon badge number with the number of unread messages.
      if (messages != nil)
      {
        if (unreadMsgs->Messages.count > 0)
        {
          [self bounceLeftItemDot];
        }
        else
        {
          [self hideLeftItemDot];
        }
        NSLog(@"01 loadReceivedMessages");
        UpdateFriendRecordListForMessages(unreadMsgs, ^(BOOL activityChanged)
        {
          NSLog(@"02 loadReceivedMessages");
          RefreshAllFriends(^
          {
            [self updateFriendsLists];
            NSLog(@"03 loadReceivedMessages");
            ActivityListView.busy = NO;
            completion(YES);
          });
        });
      }
      else
      {
        NSLog(@"Failed to load messages with error: %@", loadError);
        ActivityListView.busy = NO;
        [self updateFriendsLists];
        completion(NO);
      }
    });
  });
}
//__________________________________________________________________________________________________

@end
