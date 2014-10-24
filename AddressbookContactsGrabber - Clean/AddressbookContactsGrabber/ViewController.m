//
//  ViewController.m
//  AddressbookContactsGrabber
//
//  Created by TB on 10/23/14.
//  Copyright (c) 2014 TerryBuOrganization. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    ABContactsGrabberDAO *myDAO = [[ABContactsGrabberDAO alloc]init];
    self.DAO = myDAO;
    myDAO.delegate = self;

    [self.DAO runGrabContactsOnBackgroundQueue];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    ABAddressBookRegisterExternalChangeCallback(addressBook, addressBookChanged, (__bridge void *)(self));

}

void addressBookChanged(ABAddressBookRef abRef, CFDictionaryRef dicRef, void *context) {
    
    NSLog(@"!!!!!Address Book Changed!");
    
    //Do Something You Need. (Recreate addressbook or Reload UITableView data.)
    
    ABAddressBookUnregisterExternalChangeCallback(abRef, addressBookChanged, context);
}

- (void) DAOdidFinishFilteringContactsForPhoneNumbers {
    self.syncTimeLabel.text = self.DAO.lastContactsSyncTime;

    NSLog(@"%@", self.DAO.filteredContactsArrayWhoHavePhoneNumbers.description);

    for (int i=0; i < self.DAO.filteredContactsArrayWhoHavePhoneNumbers.count; i++) {
        Contact *contactPointer = self.DAO.filteredContactsArrayWhoHavePhoneNumbers[i];
        NSLog(@"%@ %@ - %@", contactPointer.firstName, contactPointer.lastName, contactPointer.mobileNumber);
    }
}


- (void) DAOdidFinishAddingContact {
    UIAlertView *contactAddedAlert = [[UIAlertView alloc]initWithTitle:@"Contact Added" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [contactAddedAlert show];
}

- (void) authorizationProblemHappened {
    UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
    [cantAddContactAlert show];
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
