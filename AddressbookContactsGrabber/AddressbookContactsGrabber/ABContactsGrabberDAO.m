//
//  ABContactsGrabberDAO.m
//  AddressbookContactsGrabber
//
//  Created by Aditya Narayan on 10/23/14.
//  Copyright (c) 2014 TerryBuOrganization. All rights reserved.
//

#import "ABContactsGrabberDAO.h"

@implementation ABContactsGrabberDAO

- (void) addNewPersonInAddressBook: (NSString *)firstName lastName:(NSString *)lastName phoneNumber:(NSString *) phoneNumber{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
    NSString* guyFirstName = firstName;
    NSString* guyLastName = lastName;
    NSString* guyPhoneNumber = phoneNumber;
    ABRecordRef guy = ABPersonCreate();
    ABRecordSetValue(guy, kABPersonFirstNameProperty, (__bridge CFStringRef)guyFirstName, nil);
    ABRecordSetValue(guy, kABPersonLastNameProperty, (__bridge CFStringRef)guyLastName, nil);
    ABMutableMultiValueRef phoneNumbers = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phoneNumbers, (__bridge CFStringRef)guyPhoneNumber, kABPersonPhoneMainLabel, NULL);
    ABRecordSetValue(guy, kABPersonPhoneProperty, phoneNumbers, nil);
    
    ABAddressBookAddRecord(addressBookRef, guy, nil);
    ABAddressBookSave(addressBookRef, nil);
    [self.delegate DAOdidFinishAddingContact];
    
    NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    
    for (id record in allContacts){
        ABRecordRef thisContact = (__bridge ABRecordRef)record;
        NSLog(@"%@", ABRecordCopyCompositeName(thisContact));
    }
    
}

- (void) checkForAuthorizationAndAdd {
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //1
        NSLog(@"you must allow app permissions");
        [self.delegate authorizationProblemHappened];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2
        NSLog(@"Authorized");
        [self addNewPersonInAddressBook: @"test" lastName:@"honeNumber" phoneNumber:nil];
        
    } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        //3
        NSLog(@"Not determined");
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                //4
                NSLog(@"you must allow app permissions");
                [self.delegate authorizationProblemHappened];
                return;
            }
            //5
            NSLog(@"Authorized");
            [self addNewPersonInAddressBook: @"test" lastName:@"honeNumber" phoneNumber:nil];
        });
    }
}





@end
