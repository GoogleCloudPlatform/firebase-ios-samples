/**
 # Copyright Google Inc. 2016
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 # http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
 **/

// [START FirebaseLogger]
import Firebase

class FirebaseLogger {
  var logRef: DatabaseReference!

  init(ref: DatabaseReference!, path: String!) {
    logRef = ref.child(path)
  }

  func log(_ tag: String!, message: String!) {
    let entry: LogEntry = LogEntry(tag: tag, log: message)
    logRef.childByAutoId().setValue(entry.toDictionary())
  }
}
// [END FirebaseLogger]
