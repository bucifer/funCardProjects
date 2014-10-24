//
//  ABContactsGrabberDAO.h
//  AddressbookContactsGrabber
//
//  Created by TB on 10/23/14.
//  Copyright (c) 2014 TerryBuOrganization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "Contact.h"


@interface ABContactsGrabberDAO : NSObject

@property (nonatomic, strong) NSMutableArray *savedArrayOfContactsWithPhoneNumbers;


- (void) runGrabContactsOnBackgroundQueue;
- (void) checkForABAuthorizationAndStartRun;
- (void) grabContactsWithAPhoneNumber;
- (Contact *) createContactObjectBasedOnAddressBookRecord: (ABRecordRef) myABRecordRef;

- (void) startListeningForABChanges;
- (void) addNewContactsIntoCustomArray;

- (void) printOutAllInFetchedArray;
    
@end