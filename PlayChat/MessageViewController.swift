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

import Firebase
import UIKit

class MessageViewController : NSObject, UITableViewDataSource,
UITabBarControllerDelegate {
  let CHS : String = "channels"

  var inbox: String!
  var ref: FIRDatabaseReference!
  var query: FIRDatabaseQuery!
  let dayFormatter = NSDateFormatter()
  var channelViewDict: [String : UITableView] = [:]
  var msgs: [Message] = []
  var maxMessages: UInt
  var fbLog: FirebaseLogger!

  init(maxMessages: UInt) {
    self.maxMessages = maxMessages
    dayFormatter.dateFormat = "MMM dd YYYY hh:mm a"
  }

  func tabBarController(
      ptabBarController: UITabBarController,
      didSelectViewController viewController: UIViewController) {
    query?.removeAllObservers()
    query = ref.child(CHS)
      .child(ptabBarController.selectedViewController!.tabBarItem.title!)
      .queryOrderedByChild("time").queryLimitedToLast(maxMessages)
    let title = String(ptabBarController.selectedViewController!
      .tabBarItem.title!)
    let tableView : UITableView = channelViewDict[title]!
    fbLog?.log(inbox, message: "Switching channel to '" + title + "'")
    query.observeEventType(.Value, withBlock : { snapshot in
      self.msgs = []
      for entry in snapshot.children {
        let msg = Message(text: String(entry.value!.objectForKey("text")!),
          displayName: String(entry.value!.objectForKey("displayName")!))
        msg.time = String(entry.value!.objectForKey("time")!)
        self.msgs.append(msg)
      }
      tableView.reloadData()
      if (snapshot.childrenCount > 0) {
        let indexPath = NSIndexPath(forRow: self.msgs.count-1, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath,
          atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
      }
    }) { (error) in
      print(error)
    }
  }

  func tableView(tv: UITableView, numberOfRowsInSection section: Int) -> Int {
    return msgs.count
  }

  func tableView(tableView: UITableView,
                 cellForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCell {
      var cell = tableView.dequeueReusableCellWithIdentifier(
        NSStringFromClass(MessageCell), forIndexPath: indexPath) as! MessageCell
      cell = MessageCell(style: UITableViewCellStyle.Default,
                         reuseIdentifier: NSStringFromClass(MessageCell))
      if msgs.count > indexPath.row {
        let msg = msgs[indexPath.row]
        cell.body.text = msg.text
        cell.details.text = msg.displayName + ", "
          + dayFormatter.stringFromDate(
            NSDate(timeIntervalSince1970: Double(msg.time as! String)!/1000))
      }
      return cell
  }
  
  func tableView(tableView: UITableView,
                 didSelectRowAtIndexPath indexPath: NSIndexPath) { }

}

