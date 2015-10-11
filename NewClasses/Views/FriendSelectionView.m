
//! \file   FriendSelectionView.m
//! \brief  UIView based class that show a list of friends and some other objects.
//__________________________________________________________________________________________________

#import "FriendSelectionView.h"
#import "FriendRecord.h"
#import "Alert.h"
#import "Colors.h"
#import "EditView.h"
#import "GlobalParameters.h"
#import "PopLabel.h"
#import "StillImageCapture.h"
#import "Tools.h"
#import "TopBarView.h"
#import "WhiteButton.h"
#import "Parse.h"
#import <contacts/contacts.h>
#import <addressbook/addressbook.h>
//__________________________________________________________________________________________________

#define TOP_OFFSET        120
#define EDITOR_TOP_OFFSET 8
//__________________________________________________________________________________________________

@interface UITextField (Selection)
- (NSRange) selectedRange;
- (void) setSelectedRange:(NSRange) range;
@end
//__________________________________________________________________________________________________

@implementation UITextField (Selection)

- (NSRange) selectedRange
{
  UITextPosition* beginning = self.beginningOfDocument;

  UITextRange* selectedRange = self.selectedTextRange;
  UITextPosition* selectionStart = selectedRange.start;
  UITextPosition* selectionEnd = selectedRange.end;

  const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
  const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];

  return NSMakeRange(location, length);
}
//____________________

- (void) setSelectedRange:(NSRange) range
{
  UITextPosition* beginning = self.beginningOfDocument;

  UITextPosition* startPosition = [self positionFromPosition:beginning offset:range.location];
  UITextPosition* endPosition = [self positionFromPosition:beginning offset:range.location + range.length];
  UITextRange* selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];

  [self setSelectedTextRange:selectionRange];
}
//____________________

@end
//==================================================================================================

//! UIView based class that show a list of friends and some other objects.
@interface FriendSelectionView () <UITextFieldDelegate>
{
}
@end
//__________________________________________________________________________________________________

//! UIView based class that show a list of friends and some other objects.
@implementation FriendSelectionView
{
  CGFloat               KeyboardHeight;             //!< The height of the currently displayed keyboard.
  CGFloat               KeyboardTop;                //!< The vertical position of the top of the keyboard.
  UIView*               TopSeparator;
  UIView*               BottomSeparator;
  UITextField*          Editor;
  WhiteButton*          InviteButton;
  WhiteButton*          AddButton;
  BOOL                  ButtonsAreVisible;
  BOOL                  EditorIsVisible;
  BOOL                  EditorIsOnTop;
  BOOL                  KeyboardSizeIsChanging;
  BOOL                  KeyboardIsVisible;
  BOOL                  UseShowKeyboard;
  BOOL                  UseHideKeyboard;
  NSString*             CurrentText;
  NSInteger             SelectedFriend;
}
//____________________

- (void)reset
{
  [self updateUI];
}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  [super Initialize];

//  [self registerForKeyboardNotifications];
  SelectedFriend                = NSNotFound;
  KeyboardTop                   = -1;
  KeyboardHeight                = 0;
  GlobalParameters* parameters  = GetGlobalParameters();
  ListName                      = [UILabel              new];
  TopSeparator                  = [UIView               new];
  BottomSeparator               = [UIView               new];
  Editor                        = [UITextField          new];
  FriendsList                   = [FriendSelectionList  new];
  InviteButton                  = [WhiteButton          new];
  AddButton                     = [WhiteButton          new];
  self.buttonsAreVisible        = NO;
  self.editorIsVisible          = NO;
  self.editorIsOnTop            = NO;
  KeyboardSizeIsChanging        = NO;
  KeyboardIsVisible             = NO;
  UseShowKeyboard               = NO;
  UseHideKeyboard               = YES;
  CurrentText                   = @"";
  self.topOffset                = 0;

  [self addSubview:ListName];
  [self addSubview:TopSeparator];
  [self addSubview:BottomSeparator];
  [self addSubview:Editor];
  [self addSubview:FriendsList];
  [self addSubview:InviteButton];
  [self addSubview:AddButton];

  InviteButton.title  = parameters.friendsInviteButtonTitle;
  AddButton.title     = parameters.friendsAddButtonTitle;


  FriendsList.maxNumRecentFriends = parameters.friendsMaxRecentFriends;
  TopSeparator.backgroundColor    = parameters.separatorLineColor;
  BottomSeparator.backgroundColor = parameters.separatorLineColor;
  ListName.textColor              = parameters.friendsLabelTitleColor;
  ListName.font                 = parameters.friendsListHeaderTextFont;
  Editor.delegate                 = self;
  Editor.returnKeyType            = UIReturnKeyDone;
  Editor.keyboardAppearance = UIKeyboardAppearanceDark;
  Editor.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  Editor.font                     = [UIFont fontWithName:@"AvenirNext-Regular" size:parameters.friendsEditorFontSize];
  Editor.autocorrectionType  = UITextAutocorrectionTypeNo;
  Editor.autocapitalizationType  = UITextAutocapitalizationTypeNone;



  Editor.attributedPlaceholder = [[NSAttributedString alloc] initWithString:parameters.friendsEditorPlaceholderText
                                                                    attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Italic" size:parameters.friendsEditorFontSize]}];

  [Editor addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
  InviteButton.alpha  = 0.0;
  AddButton.alpha     = 0.0;

  UIColor *color = [TypePink colorWithAlphaComponent:0.5];
  Editor.attributedPlaceholder = [[NSAttributedString alloc] initWithString:parameters.friendsEditorPlaceholderText
                                                                   attributes:@{NSForegroundColorAttributeName: color}];



  [[UITextField appearance] setTintColor:DarkGrey];

    Editor.textColor = WarmGrey;
  set_myself;
  RefreshRequest = ^
  { //Default action: do nothing!
  };
  TouchTapped = ^(NSInteger tableRow)
  { //Default action: do nothing!
  };
  TouchStarted = ^(CGPoint point, NSInteger tableRow)
  { //Default action: do nothing!
  };
  TouchEnded = ^(CGPoint point, NSInteger tableRow)
  { //Default action: do nothing!
  };
  ProgressCancelled = ^(CGPoint point, NSInteger tableRow)
  { //Default action: do nothing!
  };
  ProgressCompleted = ^(CGPoint point, NSInteger tableRow)
  { //Default action: do nothing!
  };
  MoveParentByVerticalOffset = ^(CGFloat verticalOffset, BlockAction completion)
  { //Default action: do nothing!
  };
  InviteButtonPressed = ^
  { //Default action: do nothing!
  };
  AddButtonPressed = ^
  { //Default action: do nothing!
  };
  EditionStarted = ^
  { //Default action: do nothing!
  };
  EditionEnded = ^
  { //Default action: do nothing!
  };
  EditedStringChanged = ^(NSString* editedString)
  { //Default action: do nothing!
  };

  FriendsList->RefreshRequest = ^
  {
    get_myself;
//    NSLog(@"FriendsList->RefreshRequest");
    myself->RefreshRequest();
  };
  FriendsList->TouchTapped = ^(NSInteger tableRow)
  {
    get_myself;
//    NSLog(@"FriendsList->TouchTapped");
    myself->TouchTapped(tableRow);
    myself->SelectedFriend = tableRow;
  };
  FriendsList->TouchStarted = ^(CGPoint point, NSInteger tableRow)
  {
    get_myself;
//    NSLog(@"FriendsList->TouchStarted");
    myself->TouchStarted(point, tableRow);
    myself->SelectedFriend = tableRow;
  };
  FriendsList->TouchEnded = ^(CGPoint point, NSInteger tableRow)
  {
    get_myself;
//    NSLog(@"FriendsList->TouchEnded");
    myself->TouchEnded(point, tableRow);
  };
  FriendsList->ProgressCancelled = ^(CGPoint point, NSInteger tableRow)
  {
    get_myself;
//    NSLog(@"FriendsList->ProgressCancelled");
    myself->ProgressCancelled(point, tableRow);
  };
  FriendsList->ProgressCompleted = ^(CGPoint point, NSInteger tableRow)
  {
    get_myself;
//    NSLog(@"FriendsList->ProgressCompleted row: %d, point: %f, %f", (int)tableRow, point.x, point.y);
    myself->ProgressCompleted(point, tableRow);
  };

  InviteButton.pressedAction = ^
  {
    get_myself;
    myself->InviteButtonPressed();
  };

  AddButton.pressedAction = ^
  {
    get_myself;
    myself->AddButtonPressed();
  };
}
//__________________________________________________________________________________________________

- (void)dealloc
{
  [self unregisterFromKeyboardNotifications];
  [self cleanup];
}
//__________________________________________________________________________________________________

- (void)cleanup
{
}
//__________________________________________________________________________________________________

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardDidShow:)
                                               name:UIKeyboardDidShowNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillBeHidden:)
                                               name:UIKeyboardWillHideNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardDidHide:)
                                               name:UIKeyboardDidHideNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillChangedFrame:)
                                               name:UIKeyboardWillChangeFrameNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardDidChangedFrame:)
                                               name:UIKeyboardDidChangeFrameNotification object:nil];
}
//__________________________________________________________________________________________________

- (void)unregisterFromKeyboardNotifications
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification         object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification          object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification         object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification          object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification  object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification   object:nil];
}
//__________________________________________________________________________________________________

//! Called when the UIKeyboardWillChangeFrameNotification is sent:
- (void)keyboardWillChangedFrame:(NSNotification*)notification
{
  KeyboardSizeIsChanging    = YES;
  NSDictionary* info        = [notification userInfo];
  CGRect keyboard_frame     = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  keyboard_frame            = [self convertRect:keyboard_frame fromView:nil];
//  NSLog(@"%p keyboardWillChangedFrame: %f, %f", self, KeyboardTop, keyboard_frame.origin.y);
  if ((keyboard_frame.origin.x == 0) && (keyboard_frame.origin.y != KeyboardTop))
  {
    KeyboardHeight  = keyboard_frame.size.height;
    KeyboardTop     = keyboard_frame.origin.y;
  }
}
//__________________________________________________________________________________________________

//! Called when the UIKeyboardDidChangeFrameNotification is sent:
- (void)keyboardDidChangedFrame:(NSNotification*)notification
{
  NSDictionary* info        = [notification userInfo];
  CGRect keyboard_frame     = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  keyboard_frame            = [self convertRect:keyboard_frame fromView:nil];
//  NSLog(@"%p keyboardDidChangedFrame: %f, %f", self, KeyboardTop, keyboard_frame.origin.y);
  if ((keyboard_frame.origin.x == 0) && (keyboard_frame.origin.y != KeyboardTop))
  {
    KeyboardHeight  = keyboard_frame.size.height;
    KeyboardTop     = keyboard_frame.origin.y;
  }
  KeyboardSizeIsChanging = NO;
}
//__________________________________________________________________________________________________

//! Called when the UIKeyboardWillShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)notification
{
  if (UseShowKeyboard)
  {
    [UIView animateWithDuration:0.2 animations:^
    {
      InviteButton.alpha = 0.0;
    }];
  }
  KeyboardIsVisible = YES;
}
//__________________________________________________________________________________________________

//! Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardDidShow:(NSNotification*)notification
{
  [self layout];
  if (UseShowKeyboard)
  {
    [UIView animateWithDuration:0.2 animations:^
    {
      InviteButton.alpha = 0.0;
      AddButton.alpha = 1.0;
    }];
    UseShowKeyboard = NO;
  }
}
//__________________________________________________________________________________________________

//! Called when the UIKeyboardWillHideNotification is sent:
- (void)keyboardWillBeHidden:(NSNotification*)notification
{
  if (UseHideKeyboard)
  {
    [UIView animateWithDuration:0.2 animations:^
    {
      AddButton.alpha = 0.0;
    }];
  }
  KeyboardIsVisible = NO;
}
//__________________________________________________________________________________________________

//! Called when the UIKeyboardWillHideNotification is sent:
- (void)keyboardDidHide:(NSNotification*)notification
{
  [self layout];
  if (UseHideKeyboard)
  {
    [UIView animateWithDuration:0.2 animations:^
    {
      AddButton.alpha = 0.0;
      InviteButton.alpha = 1.0;
    }];
    UseHideKeyboard = NO;
  }
}
//__________________________________________________________________________________________________

- (void)updateUI
{
}
//__________________________________________________________________________________________________

- (void)layout
{
  GlobalParameters* parameters  = GetGlobalParameters();
  if (KeyboardTop <= 0)
  {
    KeyboardTop = self.height;
  }
  [ListName sizeToFit];
  [ListName centerHorizontally];
  ListName.top = 86;

  CGFloat editorOffset    = -Editor.font.descender / 2;
  TopSeparator.height     = EditorIsVisible? parameters.separatorLineWidth: 0;
  TopSeparator.width      = self.width - 2 * parameters.separatorLineSideMargin;
  TopSeparator.top        = TOP_OFFSET;
  Editor.width            = self.width - 2 * parameters.friendsEditorLeftMargin;
  Editor.height           = EditorIsVisible? parameters.friendsEditorHeight: 0;
  Editor.top              = TopSeparator.bottom + editorOffset;
  BottomSeparator.height  = parameters.separatorLineWidth;
  BottomSeparator.width   = self.width - 2 * parameters.separatorLineSideMargin;
  BottomSeparator.top     = Editor.bottom - editorOffset;
  InviteButton.size       = [InviteButton  sizeThatFits:self.size];
  InviteButton.width      = parameters.friendsInviteFriendButtonWidth;
  AddButton.size          = [AddButton  sizeThatFits:self.size];
  AddButton.width         = parameters.friendsInviteFriendButtonWidth;
  if (KeyboardIsVisible)
  {
    CGFloat buttonGap     = parameters.friendsAddButtonBottomGap;
    AddButton.bottom      = KeyboardTop - parameters.typingFaceButtonGap;
    FriendsList.height    = AddButton.top - buttonGap - BottomSeparator.bottom;
  }
  else if (ButtonsAreVisible)
  {
    CGFloat buttonGap     = parameters.friendsInviteButtonBottomGap;
    InviteButton.bottom   = self.height - buttonGap;
    FriendsList.height    = InviteButton.top - (buttonGap/2) - BottomSeparator.bottom;
  }
  else
  {
    FriendsList.height    = self.height - BottomSeparator.bottom;
  }
//  NSLog(@"%p Button.bottom: %6.2f Gap: %6.2f", self, Button.bottom, buttonGap);
  FriendsList.width       = self.width;
  FriendsList.top         = BottomSeparator.top;
  
  [Editor           centerHorizontally];
  [TopSeparator     centerHorizontally];
  [BottomSeparator  centerHorizontally];
  [FriendsList      centerHorizontally];
  [InviteButton     centerHorizontally];
  [AddButton        centerHorizontally];
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
//  if (!KeyboardSizeIsChanging)
  {
    [super  layoutSubviews];
    [self   layout];
  }
}
//__________________________________________________________________________________________________

- (void)activate
{
  NSLog(@"%@", NSStringFromCGPoint(FriendsList.contentOffset));
  FriendsList.contentOffset = CGPointMake(0, 0- FriendsList.contentInset.top);
  [self contactsync];
  
  if (EditorIsOnTop)
  {
    [Editor becomeFirstResponder];
  }
  else
  {
    [Editor resignFirstResponder];
  }
}
//__________________________________________________________________________________________________

- (void)setRecentFriends:(NSArray*)recentFriends
{
  FriendsList.recentFriends = recentFriends;
}
//__________________________________________________________________________________________________

- (NSArray*)recentFriends
{
  return FriendsList.recentFriends;
}
//__________________________________________________________________________________________________

- (void)setAllFriends:(NSArray*)allFriends
{
  FriendsList.allFriends = allFriends;
}
//__________________________________________________________________________________________________

- (NSArray*)allFriends
{
  return FriendsList.allFriends;
}
//__________________________________________________________________________________________________

- (void)setStateViewOnRight:(BOOL)stateViewOnRight
{
  FriendsList->StateViewOnRight = stateViewOnRight;
}
//__________________________________________________________________________________________________

-( BOOL)stateViewOnRight
{
  return FriendsList->StateViewOnRight;
}
//__________________________________________________________________________________________________

- (void)setShowSectionHeaders:(BOOL)showSectionHeaders
{
  FriendsList->ShowSectionHeaders = showSectionHeaders;
}
//__________________________________________________________________________________________________

-( BOOL)showSectionHeaders
{
  return FriendsList->ShowSectionHeaders;
}
//__________________________________________________________________________________________________

- (void)setUseBlankState:(BOOL)useBlankState
{
  FriendsList->UseBlankState = useBlankState;
  [FriendsList ReloadTableData];
}
//__________________________________________________________________________________________________

- (BOOL)useBlankState
{
  return FriendsList->UseBlankState;
}
//__________________________________________________________________________________________________

- (void)setEditorIsVisible:(BOOL)editorIsVisible
{
  if (EditorIsVisible != editorIsVisible)
  {
    if (editorIsVisible)
    {
      [self registerForKeyboardNotifications];
    }
    else
    {
      [self unregisterFromKeyboardNotifications];
    }
  }
  EditorIsVisible     = editorIsVisible;
  Editor.hidden       = !EditorIsVisible;
  TopSeparator.hidden = !EditorIsVisible;
  [self setNeedsLayout];
}
//__________________________________________________________________________________________________

- (BOOL)editorIsVisible
{
  return EditorIsVisible;
}
//__________________________________________________________________________________________________

- (void)setButtonsAreVisible:(BOOL)buttonsAreVisible
{
  ButtonsAreVisible   = buttonsAreVisible;
  InviteButton.hidden = !ButtonsAreVisible;
  AddButton.hidden    = !ButtonsAreVisible;
  [self setNeedsLayout];
}
//__________________________________________________________________________________________________

- (BOOL)buttonsAreVisible
{
  return ButtonsAreVisible;
}
//__________________________________________________________________________________________________

- (void)setEditorIsOnTop:(BOOL)editorIsOnTop
{
  if (editorIsOnTop != EditorIsOnTop)
  {
    NSLog(@"setEditorIsOnTop: %d", editorIsOnTop);
    self.topOffset = editorIsOnTop? -(TopSeparator.bottom + EDITOR_TOP_OFFSET - GetStatusBarHeight()): 0;
    MoveParentByVerticalOffset(self.topOffset, ^
    {
      [self updateFriendsLists];
    });
  }
  EditorIsOnTop = editorIsOnTop;
  self.useBlankState = EditorIsOnTop;
  FriendsList->StateViewHidden = EditorIsOnTop;
  if (EditorIsOnTop)
  {
    [Editor becomeFirstResponder];
  }
  else
  {
    Editor.text = @"";
    [Editor resignFirstResponder];
  }
}
//__________________________________________________________________________________________________

- (BOOL)editorIsOnTop
{
  return EditorIsOnTop;
}
//__________________________________________________________________________________________________

- (void)setUseDotsVsState:(BOOL)useDotsVsState
{
  FriendsList->UseDotsVsState = useDotsVsState;
}
//__________________________________________________________________________________________________

- (BOOL)useDotsVsState
{
  return FriendsList->UseDotsVsState;
}
//__________________________________________________________________________________________________

- (void)setSimulateButton:(BOOL)simulateButton
{
  FriendsList->SimulateButton = simulateButton;
}
//__________________________________________________________________________________________________

- (BOOL)simulateButton
{
  return FriendsList->SimulateButton;
}
//__________________________________________________________________________________________________

- (void)setAddButtonEnabled:(BOOL)addButtonEnabled
{
  AddButton.enabled = addButtonEnabled;
}
//__________________________________________________________________________________________________

- (BOOL)addButtonEnabled
{
  return AddButton.enabled;
}
//__________________________________________________________________________________________________

- (void)setIgnoreUnreadMessages:(BOOL)ignoreUnreadMessages
{
  FriendsList->IgnoreUnreadMessages = ignoreUnreadMessages;
}
//__________________________________________________________________________________________________

- (BOOL)ignoreUnreadMessages
{
  return FriendsList->IgnoreUnreadMessages;
}
//__________________________________________________________________________________________________

- (void)setMaxNumRecentFriends:(NSInteger)maxNumRecentFriends
{
  FriendsList.maxNumRecentFriends = maxNumRecentFriends;
}
//__________________________________________________________________________________________________

- (NSInteger)maxNumRecentFriends
{
  return FriendsList.maxNumRecentFriends;
}
//__________________________________________________________________________________________________

- (void)updateFriendsLists
{
  [FriendsList ReloadTableData];
}
//__________________________________________________________________________________________________

- (ParseUser*)getFriendAtIndex:(NSInteger)friendIndex
{
  NSInteger recentFriendsCount = MIN(self.recentFriends.count, GetGlobalParameters().friendsMaxRecentFriends);
  if (friendIndex < recentFriendsCount)
  {
    return ((FriendRecord*)[self.recentFriends objectAtIndex:friendIndex]).user;
  }
  else
  {
    return ((FriendRecord*)[self.allFriends objectAtIndex:(friendIndex - recentFriendsCount)]).user;
  }
}
//__________________________________________________________________________________________________

- (void)clearSelection
{
  [FriendsList clearSelection];
}
//__________________________________________________________________________________________________

- (void)clearEditor
{
  Editor.text = @"";
}
//__________________________________________________________________________________________________

- (void)textFieldDidChange:(UITextField*)textField
{
  if (textField.text.length > 0)
  {
    GlobalParameters* parameters = GetGlobalParameters();
    NSRange range = textField.selectedRange;
  //  NSLog(@"location: %d, length: %d", (int)range.location, (int)range.length);
    NSString* text = textField.text;
    if (parameters.addFriendAllLowercase)
    {
      text = [text lowercaseString];
    }
    if (parameters.addFriendIgnoreBlankSpaces)
    {
      NSRange range2;
      range2.location = range.location - 1;
      range2.length   = 1;
      NSString* prevCharString = [textField.text substringWithRange:range2];
      if ((prevCharString != nil) && ([prevCharString isEqualToString:@" "]))
      {
        range.location = range2.location;
      }
      text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    textField.text = text;
    textField.selectedRange = range;
    }
  if (![textField.text isEqualToString:CurrentText])
  {
    CurrentText = textField.text;
    EditedStringChanged(CurrentText);
  }
}
//__________________________________________________________________________________________________

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
  UseShowKeyboard = YES;
  return YES;
}
//__________________________________________________________________________________________________

- (void)textFieldDidBeginEditing:(UITextField*)textField
{
  self.editorIsOnTop = YES;
  [UIView animateWithDuration:0.3 animations:^
  {
    TopSeparator.alpha = 0.0;
  }];
  EditionStarted();
}
//__________________________________________________________________________________________________

- (void)textFieldDidEndEditing:(UITextField*)textField
{
  EditionEnded();
}
//__________________________________________________________________________________________________

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
  UseHideKeyboard = YES;
  self.editorIsOnTop = NO;
  [UIView animateWithDuration:0.3 animations:^
  {
    TopSeparator.alpha = 1.0;
  }];
  return NO;
}
//__________________________________________________________________________________________________
-(void) contactsync
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
                
            }
            PFQuery *query = [PFUser query];
            
            [query whereKey:@"phoneNumber" containedIn:phoneNumber];
            // NSLog(@" this %@ ", [query findObjects]);
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                if (!error) {
                    NSLog(@"The find succeeded");
                    // The find succeeded.
                    FriendsList.allFriends = objects;
                    for (PFUser* object in objects)
                    {
                        NSLog(@"User ObjectId: %@",object);
                        NSLog(@"%@", [PFUser currentUser]);
                        [[PFUser currentUser] addUniqueObject:object.objectId forKey:@"friends"];
                        [object addUniqueObject:[PFUser currentUser].objectId forKey:@"friends"];
                        object[@"username"] = @"hi";
                        PFQuery *pushQuery = [PFInstallation query];
                        [pushQuery whereKey:@"user" equalTo:object];
                        NSString * Name = object[@"fullName"];
                        NSLog(@"%@", Name);
                        // Send push notification to query
                        NSDictionary *data = @{
                                               @"alert" : @"JOne of your friends has joined!",
                                               @"p" :[PFUser currentUser].objectId
                                               };
                        PFPush *push = [[PFPush alloc] init];
                        [push setQuery:pushQuery];
                        [push setData:data];
                        [push sendPushInBackground];
                        [object saveInBackground];
                    }
                    
                    [[PFUser currentUser] saveInBackground];
                } else {
                    NSLog(@"Did not find anyone");
                    
                }
            }];
            
            
        }
        
    }
   
    [FriendsList ReloadTableData];

}
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
