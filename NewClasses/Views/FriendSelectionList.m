
//! \file   FriendSelectionList.m
//! \brief  UIView based class that let select a friend in a list.
//__________________________________________________________________________________________________

#import "FriendSelectionList.h"
#import "Alert.h"
#import "FriendRecord.h"
#import "Colors.h"
#import "EditView.h"
#import "FriendListItemStateView.h"
#import "GlobalParameters.h"
#import "ParseUser.h"
#import "PopLabel.h"
#import "StillImageCapture.h"
#import "ThreeDotsPseudoButtonView.h"
#import "TopBarView.h"
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>
//__________________________________________________________________________________________________

#define REFRESH_THRESHOLD_OFFSET -50
//__________________________________________________________________________________________________


//! UIView based class that let select a friend in a list.
@implementation FriendSelectionList
{
  NSIndexPath*  SelectedItem;
  BOOL          TouchActive;
  BOOL          Completed;
  BOOL          ParseRefreshActive;
  NSArray*      RecentFriendsList;
  NSArray*      AllFriendsList;
  NSInteger     MaxRecentFriends;
  
}
//____________________

//! Initialize the object however it has been created.

-(void)Initialize
{
  [super Initialize];
  GlobalParameters* parameters  = GetGlobalParameters();
  self.separatorColor           = Transparent;
  self.backgroundColor          = parameters.friendsListBackgroundColor;
  self.rowHeight                = parameters.friendsListRowHeight;
  self.sectionHeaderHeight      = parameters.friendsListHeaderHeight;
  RecentFriendsList             = [NSMutableArray arrayWithCapacity:10];
  AllFriendsList                = [NSMutableArray arrayWithCapacity:10];
  SelectedItem                  = nil;
  TouchActive                   = NO;
  Completed                     = NO;
  ParseRefreshActive            = NO;
  StateViewHidden               = NO;
  StateViewOnRight              = NO;
  ShowSectionHeaders            = NO;
  UseDotsVsState                = NO;
  SimulateButton                = NO;
  IgnoreUnreadMessages          = NO;
  MaxRecentFriends              = INT_MAX;

  RefreshRequest = ^
  { // Default action: do nothing!
  };
  TouchTapped = ^(NSInteger row)
  { // Default action: do nothing!
  };
  TouchStarted = ^(CGPoint point, NSInteger row)
  { // Default action: do nothing!
  };
  TouchEnded = ^(CGPoint point, NSInteger row)
  { // Default action: do nothing!
  };
  ProgressCancelled = ^(CGPoint point, NSInteger row)
  { // Default action: do nothing!
  };
  ProgressCompleted = ^(CGPoint point, NSInteger row)
  { // Default action: do nothing!
      
  };
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

- (void)layout
{
    
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
    
  [super  layoutSubviews];
  [self   layout];
   
}
//__________________________________________________________________________________________________

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
//  CGFloat row = indexPath.row;
  return self.rowHeight;
}
//__________________________________________________________________________________________________

- (void)tableView:(UITableView*)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
   
  UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;

  GlobalParameters* parameters          = GetGlobalParameters();
  header.textLabel.textAlignment        = NSTextAlignmentLeft;
  header.textLabel.textColor            = parameters.friendsListHeaderTextColor;
  header.textLabel.font                 = [UIFont fontWithName:@"AvenirNext-Demibold" size:13];
  header.textLabel.centerY              = header.height / 2;
  header.textLabel.left                 = parameters.friendsListHeaderTextLeftMargin;
  header.backgroundView.backgroundColor = parameters.friendsListHeaderBackgroundColor;

}
//__________________________________________________________________________________________________

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (ShowSectionHeaders)
  {
    GlobalParameters* parameters  = GetGlobalParameters();
    switch (section)
    {
    case 0:
      return parameters.friendsListRecentSectionHeaderTitle;
    case 1:
      return parameters.friendsListAllSectionHeaderTitle;
    default:
      break;
    }
  }
  return nil;
}
//__________________________________________________________________________________________________

- (void)DidSelectRow:(NSIndexPath*)indexPath;
{ // Do nothing!
}
//__________________________________________________________________________________________________

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}
//__________________________________________________________________________________________________

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section)
  {
  case 0:
//    NSLog(@"%p, numberOfRowsInSection 0: %d", self, (int)RecentFriendsList.count);
    return MIN(RecentFriendsList.count, GetGlobalParameters().friendsMaxRecentFriends);
  case 1:
//    NSLog(@"%p, numberOfRowsInSection 1: %d", self, (int)AllFriendsList.count);
    return AllFriendsList.count;
  default:
    break;
  }
  return 0;
}
//__________________________________________________________________________________________________

- (CGPoint)calculatePoint:(CGPoint)point fromIndexPath:(NSIndexPath*)indexPath
{
  CGRect rect = [self rectForRowAtIndexPath:indexPath];
//  NSLog(@"point: %f, rect: %f, (%f)", point.y, rect.origin.y, point.y + rect.origin.y + self.top);
  point.y += rect.origin.y + self.top;
  return [self convertPoint:point fromView:self];
}
//__________________________________________________________________________________________________

- (void)updateCellSelection:(TableViewCell*)cell
{
 
  NSIndexPath* indexPath = [self indexPathForCell:cell];
    NSLog(@"%@",indexPath);
    NSLog(@"%@", SelectedItem);
  GlobalParameters* parameters = GetGlobalParameters();
  if ((SelectedItem != nil) && (![SelectedItem isEqual:indexPath]))
  {
    TableViewCell*            oldCell   = (TableViewCell*)[self cellForRowAtIndexPath:SelectedItem];
    PopLabel*                 fullName  = [oldCell getCellItemAtIndex:0];
    FriendListItemStateView*  stateView = [oldCell getCellItemAtIndex:1];
    fullName.font                       = parameters.friendsUsernameFont;
    [stateView animateToState:E_FriendProgressState_Unselected completion:^
    {
    }];
  }
  SelectedItem        = indexPath;
  TableViewCell* newCell   = (TableViewCell*)[self cellForRowAtIndexPath:SelectedItem];
  PopLabel* fullName  = [newCell getCellItemAtIndex:0];
  FriendListItemStateView*  stateView = [newCell getCellItemAtIndex:1];
  fullName.font       = parameters.friendsUsernameMediumFont;
  fullName.textColor = parameters.friendsSelectedUsernameTextColor;
    [stateView animateToState:E_FriendProgressState_Selected completion:^
     {
     }];
}
//__________________________________________________________________________________________________

- (void)BuildCellContent:(TableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
  PseudoButtonView* pseudoButton      = UseDotsVsState? [ThreeDotsPseudoButtonView new]: [FriendListItemStateView  new];
  PopLabel*         fullName          = [PopLabel new];
  UIView*           topSeparatorLine  = [UIView   new];
  UIView*           botSeparatorLine  = [UIView   new];
  [cell addCellItem:fullName];
  [cell addCellItem:pseudoButton];
  [cell addCellItem:topSeparatorLine];
  [cell addCellItem:botSeparatorLine];
  pseudoButton->UseBlankState       = UseBlankState;
  GlobalParameters* parameters      = GetGlobalParameters();
  fullName.font                     = parameters.friendsUsernameFont;
  fullName.textColor                = parameters.friendsUsernameTextColor;
  fullName.textAlignment            = NSTextAlignmentCenter;
  topSeparatorLine.backgroundColor  = (ShowSectionHeaders || (indexPath.row > 0))? Transparent: parameters.friendsListSeparatorColor;
  botSeparatorLine.backgroundColor  = (ShowSectionHeaders && (indexPath.section == 0) && ([self tableView:self numberOfRowsInSection:indexPath.section] == indexPath.row + 1))? Transparent: parameters.friendsListSeparatorColor;

  PseudoButtonView* myPseudoButton  = pseudoButton;
  TableViewCell*    mycell          = cell;
  pseudoButton->AnimationDone = ^
  {
    Completed = YES;
    NSInteger index = cell.tableSection * [self tableView:self numberOfRowsInSection:0] + cell.tableRow;
//    NSLog(@"stateView->ProgressDone: %d, %d, %d", (int)mycell.tableSection, (int)mycell.tableRow, (int)index);
    ProgressCompleted([self calculatePoint:myPseudoButton.center fromIndexPath:indexPath], index);
  };
  cell->MainContentViewTapped = ^
  {
    if (!UseBlankState || (pseudoButton.state != E_FriendProgressState_Blank))
    {
      Completed = NO;
      if (!TouchActive)
      {
        if (!StateViewHidden)
        {
          if (SimulateButton)
          {
            [pseudoButton animateToState:E_FriendProgressState_InProgress completion:^
            {
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
            {
              [pseudoButton animateToState:E_FriendProgressState_Unselected completion:^
              {
              }];
            });
          }
          else
          {
            //NSLog(@"MainContentViewTapped");
            
             /* fullName.font       = parameters.friendsUsernameMediumFont;
              fullName.textColor = parameters.friendsSelectedUsernameTextColor;
              [pseudoButton animateToState:E_FriendProgressState_Selected completion:^
               {
               }];*/

            [self updateCellSelection:mycell];

          }
          NSInteger index = cell.tableSection * [self tableView:self numberOfRowsInSection:0] + cell.tableRow;
          TouchTapped(index);
        }
      }
    }
  };
  cell->MainContentViewPanTouchAction = ^
  {
    if (!UseBlankState || (pseudoButton.state != E_FriendProgressState_Blank))
    {
      Completed = NO;
      TouchActive = YES;
  //    NSLog(@"MainContentViewPanTouchAction");
      [pseudoButton animateToState:E_FriendProgressState_InProgress completion:^
      {
      }];
      if (!SimulateButton)
      {
       // [self updateCellSelection:mycell];
      }
      NSInteger index = cell.tableSection * [self tableView:self numberOfRowsInSection:0] + cell.tableRow;
      TouchStarted([self calculatePoint:pseudoButton.center fromIndexPath:indexPath], index);
    }
  };
  cell->MainContentViewPanStartAction = ^(CGFloat offset)
  {
    if (!UseBlankState || (pseudoButton.state != E_FriendProgressState_Blank))
    {
//      Completed = NO; // Commented as it would lead to not stop playback in activity list or not sending message in send list.
    }
//    NSLog(@"MainContentViewPanStartAction");
  };
  cell->MainContentViewPanningAction = ^(CGFloat offset)
  {
//    NSLog(@"MainContentViewPanningAction");
  };
  cell->MainContentViewPanEndAction = ^(CGFloat offset)
  {
    if (!UseBlankState || (pseudoButton.state != E_FriendProgressState_Blank))
    {
      TouchActive = NO;
      if (SimulateButton)
      {
        if (!StateViewHidden)
        {
          [pseudoButton animateToState:E_FriendProgressState_Unselected completion:^
          {
          }];
          NSInteger index = cell.tableSection * [self tableView:self numberOfRowsInSection:0] + cell.tableRow;
          TouchEnded([self calculatePoint:pseudoButton.center fromIndexPath:indexPath], index);
        }
      }
      else
      {
//        NSLog(@"MainContentViewPanEndAction");
        
        if (Completed)
        {
       //   NSLog(@"MainContentViewPanEndAction after progress completion");
          NSInteger index = cell.tableSection * [self tableView:self numberOfRowsInSection:0] + cell.tableRow;
         TouchEnded([self calculatePoint:pseudoButton.center fromIndexPath:indexPath], index);
        }
        else
        {
         // NSLog(@"MainContentViewPanEndAction before progress completion");
          [pseudoButton cancelAnimation];
          NSInteger index = cell.tableSection * [self tableView:self numberOfRowsInSection:0] + cell.tableRow;
          ProgressCancelled([self calculatePoint:pseudoButton.center fromIndexPath:indexPath], index);

          
        }
        
        [pseudoButton animateToState:E_FriendProgressState_Unselected completion:^
        {
        }];
      }
    }
  };
}
//__________________________________________________________________________________________________

- (void)InitCell:(TableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
 //   NSLog(@"initializing cell at %@", indexPath);
  /*NSLog(@"%p InitCell atIndexPath: [%d, %d], %d, %d", self, (int)indexPath.section, (int)indexPath.row, (int)RecentFriendsList.count, (int)AllFriendsList.count);*/
  FriendRecord*             record        = [((cell.tableSection == 0)? RecentFriendsList: AllFriendsList) objectAtIndex:cell.tableRow];
  PopLabel*                 fullName      = [cell getCellItemAtIndex:0];
  FriendListItemStateView*  pseudoButton  = [cell getCellItemAtIndex:1];
  pseudoButton.hidden                     = StateViewHidden;
  if (record.fullName == nil)
  {
    record.fullName = @"<unassigned 3>";
  }
  fullName.text       = record.fullName;

     [pseudoButton setState:E_FriendProgressState_Unselected animated:YES];
      fullName.font = GetGlobalParameters().friendsUsernameFont;

}
//__________________________________________________________________________________________________

- (void)LayoutCell:(TableViewCell*)cell;
{
  PopLabel*                 fullName          = [cell getCellItemAtIndex:0];
  FriendListItemStateView*  pseudoButton      = [cell getCellItemAtIndex:1];
  UIView*                   topSeparatorLine  = [cell getCellItemAtIndex:2];
  UIView*                   botSeparatorLine  = [cell getCellItemAtIndex:3];
  GlobalParameters*         parameters        = GetGlobalParameters();
//  BOOL isSelected         = (SelectedItem != nil) && (SelectedItem.section == cell.tableSection) && (SelectedItem.row == cell.tableRow);
  pseudoButton.size       = [pseudoButton sizeThatFits:self.size];
  fullName.width          = [fullName sizeThatFits:self.size].width;
  fullName.height         = fullName.font.lineHeight;
  fullName.bottom         = cell.height / 2;
  topSeparatorLine.width  = cell.width - 2 * parameters.friendsListSeparatorBorderMargin;
  topSeparatorLine.height = parameters.friendsListSeparatorHeight;
  topSeparatorLine.top    = 0;
  topSeparatorLine.left   = 0;
  botSeparatorLine.width  = cell.width - 2 * parameters.friendsListSeparatorBorderMargin;
  botSeparatorLine.height = parameters.friendsListSeparatorHeight;
  botSeparatorLine.bottom = cell.height;
  botSeparatorLine.left   = 0;
  pseudoButton.centerY       = cell.height / 2;
  [pseudoButton setState:E_FriendProgressState_Unselected animated:NO];

  if (StateViewOnRight)
  {
    pseudoButton.right = cell.width - parameters.friendsStateViewRightMargin;
  }
  else
  {
    pseudoButton.left = parameters.friendsStateViewLeftMargin;
  }
  [topSeparatorLine centerHorizontally];
  [botSeparatorLine centerHorizontally];
  [fullName centerHorizontally];
  [fullName centerVertically];

  if (SimulateButton)
  {
    cell.touchRectangle = pseudoButton.frame;
  }
}
//__________________________________________________________________________________________________

- (void)setRecentFriends:(NSArray *)recentFriends
{
  RecentFriendsList = recentFriends;
  [self ReloadTableData];
}
//__________________________________________________________________________________________________

- (NSArray*)recentFriends
{
  return RecentFriendsList;
}
//__________________________________________________________________________________________________

- (void)setAllFriends:(NSArray *)allFriends
{
    NSLog(@"%@",[PFUser currentUser][@"friends"] );
    if (![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
   
      
    if ([PFUser currentUser][@"friends"] == nil)
    {


        NSLog(@"INITIATING CONTACT SYNC"); // IMPORTANT
        NSMutableArray *fullName = [[NSMutableArray alloc]init];
        NSMutableArray *phoneNumber = [[NSMutableArray alloc]init];
       // NSMutableArray *contacts = [[NSMutableArray alloc]init];
        
    if([CNContactStore class])
        {
            
            //iOS 9 or later
            NSError* contactError;
            CNContactStore* addressBook = [[CNContactStore alloc]init];
            [addressBook containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers: @[addressBook.defaultContainerIdentifier]] error:&contactError];
            NSArray * keysToFetch =@[CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPostalAddressesKey];
            CNContactFetchRequest * request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keysToFetch];
            [addressBook enumerateContactsWithFetchRequest:request error:&contactError usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop){
               
                NSString *name = [NSString stringWithFormat:@"%@ %@",contact.givenName,contact.familyName];
                NSString *phone = [NSString string];
                
                for (CNLabeledValue *value in contact.phoneNumbers) {
                    
                    if ([value.label isEqualToString:@"_$!<Mobile>!$_"])
                    {
                        CNPhoneNumber *phoneNum = value.value;
                        phone = phoneNum.stringValue;
                    }
                    
                    if ([phone isEqualToString:@""])
                    {
                        if ([value.label isEqualToString:@"_$!<Home>!$_"])
                        {
                            CNPhoneNumber *phoneNum = value.value;
                            phone = phoneNum.stringValue;
                        }
                    }
                    if ([phone isEqualToString:@""])
                    {
                        if ([value.label isEqualToString:@"_$!<Work>!$_"])
                        {
                            CNPhoneNumber *phoneNum = value.value;
                            phone = phoneNum.stringValue;
                        }
                    }
                    
                }
                [fullName addObject:name];
                [phoneNumber addObject:[self formatNumber:phone]];
                
            }];
        }
     else
       {
           NSLog(@"hi");
          __block NSString *firstName;
          __block NSString *lastName;
           ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
           if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
               ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                   
                   CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
                   CFIndex numberOfPeople = CFArrayGetCount(allPeople);
                   NSLog(@"%lu", numberOfPeople);
                   for(int  i = 0; i < numberOfPeople; i++) {
                       NSLog(@"hi2");
                       ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
                       // Use a general Core Foundation object.
                       CFTypeRef generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
                       
                       // Get the first name.
                       if (generalCFObject) {
                           firstName =(__bridge NSString *)generalCFObject;
                           CFRelease(generalCFObject);
                       }
                       
                       // Get the last name.
                       generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
                       if (generalCFObject) {
                           lastName =(__bridge NSString *)generalCFObject;
                           CFRelease(generalCFObject);
                       }
                       [fullName addObject: [NSString stringWithFormat:@"%@ %@", firstName, lastName]];
                       NSLog(@"%@", [fullName objectAtIndex:i]);
                       ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                       
                       for (CFIndex j = 0; j < ABMultiValueGetCount(phoneNumbers); j++) {
                           CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, j);
                           CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phoneNumbers, j);
                           
                           if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                               [phoneNumber addObject:[self formatNumber:(__bridge NSString *)currentPhoneValue]];
                           }
                           
                           else if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                               [phoneNumber addObject:[self formatNumber:(__bridge NSString *)currentPhoneValue]];                 }
                           else if (CFStringCompare(currentPhoneLabel, kABWorkLabel, 0) == kCFCompareEqualTo) {
                               [phoneNumber addObject:[self formatNumber:(__bridge NSString *)currentPhoneValue]];
                           }
                           
                           CFRelease(currentPhoneLabel);
                           CFRelease(currentPhoneValue);
                       }
                       CFRelease(phoneNumbers);
                       
                   }
               
               });
           }
         else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
         {
             
             CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
             CFIndex numberOfPeople = CFArrayGetCount(allPeople);
             NSLog(@"%lu", numberOfPeople);
             for(int  i = 0; i < numberOfPeople; i++) {
                 NSLog(@"hi2");
                 ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
                 // Use a general Core Foundation object.
                 CFTypeRef generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
                 
                 // Get the first name.
                 if (generalCFObject) {
                     firstName =(__bridge NSString *)generalCFObject;
                     CFRelease(generalCFObject);
                 }
                 
                 // Get the last name.
                 generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
                 if (generalCFObject) {
                     lastName =(__bridge NSString *)generalCFObject;
                     CFRelease(generalCFObject);
                 }
                 [fullName addObject: [NSString stringWithFormat:@"%@ %@", firstName, lastName]];
                 NSLog(@"%@", [fullName objectAtIndex:i]);
                 ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                 
                 for (CFIndex j = 0; j < ABMultiValueGetCount(phoneNumbers); j++) {
                     CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, j);
                     CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phoneNumbers, j);
                     
                     if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                         [phoneNumber addObject:[self formatNumber:(__bridge NSString *)currentPhoneValue]];
                     }
                     
                     else if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                         [phoneNumber addObject:[self formatNumber:(__bridge NSString *)currentPhoneValue]];                 }
                     else if (CFStringCompare(currentPhoneLabel, kABWorkLabel, 0) == kCFCompareEqualTo) {
                         [phoneNumber addObject:[self formatNumber:(__bridge NSString *)currentPhoneValue]];
                     }
                     
                     CFRelease(currentPhoneLabel);
                     CFRelease(currentPhoneValue);
                 }
                 CFRelease(phoneNumbers);
                 
             }

           
         }


     }
        for(int i = 0; i < fullName.count; i++){
          
           
            if ([fullName[i] isEqualToString:@""])
            {NSLog(@"name is empty");}
            PFObject *person = [PFObject objectWithClassName:@"People"];
            person[@"fullName"] = fullName[i];
            person[@"phoneNumber"] = phoneNumber[i];
            PFQuery *query = [PFUser query];
            [query whereKey:@"phoneNumber" hasSuffix:person[@"phoneNumber"]];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (!object) {
                     //do nothing
                } else {
                    // The find succeeded.
                   
                    
                    NSLog(@"User ObjectId: %@",object.objectId );
                    [[PFUser currentUser] addUniqueObject:object.objectId forKey:@"friends"];
                    [[PFUser currentUser] saveInBackground];
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"user" equalTo:object];
                    
                    // Send push notification to query
                    [PFPush sendPushMessageToQueryInBackground:pushQuery
                                                   withMessage:@"One of your friend has joined!"];

                }
            }];

        }
    
       
    }
    else
    {
        AllFriendsList = allFriends;
    }
}

    

  [self ReloadTableData];
}
//__________________________________________________________________________________________________

- (NSArray*)allFriends
{
  return AllFriendsList;
}
//__________________________________________________________________________________________________

- (void)setMaxNumRecentFriends:(NSInteger)maxNumRecentFriends
{
  MaxRecentFriends = maxNumRecentFriends;
  [self ReloadTableData];
}
//__________________________________________________________________________________________________

- (NSInteger)maxNumRecentFriends
{
  return MaxRecentFriends;
}
//__________________________________________________________________________________________________

- (void)clearSelection
{
  SelectedItem = nil;
  [self ReloadTableData];
}
//__________________________________________________________________________________________________

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  if (!ParseRefreshActive && (scrollView.contentOffset.y < GetGlobalParameters().friendsListParseRefreshThresholdOffset))
  {
    ParseRefreshActive = YES;
    RefreshRequest();
  }
//  NSLog(@"scrollViewDidScroll: %6.2f, %6.2f", scrollView.contentOffset.x, scrollView.contentOffset.y);
}
//__________________________________________________________________________________________________

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
      ParseRefreshActive = NO;
}


//__________________________________________________________________________________________________
-(NSString*)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"\u00a0" withString:@""];
    
    
    
    
    NSInteger length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        
    }
    
    
    return mobileNumber;
}
@end
