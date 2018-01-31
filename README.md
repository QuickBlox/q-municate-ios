# Q-municate 2.7

Q-municate is an open source code of chat application with full range of communication features on board (such as messaging, file transfer, push notifications, audio/video calls, etc.).

We are inspired to give you chat application out of the box. You can customise this application depending on your needs. 

As always QuickBlox backend is at your service: https://quickblox.com/plans/.

Find the source code and more information about Q-municate, as well as installation guide, in our Developers section: https://quickblox.com/developers/q-municate

## Q-municate iOS

This guide is brought to you from QuickBlox iOS team in order to explain how you can build a communication app on iOS using QuickBlox API.

It is a step by step guide designed for all developer levels including beginners as we move from simple to more complex implementation. Depending on your skills and your project requirements you may choose which parts of this guide are to follow. Enjoy and if you need assistance from QuickBlox iOS team feel free to let us know by creating an [issue](https://github.com/QuickBlox/q-municate-ios/issues). 

Q-municate is a fully fledged chat application using the Quickblox API.

## Q-municate application uses following QuickBlox modules:

- [Authentication](http://quickblox.com/developers/Authentication_and_Authorization)
- [Users](http://quickblox.com/developers/Users)
- [Chat](http://quickblox.com/developers/Chat)
- [Video calling](http://quickblox.com/developers/VideoChat)
- [Content](http://quickblox.com/developers/Content)
- [Push Notifications](http://quickblox.com/developers/Messages)

## It includes such features as:
- Three sign-up methods as well as login – [Facebook](https://developers.facebook.com/docs/ios/), [Firebase](https://firebase.google.com/docs/ios/setup) (phone number) and with email/password
- Call Kit
- Share extension
- Siri extension for messaging
- View list of all active chat dialogs with message history (private and group chat dialogs)
- View, edit and leave group chat dialogs
- View and remove private chat dialogs
- Search: local dialogs search, contacts search and global users search
- Create and participate in private and group dialogs
- Managing, updating and removing dialogs
- Audio and Video calls (using QuickBlox WebRTC Framework)
- Edit own user profile
- Reset password and logout
- See other users profile
- Pull to refresh for dialogs list, contacts list and user info page
- Easy to add localisation

###### Please note all these features are available in open source code, so you can customise your app depending on your needs.

## Requirements

- [Xcode 9](https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/WhatsNewXcode/xcode_9/xcode_9.html) and later.
- [QuickBlox iOS SDK](http://quickblox.com/developers/IOS) 2.15 and later.
- [QuickBlox WebRTC SDK](http://quickblox.com/developers/Sample-webrtc-ios) 2.6.3 and later.
- [QMServices](https://github.com/QuickBlox/q-municate-services-ios) 0.6.1 and later.
- [QMChatViewController](https://github.com/QuickBlox/QMChatViewController-ios) 0.6 and later.
- [Bolts](https://github.com/BoltsFramework/Bolts-ObjC#bolts) 1.9.0 and later.
- [Facebook iOS SDK](https://developers.facebook.com/docs/ios) 4.29.0 and later.
- [Firebase](https://fabric.io/kits/ios/digits) 4.8.1 and later.

## Software Environment

- The iOS application runs on any Apple device that supports iOS 9.1 and later.
- The iOS application is developed as native IOS application.
- The iOS application has English language interface and easy to add localisation.
- The App supports both landscape and portrait mode.


## First look into project
### Welcome Screen

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516977157374_welcome.png)


#### Available features:
#### Buttons:
- Connect with Phone – this button allows user to enter the App with his/her phone number using Firebase. If tapped will be shown User Agreement pop-up.
- Login by email or social button – By tapping this button action sheet with extra login methods will pop up. There is such methods as Facebook login and login by email/password.
- Login with Facebook allows user to enter the App with his/her Facebook credentials. If tapped will be shown User Agreement pop-up.
- If App has passed Facebook authorisation successfully, the App will redirect user into chat dialogs list screen.
- Login by email/password allows user to enter the App if he/she provides correct and valid email and password. By tapping on this button user will be redirected to the login screen.

###### Please note, that there is no longer a possibility to sign up user using email and password method. You can only sign up using Phone number and/or Facebook credentials.

###Login with email/password page

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516977175593_login_email.png)


#### Available features:
#### Fields set:

- Email – text/numeric/symbolic fields 3 chars min - no border, mandatory (email symbols validation included)
- Password – text/numeric/symbolic field 8-40 chars (should contain alphanumeric and punctuation characters only) , mandatory

#### Buttons

- Back - returns user back to welcome screen
- Done - performing login after fields validation using provided email and password
- Forgot password - opens forgot password screen

### Forgot password screen

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516977185493_forgot_password.png)


#### Fields set:

- Email – text/numeric/symbolic fields 3 chars min - no border, mandatory (email symbols validation included)

#### Buttons

- Back - returns user back to welcome screen
- Reset - performing password reset

### Tab Bar

Tab bar is a main controller of the application. It consists of such pages:

- Chat dialogs list (main page)
- Contacts list
- Settings

### Chat Dialogs List Screen

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516977194742_chats.png)


#### Search

Search allows user to filter existing dialogs in local cache by its names.

#### Buttons

- Right bar button - redirects user to new dialog screen

### New Message Screen

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516977203691_new_message.png)


If you will select only 1 contact - private chat will be opened (if existent) or created if needed. Otherwise group chat will be created.

#### Search

Tag field allows you to search through contacts full names.

#### Buttons

- Right bar button - creates chat dialog
- Back - return user back to chat dialogs page

### Chat Screen
There is a possibility to send:

- Text messages
- Images from gallery and camera
- Videos from gallery and camera
- Audio records using input toolbar right button

Available features:

- Sharing and forwarding
- Copying image attachmnets and text messages

### Private Chat Screen

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516977220481_private_chat.png)


#### Buttons

- Right bar buttons - Audio and Video call buttons, you can only call user if he is in your contact list
- Back - returns user back to chat dialogs list screen
- Navigation bar title - redirects user to opponent profile page

### Group Chat Screen

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516977229548_group_chat.png)


#### Buttons

- Right bar button and navigation bar title - redirects user to group chat info screen
- Back - return user to chat dialogs list screen
- Opponent user avatars - by tapping opponent user avatars in messages you will be redirected to the info page of that user

### Group Info Screen

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516977239195_group_info.png)

#### Fields/Buttons

- By tapping on group avatar you can change it by taking a new photo or selecting it from library
- By tapping on group name you will be redirected to group name change screen
- By tapping on Add member field you will be redirected to contacts screen in order to select users to add
- By tapping on any user in members list you will be redirected to their info page (except your own user in list)
- By tapping Leave and remove chat field - you will leave existent group chat and delete it locally

### Contacts List Screen

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516977255219_contacts.png)

####  Search

 Search has two scopes buttons:
 
 - Local search - allows user to filter existing contacts by their names.
 - Global search - allows user to find users and see their profiles by full names.
 
![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516968530350_ContactsSearch+1.png)

### User Info Screen

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516977275044_profile.png)

#### Fields/Buttons

 Contacts actions:
 
- Send message - opens chat with user, if there is no chat yet - creates it
- Audio Call - audio call to user
- Video Call - video call to user
- Remove Contact and Chat - deleting user from contact list and chat with him

Other user actions:

- Add contact - sending a contact request to user or accepting existing one

### Settings Screen

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516977285595_settings.png)

#### Fields/Buttons

- Full name, status and email fields will redirect you to update field screen, where you can change your info.
 
![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516977297040_status.png)

- By tapping on avatar action sheet will be opened. You can either take a new picture or choose it from library to update your user avatar.
- Push notification switch - you can either subscribe or unsubscribe from push notifications.
- Tell a friend - opens share controller where you can share this awesome app with your friends :)
-  Give feedback - feedback screen, where you can send an email to us with bugs, improvements or suggestion information in order to help us make Q-municate better!

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516977305837_feedback.png)

## Calls

Q-municate using QuickBlox WebRTC SDK as call service. You can find more information on it [here](http://quickblox.com/developers/Sample-webrtc-ios).

### Calls manager
In order to manage calls we have created a [QMServices](https://github.com/QuickBlox/q-municate-services-ios) sub-service, and its name is QMCallManager. It is managing incoming and outgoing calls. See inline documentation of QMCallManager class for more information.

### Calls controller

To display incoming, outgoing and active calls we have created a universal interface and defined into one view controller. Its name is QMCallViewController.
Call controller has 6 states:

- Incoming audio call
- Incoming video call
- Outgoing audio call
- Outgoing video call
- Active audio call
- Active video call

Call controller is been managed by QMCallManager, basically call manager allocating it with a specific state, whether it is an incoming or outgoing call, then call controller changing its state to active one if required user accepts it.
For more information about code realisation see inline doc of QMCallViewController.

### Audio Call

You can see down below Incoming, outgoing and active audio call screens.

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516983533322_AudioCallScreens.png)


#### Toolbar buttons

Incoming call:

- Decline - declines call and closes received session and controller.
- Accept - accepts call and changes call controller state to Active audio call.

Outgoing and active call:

- Microphone - disables microphone for current call
- Speaker - whether sound should be played in speaker or receiver. Default for audio calls is receiver.
- Decline - hanging up current all and closing controller.

### Video Call

You can see down below Incoming, outgoing and active video call screens.

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516977747381_video_call.png)


By default sound for video calls is in speakers

Incoming call:

- Decline - declines call and closes received session and controller
- Accept - accepts call and changes call controller state to Active video call

Outgoing and active call:

- Camera - enables/disables camera for current call
- Camera rotation - changes camera for current call (front/back)
- Microphone - disables microphone for current call
- Decline - hanging up current all and closing controller

### Call Kit

CallKit allows to integrate calling services with other call-related apps on the system. CallKit provides the calling interface, and we handle the back-end communication with [our VoIP service](https://quickblox.com/developers/SimpleSample-messages_users-ios#Adding_support_for_VOIP_push_notifications). For incoming and outgoing calls, CallKit displays the same interfaces as the Phone app, giving Q-municate application a more native look and feel.

![](https://d2mxuefqeaa7sj.cloudfront.net/s_7BF69620C1058AA11632E980A66E2B94CAE1B1639FF018694E91270C4F3093C2_1517255409865_call_kit.png)

## Extensions

### Share extension

[Share extension](https://developer.apple.com/library/content/documentation/General/Conceptual/ExtensibilityPG/Share.html#//apple_ref/doc/uid/TP40014214-CH12-SW1) gives users a convenient way to share content with other entities.

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516980034230_Untitled-1.png)

### Intent extension(Siri for messaging)

![](https://d2mxuefqeaa7sj.cloudfront.net/s_93E53399630C968604A237F0EAB1B99A1C51B88BD402C4A305A46BBA63CA3D8B_1516980706159_siri.png)

## Code explanation

You can see basic code explanation down below. For detailed one please see our inline documentation for header files in most classes. We have tried to describe as detailed as possible the purpose of every class and its methods. If you have any questions, feel free to let us know by creating an [issue](https://github.com/QuickBlox/q-municate-ios/issues).

### Core

Q-municate using [QMServices](https://github.com/QuickBlox/q-municate-services-ios) as a main wrapper over QuickBlox iOS SDK. See its documentation for more information.

As QMServices design required, we have created a subclass over QMServicesManager and named it QMCore. QMCore has its own managers, that adds more wrappers over methods in QMServices, chaining and performing them using [Bolts framework](https://github.com/BoltsFramework/Bolts-ObjC#bolts).

### Storyboards

We have separated Q-municate for modules, such as:

- Auth
- Main
- Chat
- Settings

Each module has its own storyboard, all storyboards are linked with storyboard links (feature available since Xcode 7 and iOS 8+).

## How to build your own Chat app

If you want to build your own app using Q-municate as a basis, please follow our [detailed guide here](http://quickblox.com/developers/Q-municate#How_to_build_your_own_Chat_app).

# License

Apache License, Version 2.0. See [LICENSE](LICENSE) file.

