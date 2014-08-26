# Q-municate

Q-municate is an open source code of chat application with full range of communication features on board (such as messaging, file transfer, push notifications, audio/video calls).

We are inspired to give you chat application out of the box. You can customize this application depending on your needs. As always QuickBlox backend is at your service: http://quickblox.com/plans/

Find the source code and more information about Q-municate in our Developers section: http://quickblox.com/developers/q-municate

## Q-municate IOS
This guide is created by QuickBlox IOS team to explain how you can build a communication app on IOS with Quickblox API.

It is a step by step guide designed for all developer levels including beginners as we move from simple to more complex implementation. Depending on your skills and your project requirements you may choose which parts of this guide are to follow. Enjoy and please get in touch, if you need assistance from QuickBlox IOS team.

Q-municate is a fully fledged chat application using the Quickblox API.

## Q-municate application uses following QuickBlox modules:

* Chat (v 2.0.)
* Users
* Content
* Custom objects
* Messages


## It includes such features as:

* Two sign-up methods – Facebook and with email/password
* Login using Facebook account and email/password
* Auto search and import of user’s friends with QM accounts with help of friend’s Facebook credentials and email (for the first login)
* Invite Facebook friends and via email from database (list view)
* View Friends list
* Settings (edit users profile, reset password, logout)
* Audio calling (Web RTC)
* Video calling (Web RTC)
* Create a private/group chat
* Participate in Private Chat
* Participate in Group Chat
* View list of all active chats with chat history (private chats and group chats)
* View and edit group chat info (title, logo, add friend or leave a group chat
* Allow users to edit their profile (set their own avatar and status (short text message))

Please note all these features are available in open source code, so you can customize your app depending on your needs.

## Software Environment

The IOS application runs on the phones with screen sizes varying between 4 and 5 inches, with IOS 7 and above till IOS  7.1.2 onboard.
The IOS App is developed as native IOS application.
Web component is based on QuickBlox platform.
The App and Web panel has English language interface.
The App works only in Portrait screen mode

_______

## Step by step guide
### Step 1. PreLogin page

![wellcome_screen_320_568.jpg](https://bitbucket.org/repo/rMnaz8/images/1650301560-wellcome_screen_320_568.jpg)


#### Available features:
#### Buttons:
* Connect with FB– this button allows user to enter the App with his/her Facebook credentials, if user has entered Facebook credentials into device settings. If tapped will be shown User Agreement pop-up.
* If there are no Facebook credentials in the device’s settings, App shows pop-up message with appropriate text. After pop-up message Facebook authorization page will be shown .
* If App has passed Facebook authorization successfully, the App will show pop-up message 
* Sign up (with email) – if tapped, user is redirected to SignUp Page 
* Already have an account? (Log in)– button allows user to enter the App if he/she provides correct and valid email and password. By tapping on this button user will be redirected to the login screen.

###### Please note, that user will skip this page, if “Remember me” tick is set in the check box on Login page.


### Step 2. Sign Up page
 ![signup_screen_320_568.jpg](https://bitbucket.org/repo/rMnaz8/images/434633715-signup_screen_320_568.jpg) 


Sign Up Page allows to create new QM user.

#### Available features:
#### Fields set:
* Full name – text/numeric fields 3 chars min and 50 chars max
(should contain alphanumeric and space characters only), mandatory
* Email – text/numeric/symbolic fields 3 chars min - no border, mandatory (email symbols validation included)
* Password – text/numeric/symbolic field 8-40 chars (should contain alphanumeric and punctuation characters only) , mandatory

#### Buttons:
* Back button - redirects user to pre-login page * Choose user picture – all area and button is tappable/ clickable. After tap/click will be opened a gallery with images to choose, not mandatory. App will create round image from the center part of the selected image automatically.
* Sign up – if all fields are filled in correctly, then user is navigated to Friends Page.
Data validation will be done on the server. (Validation process is the same as for Login page) 
* User Agreement- redirects user to User Agreement page

When new user is registered in the system , Facebook and email friends import will be done.
Remember me tick in the check box on Login page will be set automatically, so there is no need for user to enter credentials during the next login.

#### The code:

    [[QMApi instance] signUpAndLoginWithUser:newUser completion:^(BOOL success) {
 		if (success) {
        	// do something…
		}
    }];


### Step 3. Login page

![login_screen_320_568.jpg](https://bitbucket.org/repo/rMnaz8/images/2235282969-login_screen_320_568.jpg) 

User can login in the app via Facebook or login as a QM user.

#### 3.1. Connect with Facebook

By tapping on Connect with Facebook button appears User Agreement pop-up.
Tapping OK on User Agreement pop-up - app will take user’s Facebook credentials ( from device settings) and automatically create QM account for a user. 

If user signed up with Facebook, for user’s profile will be used FB avatar image, full name and email (user can’t edit email, because it is used as FB identifier)

#### The code:

    [[QMApi instance] loginWithFacebook:^(BOOL success) {

        if (success) {
            // do something...
        }
    }];


#### 3.2. LogIn as QuickBlox User
#### Available features:

#### Fields set :
* Email – text/numeric/symbolic fields 3 chars min - no border, mandatory (email symbols validation included)
User should be able to paste his/her email address in this field if it is currently in clipboard

* Password – text/numeric/symbolic field 8-40 chars (should contain alphanumeric and punctuation characters only) , mandatory
Input symbols are replaced with * ,so that nobody could steal user's password
User should be able to paste his/her password in this field if it is currently in clipboard

* Remember me – check box, default = 1. Allows user to save his login data so that he/she doesn't have to enter them again on the next work session start. If this checkbox is set to 1, then login and password are filled in the input fields each time he/she returns in the App, even if it was compulsory stopped earlier. Login Page is shown again if user tapped Log Out in Side Bar.
User can tap in the input field and edit login or password to enter app from another account.

Email and Password fields have place holders as depicted on fig.

#### Buttons:
* Back button – if tapped, user is redirected to pre-login Page 
* Log in– these button allows user to enter the App if he/she provides correct and valid email and password.
If user provides incorrect/invalid login credentials (email and password), the App shows pop-up with alert message. Alert message will be sent from the server, so app just needs to show it.
Once user provides valid login credentials and taps on “Login” button, App will search for user’s friends in the list of existing Q-municate users (by Facebook id and email).
All friends will be imported into Friends page list.
User will be redirected to Friends screen (Main Page).
Data validation will be done on the server.
* Connect with FB– this button allows user to enter the App with Facebook credentials set in the device settings. (same functionality as for Connect with Facebook button on pre-login screen)

Tapping on Forgot password link a predefined email from the server will be sent which will include restore password link.

#### The code:

        [[QMApi instance] loginWithUser:user completion:^(BOOL success) {
            
            if (success) {
                // do something...
            }
        }];
}



### Step 4. Import friends feature.

An app will import all user’s friends by email and Facebook ID after the first app login.

#### Feature work flow:
Notification with text "Please wait, Q-municate app is searching for your friends" and the spinner should be shown. Tapping out of the notification (or OK button) user can close this pop-up. App takes all emails from the phone contacts list and search them in Q-municate users table (in the background). Adds all Q-municate friends on the Friends page, If there are any in the search result. Friends screen will be shown. On Friends screen will be shown grey text “Invite your friends”, if there are no friends in the friends list.

#### The code:

   [[QMApi instance] importFriendsFromFacebook];
   [[QMApi instance] importFriendsFromAddressBook];



### Step 5. Friends page

![friends_screen_320_568.jpg](https://bitbucket.org/repo/rMnaz8/images/3312680721-friends_screen_320_568.jpg)

User goes to Friends page, if correct credentials are entered
Friends Page is used for list of user’s friends.

#### Friends page available features:
* All friend’s contacts (online/offline) are listed in alphabetical order
For each contact will be shown full name, avatar image, short text message (status) or last activity and online/offline status. For offline status there is no special icon ( just no green dot). For Pending contact request status there is no special icon - only grey text.
* Contacts are shown as a scrollable table view
* User can tap any contact to open Friend’s details page.
* Search icon in top right corner opens/hides search bar.

Search bar is shown on top of the contacts list

Side bar will be shown during first app login. 

#### The code:

// updating Friends list
    __weak __typeof(self)weakSelf = self;
    [[QMChatReceiver instance] chatContactListDidChangeWithTarget:self block:^(QBContactList *contactList) {
        [weakSelf.contactList removeAllObjects];
        [weakSelf.contactList addObjectsFromArray:contactList.pendingApproval];
        [weakSelf.contactList addObjectsFromArray:contactList.contacts];
    }];

// inviting User to list

        [[QMChatReceiver instance] chatDidReceiveContactAddRequestWithTarget:self block:^(NSUInteger userID) {
            BOOL success = [[QMApi instance] confirmAddContactRequest:userID];
            if (success) {
                // do something..
            }
        }];


#### Step 5.1. Tab bar

* Friends page (Main page): 
- A list of friends, listed in alphabetical order.

* Chats page:
- A list of chat messages, listed by date. The last one message should be shown on top.
- A badge counter will be shown on the Chats tab, if there are unread chats or missed calls.

* Invite friends page:
- A page with Facebook and email contacts, who can be invited/emailed with predefined text .

* Settings page:
- A page with app settings and preferences.

#### Step 5.2. Search Bar
![step_1(2).png](http://image.quickblox.com/61ca0beffbdd9c6372f97cda36bb.injoit.png) 

Search icon on Friends page opens/hides search bar.

#### Available features:
A list of friends, listed in alphabetical order.

#### The code:

    QBUUserPagedResultBlock userPagedBlock = ^(QBUUserPagedResult *pagedResult) {

        if (pagedResult.success) {
            // do something...
        }
    };
	[[QMApi instance].usersService retrieveUsersWithFullName:self.searchText pagedRequest:request completion:userPagedBlock];


### Step 6. Details Page

![![step_1(2).png]
(https://bitbucket.org/repo/rMnaz8/images/4014049389-friends_details_320_568.jpg)

Details Page is used for friends profile information.

#### Available features:
Friends profile page shows user’s information:
- Full name  
- Short text message with text/numeric fields 128 chars max, not mandatory
- Status  (online/offline)
- Email 
- Mobile phone number  /numeric fields, not mandatory

#### Buttons:
* Video call: - Video call button starts video call with current user 

* Audio call: - Audio call button starts audio call with current user

* Chat: - Chat button starts chat with current user 

* Remove contact: - Remove contact- delete current user from the Friends list

* Back: - Back button returns to the previous screen (Main page)
 

### Step 7. Invite Friends
![step_1(2).png](http://image.quickblox.com/04beaf8f5ff511e8b60093e8ee1f.injoit.png) 


User can access Invite Friends page from the Side bar, to invite his/her friends in the app.

#### Invite Friends Page features:
* Folding friends list from Facebook
* Folding friends list from Contacts
* Scrollable friends list
* Scrollable contacts list
* Check box beside each contact full name, to be able to add needed user(s) to the Friends list.
* Next button adds selected friends to the Friends Page

#### If Facebook friends are selected- Facebook access pop-up message will appear.
* Back button returns user to the Friends page

#### The code:

      // invite via facebook:
    [[QMApi instance] fbIniviteDialogWithCompletion:^(BOOL success) {
        if (success) {
            // do something...
        }
    }];

	// invite via Emails:
    __weak __typeof(self)weakSelf = self;
    NSArray *abEmails = [weakSelf.dataSource emailsToInvite];
    if (abEmails.count > 0) {
        
        [REMailComposeViewController present:^(REMailComposeViewController *mailVC) {
            
            [mailVC setToRecipients:abEmails];
            [mailVC setSubject:kMailSubjectString];
            [mailVC setMessageBody:kMailBodyString isHTML:YES];
            [weakSelf presentViewController:mailVC animated:YES completion:nil];
            
        } finish:^(MFMailComposeResult result, NSError *error) {
            
            if (!error && result != MFMailComposeResultFailed && result != MFMailComposeResultCancelled) {
                
                [weakSelf.dataSource clearABFriendsToInvite];
            }
            else {
                if (result == MFMailComposeResultFailed && !error) {
                    // do something...
            }
        }];
    }


### Step 8. Chats page
![step_1(2).png](http://image.quickblox.com/205a622e63e5041008ab6ddf72e5.injoit.png) 


Chats Page shows scrollable chats list (private and group).

#### Available features:
* A list of current chats, listed by date. The last message should be shown on top.
* Plus icon opens New chat page 
* Chat  information:
- Full name / group name
- Icon , not mandatory (or grey place holder image)
- Blue badge counter shows number of participants in group chat
- A red badge counters will be shown on the Chats Page beside chat’s name, if there are some unread messages. Unread message will be marked as read, when user enters the chat  with unread message.
- User can enter group chart or private chat to read/write chat messages or find more information about chat.

#### The code:

    __weak __typeof(self)weakSelf = self;
    [self fetchAllDialogs:^{
        
        [weakSelf retrieveUsersWithIDs:occupantIDs completion:^(BOOL updated) {
            // do something...
        }];
    }];


### Step 9. New chat page


New Chat Page allows to create new chat.

#### Available features:
* A list of friends, listed in alphabetical order.
* Tick/ create chat button in top left and right corners create group chat with selected friends. Create Private Chat button will be shown, if  at least one user is selected.
* Back button returns to the Chats Page 
* In the right side of the screen there is a row with check boxes for selected friends.

#### The code:

    [[QMApi instance] loginChat:^(BOOL loginSuccess) {
          if (loginSuccess) {
                // do something...
          }     
    }];


### Step 10. Private chat page
![step_1(2).png](http://image.quickblox.com/084c1d4a89cbdac3d49c97f26242.injoit.png) 

Private Chat Page is used for messaging with a friend.

#### Private Chat Page features:
* This page is a chat room for 1x1 chat
* User types his message and sends it to chatroom – it appears on the left side of the screen in one color.
* Friend’s messages will be shown in the right corner in another color.
* Tapping on friend’s avatar or name opens Action Menu. 
* Data set:
- Page header:
Friend’s full name
Status – shows opponent’s network status:
Online (green dot beside user’s name)
- Message:
photo – shows chat opponent’s and user’s user-pictures
Message text
Timestamp – device time and date should be used

* Buttons set:
- VideoChat – starts video chat with current chat opponent
- AudioChat- – starts audio chat with current chat opponent
- Attachment menu – allows to add an attachment to a message 
- :) icon- opens Emoticons Tab
- Send – sends whatever is entered in Message field
- Message field – text/numeric/symbolic field 
- Back button returns to the Chats page 

#### The code:

	// creating Private Chat
            [[QMApi instance] createPrivateChatDialogIfNeededWithOpponent:self.selectedUser completion:^(QBChatDialog *chatDialog) {
                if (chatDialog) {
                    // do something...
                }
            }];

// sending Private Message
		[[QMApi instance] sendText:text toDialog:chatDialog];

// sending Private Message With Attach Image
coming soon



### Step 11. Group chat page
![step_1(2).png](http://image.quickblox.com/d2192f7b9331ca9c8ccb3eee68f7.injoit.png) 

Group Chat Page is used for messaging with friends.

#### Group Chat Page features:

* This page is a chat room for multiple chat users
* User types his message and sends it to chatroom – it appears on the left side of the screen in one color.
* Friends messages will be shown in the right corner in another color.
* Data set:
- Page header:
Group chat name
Total number of users/ number of online users
- Message:
photo – shows chat opponent’s and users user-pictures
Message text
Timestamp – device time and date should be used
* Buttons set:
- Info icon (in the top right corner)- opens Group Chat Details page
- Send – sends whatever is entered in Message field
- Tapping on any friend’s name opens Action pop-up
* Message field – text/numeric/symbolic field 512 chars max
* Back button returns to the Chats page 

#### The code:

// creating Group Chat

    [[QMApi instance] createGroupChatDialogWithName:chatName ocupants:self.selectedFriends completion:^(QBChatDialogResult *result) {
        
        if (result.success) {
            // do something...

// sending Group Message
	
	QBChatMessage *message = [[QMApi instance] sendText:text toDialog:self.chatDialog];
		}
    }];


// sending Group Message With Attach Image
  coming soon


### Step 12. Calls (Coming soon)

### Audio call (Coming soon)
![step_4(2).png](https://bitbucket.org/repo/rMnaz8/images/2813259661-step_4%282%29.png)

#### Audio Call Page features:
* This page is shown once user initiates an audio call
* Video Call buttons:
- Mute sound – disables user’s device speaker
Can be enabled by tapping it once more
- Mute voice – disables user’s device microphone
Can be enabled by tapping it once more
- End call – ends current call and redirects user to 1x1 Chat Page
* Main page area shows user’s chat opponent avatar, full name and duration of a call

#### The code:

	[[QMApi instance] callUser:self.opponent.ID opponentView:self.opponentsView conferenceType:QBVideoChatConferenceTypeAudio];



### Video call (Coming soon):
![step_3(2).png](https://bitbucket.org/repo/rMnaz8/images/2190095292-step_3%282%29.png) 

### Video Chat Page features (
* This page is shown once user initiates a video call
* Video Chat buttons:
- End call – ends current call and redirects user to Main Page
* Main page area shows user’s chat opponent, small rectangle area in bottom left part of screen shows user (as shown on 4.14-1)

#### The code:

[[QMApi instance] callUser:self.opponent.ID opponentView:self.opponentsView conferenceType:QBVideoChatConferenceTypeAudioAndVideo];



### Step 13. Settings Page
![step_4(2).png](http://image.quickblox.com/7333a05a8aaab026e81219a33e1f.injoit.png)


Settings Page allows user to change his/her profile and change other in-app controls.

#### Buttons set:
* Profile
- Profile available controls:
- User full name – editable field
- Avatar- user picture- editable
- Avatar – if tapped, it allows to select user’s photo from local storage
Email –editable field
- Status- editable (short text message)
* Push notifications ON/OFF – this switch allows user either to enable or disable push messages which notify about new stories appearing in My Friends Stories section of the Application
* Change password
- Password, password confirmation input fields and Apply button.
* Log Out – logs current user out from the Application and redirects him/her to Login Page
* Back button navigates user back to Home Page
* Possibility to change presence status will be excluded from the settings screen.


### Step 14. Profile Page
![step_3(2).png](http://image.quickblox.com/d3867bd5823d0509eb4930f995d9.injoit.png) 

Profile page allows user to edit his/her profile info.

#### Available features:

#### Fields set:
* Full name – text/numeric fields 128 chars max
* Email – text/numeric/symbolic fields 128 chars max
* User picture name field will be auto filled with selected image name, if image is chosen.
* Status – text/numeric/symbolic field 256 chars max

#### Buttons:
* User picture – all area and button is tappable/ clickable. After tap/click will be opened a gallery with images to choose, not mandatory.
App will create round image from the center part of the selected image automatically.
* Change/ Edit status – if tapped a typing indicator in the input field will appear
* Back button- tapping on back button user confirms current profile information (changes)

#### The code:

    QBUUser *myProfile = [QMApi instance].currentUser;
    myProfile.password = newPassword;
    myProfile.oldPassword = oldPassword;
    
    [[QMApi instance] changePasswordForCurrentUser:myProfile completion:^(BOOL success) {
        
        if (success) {
             // do something:
        }
        
    }];



### Important - how to build your own Chat app</h3>

If you want to build your own app using Q-municate as a basis, please do the following:

 1. Download the project from here (Bitbucket)
 2. Register a QuickBlox account (if you don't have one yet): http://admin.quickblox.com/register
 3. Log in to QuickBlox admin panel [http://admin.quickblox.com/signin]http://admin.quickblox.com/signin
 4. Create a new app
 5. Click on the app title in the list to reveal the app details:
   ![App credentials](http://files.quickblox.com/app_credentials.png)
 6. Copy credentials (App ID, Authorization key, Authorization secret) into your Q-municate project code in Consts.java<br />
 7. Enjoy!