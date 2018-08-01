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
  var ref: DatabaseReference!
  var query: DatabaseQuery!
  let dayFormatter = DateFormatter()
  var channelViewDict: [String : UITableView] = [:]
  var msgs: [Message] = []
  var maxMessages: UInt
  var fbLog: FirebaseLogger!

  init(maxMessages: UInt) {
    self.maxMessages = maxMessages
    dayFormatter.dateFormat = "MMM dd YYYY hh:mm a"
  }

  func tabBarController(
      _ ptabBarController: UITabBarController,
      didSelect viewController: UIViewController) {
    query?.removeAllObservers()
    query = ref.child(CHS)
      .child(ptabBarController.selectedViewController!.tabBarItem.title!)
      .queryOrdered(byChild: "time").queryLimited(toLast: maxMessages)
    let title = String(ptabBarController.selectedViewController!
      .tabBarItem.title!)
    let tableView : UITableView = channelViewDict[title]!
    fbLog?.log(inbox, message: "Switching channel to '" + title + "'")
    query.observe(.value, with : { snapshot in
      self.msgs = []
        
      let enumerator = snapshot.children
      
      while let entry = enumerator.nextObject() as? DataSnapshot {
        let dictionary = entry.value as! Dictionary<String, AnyObject>
        let msg = Message(
            text: dictionary["text"] as! String,
            displayName: dictionary["displayName"] as! String
        )
        msg.time = dictionary["time"] as! NSObject
        self.msgs.append(msg)
      }
    
      tableView.reloadData()
      if (snapshot.childrenCount > 0) {
        let indexPath = IndexPath(row: self.msgs.count-1, section: 0)
        tableView.scrollToRow(at: indexPath,
          at: UITableViewScrollPosition.bottom, animated: false)
      }
    }) { (error) in
      print(error)
    }
  }

  func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
    return msgs.count
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
      var cell = tableView.dequeueReusableCell(
        withIdentifier: NSStringFromClass(MessageCell.self), for: indexPath) as! MessageCell
      cell = MessageCell(style: UITableViewCellStyle.default,
                         reuseIdentifier: NSStringFromClass(MessageCell.self))
      if msgs.count > indexPath.row {
        let msg = msgs[indexPath.row]
        cell.body.text = msg.text
        cell.details.text = msg.displayName + ", "
          + dayFormatter.string(
            from: Date(timeIntervalSince1970: msg.time as! Double/1000))
      }
      return cell
  }
  
  func tableView(_ tableView: UITableView,
                 didSelectRowAtIndexPath indexPath: IndexPath) { }

}

