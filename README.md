# Build a Mobile App Using  Firebase and App Engine Flexible Environment
This repository contains iOS client sample code for "[Build a Mobile App Using  Firebase and App Engine Flexible Environment](https://cloud.google.com/solutions/mobile/mobile-firebase-appengine-flexible)" paper. Sample backend code can be found [here](https://github.com/GoogleCloudPlatform/firebase-appengine-backend).

## Build Requirements
- Following Google APIs are needed to be enabled from Google Developers Console.
  - Google App Engine
  - Google Compute Engine
- Sign up on [Firebase](https://firebase.google.com/) and create a new project (if you don't have one).
- Build and test environment
  - Xcode Version 7.3.1
  - UI layout is optimal for iPhone 6.

Firebase is a Google product, independent from Google Cloud Platform.

## Configuration
- Login to Firebase console and click "ADD APP" and select "Add Firebase to your iOS app".
- Follow instructions and make sure to place "GoogleService-Info.plist" file under "PlayChat/PlayChat" directory.
  - iOS bundle ID : com.google.cloud.solutions.flexenv

## Build
- Open "GoogleService-Info.plist" file and copy a value of REVERSED_CLIENT_ID (eg. com.googleusercontent.apps.xxxxx)
- Open "Info.plist" file and replace "[REVERSED_CLIENT_ID]" to the value copied in the previous step.
- Save "Info.plist" file.
- Execute "pod install" under "PlayChat" directory.

## Launch and test
- Start an iOS simulator and run the app.
- Sign in with a Google account.
- Select a channel from bottom menu and enter messages.

Note : press "Command + k" to show/hide keyboard.

## License
 Copyright 2016 Google Inc. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
      http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS-IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the License for the specific language governing permissions and limitations under the License.

This is not an official Google product.
