//__________________________________________________________________________________________________
//
// Copyright © 2014 Bernie                                              
//__________________________________________________________________________________________________
//
// PROJECT  FallingTexts
//__________________________________________________________________________________________________
//
//! \file   ParseTemplateClass.m
//! \brief  Template class to use to build any other Parse based class.
//!
//! \author Bernie
//__________________________________________________________________________________________________

#import <Parse/PFObject+Subclass.h>

#import "ParseTemplateClass.h"
//__________________________________________________________________________________________________

//! Template class to use to build any other Parse based class.
@interface ParseTemplateClass()<PFSubclassing>
{
}
//____________________

@end
//__________________________________________________________________________________________________

//! Template class to use to build any other Parse based class.
@implementation ParseTemplateClass
{
}
//____________________

+ (void)load
{
  [self registerSubclass];
}
//__________________________________________________________________________________________________

+ (NSString*)parseClassName
{
  return @"ParseTemplateClass";
}
//__________________________________________________________________________________________________

- (void)dealloc
{
}
//__________________________________________________________________________________________________

@end
