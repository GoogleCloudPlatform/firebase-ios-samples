# Build an iOS App Using Firebase and App Engine Flexible Environment

The Playchat sample app stores chat messages in the Firebase Realtime Database,
which automatically synchronizes that data across devices. Playchat also writes
user-event logs to the database. For more information about how the sample app
works, see [Build an iOS App Using Firebase and the App Engine Flexible
Environment](https://cloud.google.com/solutions/mobile/mobile-firebase-app-engine-flexible-ios)
in the Google Cloud Platform (GCP) documentation.

The following screenshot shows the app running on the iOS Simulator:

![PlayChat sample
app](https://cloud.google.com/solutions/mobile/images/firebase-flexible-playchat-message-sent-ios.png)

## Prerequisites

Before using the sample app, make sure that you have the following prerequisites:

- A [Firebase account](https://console.firebase.google.com)
- [Xcode](https://developer.apple.com/xcode/) version 9.4.1 or higher, including 
  iOS Simulator version 9 or higher
- [Cocoapods](https://cocoapods.org/) version 1.5.3 or higher
- A [Google account](https://accounts.google.com) to test the sample app

## Configuring the app

Complete the following tasks to configure the sample app with Firebase and
GCP:

1. Create a project in the [Firebase
   Console](https://console.firebase.google.com/).
   1. Register the iOS app in the project.
   1. Add a Realtime Database to the project.
1. Enable Google authentication for the project.
1. Add a service account to the project.
1. Enable billing for the project from the [GCP Console](https://console.cloud.google.com).
1. Enable the App Engine Admin and Compute Engine APIs.
1. Deploy the backend service to GCP.
1. Update the URL scheme in the `Info.plist` file of the sample app.

For detailed instructions, see [Build an iOS App Using Firebase and the App
Engine Flexible Environment](https://cloud.google.com/solutions/mobile/mobile-firebase-app-engine-flexible-ios).

## Building the app

Follow these steps to install the dependencies and build the sample app:

- From a terminal window, go to the `PlayChat` directory and run the following
  command:
  ```
  pod install
  ```
- From Xcode, select **Product** > **Build**.

## Testing the app

Follow these steps to run the sample app and store messages in the Realtime Database:

- From Xcode, select **Product** > **Run**. Xcode launches the sample app on the
  iOS Simulator.
- Sign in with a Google Account.
- Select a channel from the menu and enter a message.

To browse the data on the Realtime Database, go to your project on the [Firebase
Console](https://console.firebase.google.com) and select **Develop** >
**Database** > **Data**.

## License

 Copyright 2016 Google LLC. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
      http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS-IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the License for the specific language governing permissions and limitations under the License.

This is not an official Google product.
