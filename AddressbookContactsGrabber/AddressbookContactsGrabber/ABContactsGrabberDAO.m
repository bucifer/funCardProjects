//
//  ABContactsGrabberDAO.m
//  AddressbookContactsGrabber
//
//  Created by TB on 10/23/14.
//  Copyright (c) 2014 TerryBuOrganization. All rights reserved.
//

#import "ABContactsGrabberDAO.h"

@implementation ABContactsGrabberDAO


- (void) grabContactsOnBackgroundQueue {
    NSOperationQueue *queue = [NSOperationQueue new];
    /* Create our NSInvocationOperation to call loadDataWithOperation, passing in nil */
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(grabContactsWithAPhoneNumber)
                                                                              object:nil];
    [queue addOperation:operation];
}

- (void) grabContactsWithAPhoneNumber {
    
    NSMutableArray *resultsArray = [[NSMutableArray alloc]init];
    
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);

    NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    
    for (id record in allContacts){
        ABRecordRef thisContact = (__bridge ABRecordRef)record;
        ABMultiValueRef mvr = ABRecordCopyValue(thisContact, kABPersonPhoneProperty);
        if (ABMultiValueGetCount(mvr) != 0) {
//            ABMultiValueRef mvr = ABRecordCopyValue(thisContact, kABPersonPhoneProperty);
//            NSArray *currentNums = (__bridge NSArray*) ABMultiValueCopyArrayOfAllValues(mvr);
//            [resultsArray addObjectsFromArray:currentNums];
            //above is for pulling the phone numbers logic ... in case you want to do that
            
            NSString *personName = (__bridge NSString *) ABRecordCopyCompositeName(thisContact);
//            [resultsArray addObject:personName];
            
            Contact *mySelectedContact = [[Contact alloc]init];
            
            mySelectedContact.firstName = (__bridge NSString *)(ABRecordCopyValue(thisContact, kABPersonFirstNameProperty));
            mySelectedContact.lastName = (__bridge NSString *)(ABRecordCopyValue(thisContact, kABPersonLastNameProperty));
            mySelectedContact.mobileNumber =  (__bridge NSString *)(ABMultiValueCopyValueAtIndex(mvr, 0));

            [resultsArray addObject:mySelectedContact];
        }
        else {
            NSLog(@"found a contact without phone number at %@", ABRecordCopyCompositeName(thisContact));
        }
    }
    
    self.filteredContactsArrayWhoHavePhoneNumbers = resultsArray;        
    [self.delegate DAOdidFinishFilteringContactsForPhoneNumbers];
}


- (void) checkForAuthorizationAndAdd: (NSString *)firstName lastName:(NSString *)lastName phoneNumber:(NSString *) phoneNumber {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //1
        NSLog(@"you must allow app permissions");
        [self.delegate authorizationProblemHappened];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2
        NSLog(@"Authorized");
        [self addNewPersonInAddressBook: firstName lastName:lastName phoneNumber:phoneNumber];
        
    } else { //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
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
            [self addNewPersonInAddressBook: firstName lastName:lastName phoneNumber:phoneNumber];
        });
    }
}

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
//        NSLog(@"%@", ABRecordCopyCompositeName(thisContact));
    }
    
}




@end
