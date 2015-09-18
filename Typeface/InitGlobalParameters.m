
//! \file   InitGlobalParameters.m
//! \brief  The main ViewController of the application.
//__________________________________________________________________________________________________

#import "InitGlobalParameters.h"

#import "Alert.h"
#import "Blocks.h"
#import "Colors.h"
#import "AppViewController.h"
#import "Tools.h"
//__________________________________________________________________________________________________

GlobalParameters* InitGlobalParameters(AppViewController* viewController)
{
  GlobalParameters* parameters = GetGlobalParameters();

  // Parse parameters.
  parameters.parseNotificationFormatString              = NSLocalizedString(@"from %@", @"");
  //parameters.parseRemoveFriendNotificationFormatString  = NSLocalizedString(@"%@ removed you from his/her friend list", @"");

  //! Blocked users parameters.

   //parameters.blockedUserReasonMessage       = NSLocalizedString(@"You have been blocked because you deserve it!", @"");
parameters.blockedUserReasonMessage       = NSLocalizedString(@"You have been blocked because you deserve it!", @"");
    // Login view parameters.
  parameters.customizableLoginLabel         = NSLocalizedString(@"Customizable Label", @"");
  parameters.selectCountryMessage           = NSLocalizedString(@"Select your country", @"");
  parameters.fullNamePlaceholder            = NSLocalizedString(@"Full Name", @"");
  parameters.usernamePlaceholder            = NSLocalizedString(@"Username", @"");
  parameters.phoneNumberPlaceholder       	= NSLocalizedString(@"Phone #", @"");
  parameters.verificationCodePlaceholder  	= NSLocalizedString(@"Enter Code", @"");
  parameters.termsAndPrivacyPolicyMessage 	= NSLocalizedString(@"By continuing, you agree to our <a href=\"1\">Terms</a> and\n <a href=\"2\">Privacy Policy</a>", @"");
  parameters.loginLeftButtonLabel         	= NSLocalizedString(@"Didn't get it?", @"");
  parameters.loginRightButtonLabel          = NSLocalizedString(@"Next", @"");
  parameters.initialCountry                 = @"United States";
  parameters.termsAndPolicyLinkAction       = ^(id obj)
  {
    NSString* str = obj;
    if ([str isEqualToString:@"1"])
    {
      Alert(@"User Pressed on the \"Terms\" link", @"You should replace this alert by the display of the terms!", @"OK", nil, ^(NSInteger pressedButton)
      { // Do nothing!
      });
    }
    else
    {
      Alert(@"User Pressed on the \"Privacy Policy\" link", @"You should replace this alert by the display of the privacy policy!", @"OK", nil, ^(NSInteger pressedButton)
      { // Do nothing!
      });
    }
  };
  parameters.invalidParseSessionToken = ^
  {
    Alert(NSLocalizedString(@"Well, this is embarrassing", @""), NSLocalizedString(@"Looks like our server may be acting up.\nTry loggin in again please 🙏🏼", @""), NSLocalizedString(@"OK", @""), nil, ^(NSInteger pressedButton)
    { // Do nothing!
    });
  };
  parameters.missingInternetConnection = ^(BlockAction retry)
  {
    Alert(NSLocalizedString(@"The Internet connection appears to be offline 📵", @""), NSLocalizedString(@"Press OK when connection is stronger 💪🏼", @""), NSLocalizedString(@"OK", @""), nil, ^(NSInteger pressedButton)
    { // Do nothing!
      retry();
    });
  };
  parameters.userIsBlocked = ^(NSString* reason)
  {
    Alert(NSLocalizedString(@"You have been blocked!", @""), reason, NSLocalizedString(@"OK", @""), nil, ^(NSInteger pressedButton)
    { // Do nothing!
    });
  };
  parameters.loginDone = ^(BOOL newUser)
  {
    [viewController loginDone:newUser];
  };

    parameters.findUserMessagingSampleText          = NSLocalizedString(@"I'm done being misunderstood when we text. I'm on Typeface now. Talk to me there.\nMy username is %@\nhttp://typeface.wtf", @"");  // The %@ is a placeholder for the username.
  parameters.findUserMessagingNotSupportedAction  = ^
  {
    Alert(NSLocalizedString(@"Failed to send iMessage", @""), NSLocalizedString(@"Messaging is not supported on this device!", @""), NSLocalizedString(@"OK", @""), nil, ^(NSInteger pressedButton)
    { // Do nothing!
    });
  };
  parameters.findUserFailedToSendMessageAction = ^
  {
    Alert(NSLocalizedString(@"Failed to send iMessage", @""), NSLocalizedString(@"Sending the message was unsuccessful", @""), NSLocalizedString(@"OK", @""), nil, ^(NSInteger pressedButton)
    { // Do nothing!
    });
  };

  parameters.rollDownViewBackgroundColor                = TypePink;

  parameters.loginRollDownViewTitle                     = NSLocalizedString(@"Oops, tap backspace ◀️", @"");
  parameters.loginRollDownPhoneNumberFormatErrorMessage = NSLocalizedString(@"Please double-check your # 📵", @"");
  parameters.loginRollDownPhoneNumberErrorMessage       = NSLocalizedString(@"Please double-check your # 📵", @"");
  parameters.loginRollDownVerificationCodeErrorMessage  = NSLocalizedString(@"Please double-check your code 🔑", @"");
  parameters.loginRollDownUsernameErrorMessage          = NSLocalizedString(@"That username is taken. Try a different one!", @"");

  parameters.addFriendRollDownViewTitle                         = NSLocalizedString(@"Oops, tap backspace ◀️", @"");
  parameters.AddFriendRollDownAlreadyFriendErrorMessage         = NSLocalizedString(@"You two are already friends 👥", @"");
  parameters.AddFriendRollDownBlockedFriendErrorMessage         = NSLocalizedString(@"You blocked this user 🙅🏼", @"");
  parameters.AddFriendRollDownBlockingUserErrorMessage          = NSLocalizedString(@"We couldn't find that username 🔎 ", @"");
  parameters.AddFriendRollDownUnknownUsernameErrorMessage       = NSLocalizedString(@"We couldn't find that username 🔎 ", @"");

  parameters.cameraExposureTargetBias             = 0.65;
  parameters.cameraManualExposureEnabled          = NO;
  parameters.cameraManualWhiteBalanceEnabled      = NO;
  parameters.cameraAutoVideoHdrEnabled            = YES;
  parameters.cameraLowLightBoostEnabled           = YES;
  parameters.cameraExposureDuration               = 0.1;
  parameters.cameraIso                            = 100;
  parameters.cameraWhiteBalanceRedGain            = 1.0;
  parameters.cameraWhiteBalanceGreenGain          = 1.0;
  parameters.cameraWhiteBalanceBlueGain           = 1.0;
  parameters.cameraUseBackCamera                  = NO;

  parameters.gradientTopColor                     = ColorWithAlpha(White , 1.0);
  parameters.gradientBottomColor                  = ColorWithAlpha(White , 0.5);
  parameters.gradientAlpha                        = 1.0;

  parameters.separatorLineWidth                   = 0.40;
  parameters.separatorLineColor                   = LightGrey;
  parameters.separatorLineSideMargin              = 17;


  parameters.headerLeftLabelTitle                 = NSLocalizedString(@"Recent", @"");
  parameters.headerCenterLabelTitle               = NSLocalizedString(@"Type", @"");
  parameters.headerRightLabelTitle                = NSLocalizedString(@"Friends", @"");
  parameters.headerHeight                         = 65;
  parameters.headerTopMargin                      = 20;
  parameters.headerSideMargin                     = 17;
  parameters.headerUnderlineHeight                = 0.40;
  parameters.headerUnderlineGap                   = 18;
  parameters.headerUnderlineColor                 = TypePink;
  parameters.headerUnderlineAnimParameters        = [PopAnimParameters new];
  parameters.headerUnderlineAnimParameters.animationStyle = E_PopAnimationStyle_Spring;
  parameters.headerUnderlineAnimParameters.duration = 0.2;

  parameters.headerUnderlineAnimParameters.bounciness       = 10;
  parameters.headerUnderlineAnimParameters.velocity         = 15;
  parameters.headerUnderlineAnimParameters.springSpeed      = 10;
  parameters.headerUnderlineAnimParameters.dynamicsMass     = 2;
  parameters.headerUnderlineAnimParameters.dynamicsFriction = 25;


  parameters.headerButtonBounceScaleFactor        = 1.333;
  parameters.headerButtonFontSize                 = 16;
  parameters.headerButtonIdleColor                = LightGrey;
  parameters.headerButtonHighlightedColor         = TypePink;
  parameters.headerButtonSelectedColor            = TypePink;
  parameters.headerButtonDisabledColor            = LightGrey;
  parameters.headerButtonDotRadius                = 3;
  parameters.headerButtonHighlightedDotRadius     = 6;
  parameters.headerButtonDotColor                 = TypePink;
  parameters.headerButtonDotFadeDuration          = 0.2;
  parameters.headerButtonDotHorizontalOffset      = 7.5;
  parameters.headerButtonDotVerticalOffset        = 11.5;

  parameters.headerButtonAnimParameters                		= [PopAnimParameters new];
  parameters.headerButtonAnimParameters.animationStyle      = E_PopAnimationStyle_Spring;
  parameters.headerButtonAnimParameters.bounciness       	= 10;
  parameters.headerButtonAnimParameters.velocity        	= 20;
  parameters.headerButtonAnimParameters.springSpeed      	= 20;
  parameters.headerButtonAnimParameters.dynamicsMass     	= 2;
  parameters.headerButtonAnimParameters.dynamicsFriction 	= 15;
  parameters.headerButtonAnimParameters.duration            = 0.2;

  parameters.headerButtonDotAnimParameters                  = [PopAnimParameters new];
  //parameters.headerButtonDotAnimParameters.duration         = 0.2;
  parameters.headerButtonDotAnimParameters.animationStyle   = E_PopAnimationStyle_Spring;
  parameters.headerButtonDotAnimParameters.velocity         = 10;
  parameters.headerButtonDotAnimParameters.bounciness       = 2;
  parameters.headerButtonDotAnimParameters.springSpeed      = 50;
  parameters.headerButtonDotAnimParameters.dynamicsFriction = 13;
  parameters.headerButtonDotAnimParameters.dynamicsMass     = 2;

  parameters.networkActivityBackgroundColor         = Transparent;
  parameters.networkActivityBackgroundOpacity       = 0.00;
  parameters.networkActivityWheelColor              = Transparent;

  parameters.navigatorScrollViewBounces             = NO;

  parameters.friendsTopBarBorderOffset              = 47;
  parameters.friendsTopBarTopOffset                 = 10;
  parameters.friendsUsernameFont                  	= [UIFont fontWithName:@"AvenirNext-Regular" size:26];
  parameters.friendsUsernameMediumFont              = [UIFont fontWithName:@"AvenirNext-Bold" size:26];
  parameters.friendsSelectedUsernameTextColor       = WarmGrey;
  parameters.friendsUsernameTextColor               = DarkGrey;
  parameters.friendsPhotoRadius                     = 20;
  parameters.friendsPhotoLeftMargin                 = 21;
  parameters.friendsTextLeftMargin                  = 68;
  parameters.friendsTextLeftMarginNoPhoto         	= 20;

  parameters.friendsStateViewLeftMargin             = 14;
  parameters.friendsStateViewRightMargin            = 14;
  parameters.friendsListRowHeight                 	= 78;
  parameters.friendsListHeaderHeight                = 26;

  parameters.friendsListBackgroundColor             = Transparent;
  parameters.friendsListSeparatorColor              = LightGrey;
  parameters.friendsListSeparatorHeight             = 0.40;
  parameters.friendsListSeparatorBorderMargin       = 16;
  parameters.friendsListRecentSectionHeaderTitle    = NSLocalizedString(@"Recent", @"");
  parameters.friendsListAllSectionHeaderTitle       = NSLocalizedString(@"All", @"");
  parameters.friendsListHeaderBackgroundColor       = [LightGrey colorWithAlphaComponent:0.5];
  parameters.friendsListHeaderTextColor             = [Grey colorWithAlphaComponent:0.6];
  parameters.friendsListHeaderTextFont              = [UIFont fontWithName:@"AvenirNext-MediumItalic" size:17];
  parameters.friendsListHeaderTextLeftMargin        = 132;
  parameters.friendsListParseRefreshThresholdOffset = -50;
  parameters.friendsProgressRadius                  = 23;
  parameters.friendsProgressLineWidth             	= 2;
  parameters.friendsProgressStrokeColor             = Transparent;
  parameters.friendsProgressFillColor               = parameters.secondaryButtonColor;
  parameters.friendsSendToLabelTitle              	= NSLocalizedString(@"press & hold send", @"");
  parameters.friendsA_ZLabelTitle                 	= NSLocalizedString(@"tap dots for options", @"");
  parameters.friendsActivityLabelTitle              = NSLocalizedString(@"press & hold to watch", @"");
  parameters.friendsLabelTitleColor                 = LightGrey;
  parameters.friendsLabelTitleFontSize              = 16;
  parameters.friendsProgressDuration                = 2;
  parameters.friendsMaxRecentFriends                = 5;

  parameters.friendsEditorPlaceholderText           = NSLocalizedString(@"Add friends by username...", @"");
  parameters.friendsEditorFontSize                  = 16;
  parameters.friendsEditorHeight                    = 60;
  parameters.friendsEditorLeftMargin                = 18;
  parameters.friendsInviteFriendButtonWidth         = 220;
  parameters.friendsAddFriendButtonLateralMargin    = 30;

  parameters.friendsInviteButtonBottomGap           = 43;
  parameters.friendsAddButtonBottomGap              = 5;
  parameters.friendsInviteButtonTitle               = NSLocalizedString(@"INVITE", @"");
  parameters.friendsAddButtonTitle                  = NSLocalizedString(@"ADD", @"");

  parameters.addFriendAutoSearch                    = NO;
  parameters.addFriendIgnoreBlankSpaces             = YES;
  parameters.addFriendAllLowercase                  = NO;

  parameters.friendStateViewCircleLineWidth               = 1.5;
  parameters.friendStateViewCircleRadius                  = 10.5;
  parameters.friendStateViewDiskRadius                    = 6.5;
  parameters.friendStateViewProgressCircleRadius          = 15;
  parameters.friendStateViewProgressDiskRadius            = 10;
  parameters.friendStateViewColor                         = TypePink;
  parameters.friendStateViewProgressAnimationDuration     = 0.6;

  parameters.friendStateViewAnimParameters                = [PopAnimParameters new];
  parameters.friendStateViewAnimParameters.animationStyle = E_PopAnimationStyle_Spring;
  parameters.friendStateViewAnimParameters.bounciness     = 200;
  parameters.friendStateViewAnimParameters.velocity       = 10;
  parameters.friendStateViewAnimParameters.springSpeed    = 200;
  parameters.friendStateViewAnimParameters.dynamicsMass   = 5;

  parameters.friendMenuRemoveFriendTitle                  = NSLocalizedString(@"Remove", @"");
  parameters.friendMenuBlockFriendTitle                   = NSLocalizedString(@"Block & Report", @"");
  parameters.friendMenuCancelTitle                        = NSLocalizedString(@"Cancel", @"");

  parameters.threeDotsPseudoButtonDotRadius                       = 3.0;
  parameters.threeDotsPseudoButtonDotInterval                     = 9.5;
  parameters.threeDotsPseudoButtonHighlightedScaleFactor          = 1.25;
  parameters.threeDotsPseudoButtonColor                           = TypePink;
  parameters.ThreeDotsPseudoButtonAnimParameters                  = [PopAnimParameters new];
  parameters.ThreeDotsPseudoButtonAnimParameters.animationStyle   = E_PopAnimationStyle_Spring;
  parameters.ThreeDotsPseudoButtonAnimParameters.bounciness       = 30;
  parameters.ThreeDotsPseudoButtonAnimParameters.velocity         = 20;
  parameters.ThreeDotsPseudoButtonAnimParameters.springSpeed      = 10;
  parameters.ThreeDotsPseudoButtonAnimParameters.dynamicsMass     = 2;
  parameters.ThreeDotsPseudoButtonAnimParameters.dynamicsFriction = 10;


  parameters.whiteButtonBounceScaleFactor         = 1.5;
  parameters.whiteButtonHeight                    = 50;
  parameters.whiteButtonFontSize                  = 24;
  parameters.whiteButtonIdleColor                 = White;
  parameters.whiteButtonHighlightedColor          = White;
  parameters.whiteButtonDisabledColor             = [White colorWithAlphaComponent:0.4];
  parameters.whiteButtonBounceDuration            = 0.2;


  parameters.whiteButtonAnimParameters                    = [PopAnimParameters new];
  parameters.whiteButtonAnimParameters.animationStyle     = E_PopAnimationStyle_Spring;
  parameters.whiteButtonAnimParameters.bounciness         = 30;
  parameters.whiteButtonAnimParameters.velocity           = 25;
  parameters.whiteButtonAnimParameters.springSpeed        = 100;
  parameters.whiteButtonAnimParameters.dynamicsMass       = 5;
    

  parameters.typingBackgroundColor                = Transparent;
  parameters.typingValidatedBackgroundColor       = Transparent;
  parameters.typingTopBarBorderOffset             = 42;
  parameters.typingTopBarTopOffset                = -3;
  parameters.typingCursorColor                    = DarkGrey;
  parameters.typingFont                           = [UIFont fontWithName:@"AvenirNext-Medium" size:18];




        parameters.typingSmallFontSize                         = 22;
        parameters.typingLargeFontSize                         = 30;

  //parameters.TypingButtonFont                     = [UIFont fontWithName:@"AvenirNext-DemiBold" size:17];
  parameters.typingFaceButtonTitle                = NSLocalizedString(@"FACE", @"");
  parameters.typingMaxCharacterCount              = 140;
  parameters.typingFontSizeCharacterCountTrigger  = 67;
  parameters.typingCharacterCountFontSize         = 14;
    parameters.typingCharacterCountColor            = [White colorWithAlphaComponent:0.5];;
  parameters.typingCharacterCountRightMargin      = 24;
  parameters.typingLeftButtonAlertTitle           = NSLocalizedString(@"Use that selfie?", @"");
  parameters.typingLeftButtonAlertMessage         = NSLocalizedString(@"Tapping 🔴 attaches a selfie to your current text blurb", @"");
  parameters.typingLeftButtonAlertOkString        = NSLocalizedString(@"Use It", @"");
  parameters.typingLeftButtonAlertCancelString    = NSLocalizedString(@"Do Over", @"");
  parameters.typingRightButtonAlertTitle          = NSLocalizedString(@"All done?", @"");
  parameters.typingRightButtonAlertMessage        = NSLocalizedString(@"Tapping 🔵 means you're ready to pick the recipient of the message", @"");
  parameters.typingRightButtonAlertOkString       = NSLocalizedString(@"Yup", @"");
  parameters.typingRightButtonAlertCancelString   = NSLocalizedString(@"Not Yet", @"");


  parameters.faceButtonWidth = 220;

  parameters.typingTextColor                      = WarmGrey;
  parameters.typingValidatedTextColor             = [Grey colorWithAlphaComponent:0.3];
  parameters.typingValidatedTextBackgroundColor   = [White colorWithAlphaComponent:0.4];
  parameters.typingTextBlockGap                   = 5;
  parameters.typingTopOffset                      = 10;
  parameters.typingFaceButtonGap                  = 10;
  parameters.typingFaceButtonLateralMargin        = 30;
  parameters.typingEditorLateralMargin            = 20;
  parameters.typingForceCapitalizingFirstChar     = YES;
  parameters.typingSnapshotFlashDuration          = 0.20;
  parameters.typingHideKeyboardDuringFlash        = NO;


  parameters.playerLabelCenterOffsetFromBottom                    = 160;
  parameters.playerLabelLateralMargin                             = 50;


 parameters.playerShortTextFontSize                         = 32;
parameters.playerLongTextFontSize                          = 22;

  parameters.playerTextColor                                      = WarmGrey;
  parameters.playerFontSizeCharacterCountTrigger                  = 90;

  parameters.playerCircleToScreenAnimParameters                   = [PopAnimParameters new];
  parameters.playerCircleToScreenAnimParameters.animationStyle    = E_PopAnimationStyle_Spring;
  parameters.playerCircleToScreenAnimParameters.bounciness        = 500;
  parameters.playerCircleToScreenAnimParameters.velocity          = 1.5;
  parameters.playerCircleToScreenAnimParameters.springSpeed       = 20;
  parameters.playerCircleToScreenAnimParameters.dynamicsTension   = 300;
  parameters.playerCircleToScreenAnimParameters.dynamicsFriction  = 30;
  parameters.playerCircleToScreenAnimParameters.dynamicsMass      = 2;

  parameters.playerChunkColorIntroAnimParameters                  = [PopAnimParameters new];
  parameters.playerChunkColorIntroAnimParameters.duration         = 0.25;

  parameters.playerChunkColorLeaveAnimParameters                  = [PopAnimParameters new];
  parameters.playerChunkColorLeaveAnimParameters.duration         = 0.25;

  parameters.playerChunkScaleIntroAnimParameters                  = [PopAnimParameters new];
  parameters.playerChunkScaleIntroAnimParameters.animationStyle   = E_PopAnimationStyle_Spring;
  parameters.playerChunkScaleIntroAnimParameters.bounciness       = 20;
  parameters.playerChunkScaleIntroAnimParameters.velocity         = 2;
  parameters.playerChunkScaleIntroAnimParameters.springSpeed      = 20;
  parameters.playerChunkScaleIntroAnimParameters.dynamicsMass     = 2;

  parameters.playerChunkScaleLeaveAnimParameters                  = [PopAnimParameters new];
  parameters.playerChunkScaleLeaveAnimParameters.duration         = 0.2;
  parameters.playerChunkScaleLeaveAnimParameters                  = [PopAnimParameters new];
  parameters.playerChunkScaleLeaveAnimParameters.animationStyle   = E_PopAnimationStyle_Spring;
  parameters.playerChunkScaleLeaveAnimParameters.bounciness       = 20;
  parameters.playerChunkScaleLeaveAnimParameters.velocity         = 2;
  parameters.playerChunkScaleLeaveAnimParameters.springSpeed      = 20;
  parameters.playerChunkScaleLeaveAnimParameters.dynamicsMass     = 2;

  parameters.playerShortTextLength                                = 10;
  parameters.playerAdjustmentRatio                                = 16.5;
  parameters.playerFont                                           = [UIFont fontWithName:@"AvenirNext-Demibold" size:30];

  return parameters;
}
//__________________________________________________________________________________________________
