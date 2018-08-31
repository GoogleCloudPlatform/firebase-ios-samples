/**
 # Copyright Google LLC. 2016
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

import Firebase

class Message: NSData {
  var text: String!
  var displayName: String!
  var time: NSObject!

  init(text: String, displayName: String) {
    super.init()
    self.text = text
    self.displayName = displayName
    self.time = ServerValue.timestamp() as NSObject
  }

  convenience override init() {
    self.init(text: "", displayName: "")
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func toDictionary() -> [String: AnyObject] {
    let json = ["text": text, "displayName": displayName, "time": time] as [String: AnyObject]
    return json
  }
}
