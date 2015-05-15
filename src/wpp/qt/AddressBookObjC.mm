#import "AddressBookObjC.h"
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/ABSource.h>
#import <AddressBook/ABMultiValue.h>
#import <AddressBook/ABPerson.h>
#import <Foundation/NSData.h>


@implementation AddressBookObjC

- (QList<QObject*>) fetchAll
{
	// Programmatically Request Access to Contacts: http://stackoverflow.com/questions/12648244/programmatically-request-access-to-contacts
	// http://stackoverflow.com/questions/19027118/fetch-contacts-in-ios-7

/*	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
		ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
	  //1
	  NSLog(@"Denied");
	} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
	  //2
	  NSLog(@"Authorized");
	} else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
	  //3
	  NSLog(@"Not determined");
	}
*/
	//std::map<std::string> contactList;
NSLog(@"obj-c: fetchAll: 2");

#ifdef __cplusplus
	QList<QObject*> contacts;
#endif

	CFErrorRef *error = nil;

	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);

	__block BOOL accessGranted = NO;
	if (ABAddressBookRequestAccessWithCompletion != NULL)
	{ // we're on iOS 6
		dispatch_semaphore_t sema = dispatch_semaphore_create(0);
		ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
			accessGranted = granted;
			dispatch_semaphore_signal(sema);
		});
		dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//#ifdef DEBUG
		NSLog(@"iOS 6 or later...");
//#endif
	}
	else
	{ // we're on iOS 5 or older
		accessGranted = YES;
//#ifdef DEBUG
		NSLog(@"iOS 5 or older...");
//#endif
	}

	if (!accessGranted)
	{
		NSLog(@"Cannot fetch Contacts :( ");
		return contacts;
	}

	//#ifdef DEBUG
	NSLog(@"Access Granted. Fetching contact info ----> ");
	//#endif

	//scope
	{
		ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);

		CFArrayRef addressBookRecords = ABAddressBookCopyArrayOfAllPeople(addressBook);

		//ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
		//CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
		CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
		//NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];

		//NSLog(@"addressbook = %@", addressBook);
		//NSLog(@"nPeople = %d", nPeople);


		for (int i = 0; i < nPeople; i++)
		{
			//ContactsData *contacts = [ContactsData new];

			NSLog(@"people index:%d", i);
			ABRecordRef person = CFArrayGetValueAtIndex(addressBookRecords, i);
			NSLog(@"person: %p", person);

			//get First Name and Last Name

			//contacts.firstNames = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
			//contacts.lastNames =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
			NSString *firstNames = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
			NSString *lastNames =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
			//if (!contacts.firstNames) {
			if (!firstNames) {
				//contacts.firstNames = @"";
				firstNames = @"";
			}
			//if (!contacts.lastNames) {
			if (!lastNames) {
				//contacts.lastNames = @"";
				lastNames = @"";
			}
			NSLog(@"firstNames %@", firstNames);
			NSLog(@"lastNames %@", lastNames);


			wpp::qt::AddressBookContact *contact = new wpp::qt::AddressBookContact();
			contact->setFirstName( [firstNames UTF8String] );//http://stackoverflow.com/questions/8001677/how-do-i-convert-a-nsstring-into-a-stdstring
			contact->setLastName( [lastNames UTF8String] );//http://stackoverflow.com/questions/8001677/how-do-i-convert-a-nsstring-into-a-stdstring
			NSLog(@"contact set firstname" );

			// get contacts picture, if pic doesn't exists, show standart one

			NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
			char *imgDataPtr = (char *)[imgData bytes];
			contact->setProfilePhotoData( QByteArray( imgDataPtr, imgData.length ) );  //std::vector<char>(imgDataPtr, imgDataPtr + imgData.length);
				//contacts.image = [UIImage imageWithData:imgData];
			//if (!contacts.image) {
				//contacts.image = [UIImage imageNamed:@"NOIMG.png"];
			//}

			//get Phone Numbers

			//NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];

			ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
			NSLog(@"phone count: %ld", ABMultiValueGetCount(multiPhones) );
			for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {

				CFStringRef phoneNumberRef = (CFStringRef)ABMultiValueCopyValueAtIndex(multiPhones, i);
				NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
				NSLog(@"phone: %@", phoneNumber);
				QString phone( [phoneNumber UTF8String] );
				//[phoneNumbers addObject:phoneNumber];
				//NSLog(@"All numbers %@", phoneNumbers);

				NSLog(@"phone-A");

				CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(multiPhones, i);
				NSLog(@"phone-A1:%p",locLabel);
				NSString *phoneLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
				NSLog(@"phone-A2:phoneLabel=%@", phoneLabel);
				if ( locLabel != 0 ) CFRelease(locLabel);
				NSLog(@"phone-A3");
				QString phoneCustomLabelString( [phoneLabel UTF8String] );

				NSLog(@"phone-B");

				//int phoneType = 7;//TYPE_OTHER
				int phoneType = 0;//TYPE_CUSTOM

				if ( phoneType == 0 )//TYPE_CUSTOM
				{
					contact->getPhones().push_back(
						new wpp::qt::AddressBookContactPhone( phone, phoneCustomLabelString )
					);
				}
				else
				{
					contact->getPhones().push_back(
						new wpp::qt::AddressBookContactPhone( phone, phoneType )
					);
				}
				NSLog(@"phone-C");

			}

			NSLog(@"phone-for-end");

			//[contacts setNumbers:phoneNumbers];

			//get Contact email

			//NSMutableArray *contactEmails = [NSMutableArray new];
			ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
			NSLog(@"email count: %ld", ABMultiValueGetCount(multiEmails) );
			for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
				CFStringRef contactEmailRef = (CFStringRef)ABMultiValueCopyValueAtIndex(multiEmails, i);
				NSString *contactEmail = (__bridge NSString *)contactEmailRef;
				//[contactEmails addObject:contactEmail];
				//NSLog(@"All emails are:%@", contactEmails);
				NSLog(@"email: %@", contactEmail);
				QString email( [contactEmail UTF8String] );

				CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(multiEmails, i);
				NSString *emailLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
				if ( locLabel != 0 ) CFRelease(locLabel);
				QString emailCustomLabelString( [emailLabel UTF8String] );

				//int emailType = 3;//TYPE_OTHER
				int emailType = 0;//TYPE_CUSTOM

				if ( emailType == 0 )//TYPE_CUSTOM
				{
					contact->getEmails().push_back(
						new wpp::qt::AddressBookContactEmail( email, emailCustomLabelString )
					);
				}
				else
				{
					contact->getEmails().push_back(
						new wpp::qt::AddressBookContactEmail( email, emailType )
					);
				}
			}
			NSLog(@"adding into list");

			//[contacts setEmails:contactEmails];

			//[items addObject:contacts];
			contacts.push_back(contact);

		}//for-each-person

	}//scope

	return contacts;
}

@end
