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

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate,
                   UITableViewDelegate, UITableViewDataSource,
                   UITabBarControllerDelegate, UITextFieldDelegate {
  let IBX : String = "inbox"
  let CHS : String = "channels"
  let REQLOG : String = "requestLogger"
  var maxMessages: UInt = 20
    
  var window: UIWindow?
  var storyboard: UIStoryboard?
  var navigationController: UINavigationController?
  var tabBarController: UITabBarController!
  let dayFormatter = NSDateFormatter()
    
  var user: GIDGoogleUser!
  var inbox: String?
  var ref: FIRDatabaseReference!
  var query: FIRDatabaseQuery!
  var msgs: [Message] = []
  var channelViewDict: [String : UITableView] = [:]
  
  var fbLog: FirebaseLogger?

  func application(application: UIApplication, didFinishLaunchingWithOptions
                   launchOptions: [NSObject: AnyObject]?) -> Bool {
    var configureError: NSError?
    GGLContext.sharedInstance().configureWithError(&configureError)
    assert(configureError == nil, "Config error: \(configureError)")

    let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist")!
    let dict = NSDictionary(contentsOfFile: path) as! [String: AnyObject]
    let channels = dict["Channels"] as! String
    let chanArray = channels.componentsSeparatedByString(",")
    maxMessages = dict["MaxMessages"] as! UInt
    
    storyboard = UIStoryboard(name: "Main", bundle: nil)
    navigationController = storyboard!.instantiateInitialViewController()
      as? UINavigationController
    tabBarController = self.storyboard!
      .instantiateViewControllerWithIdentifier("TabBarController")
      as! UITabBarController
    tabBarController?.delegate = self
    
    for i in 0...chanArray.count-1 {
      let channelView = buildChannelView(chanArray[i])
      if i == 0 {
        tabBarController?.viewControllers = [channelView]
      }
      else {
        tabBarController?.viewControllers?.append(channelView)
      }
    }
    dayFormatter.dateFormat = "MMM dd YYYY hh:mm a"
    
    FIRApp.configure()
    GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
    GIDSignIn.sharedInstance().delegate = self
    
    return true
  }
    
  func buildChannelView(title : String) -> UIViewController {
    let channelView = UIViewController()
    let fontBold:UIFont = UIFont(name: "HelveticaNeue-Bold", size: 14)!
    channelView.tabBarItem.title = title
    channelView.tabBarItem.setTitleTextAttributes(
    [
      NSForegroundColorAttributeName: UIColor.grayColor(),
      NSFontAttributeName: fontBold
    ], forState: UIControlState.Normal)
    channelView.tabBarItem.setTitleTextAttributes(
    [
      NSForegroundColorAttributeName: UIColor.blackColor(),
      NSFontAttributeName: fontBold
    ], forState: UIControlState.Selected)
    
    let tableView:UITableView = UITableView()
    tableView.frame = CGRectMake(0, 20, channelView.view.frame.width,
                                 channelView.view.frame.height - 110);
    tableView.rowHeight = 50
    tableView.estimatedRowHeight = 40
    tableView.delegate = self
    tableView.dataSource = self
    tableView.registerClass(MessageCell.self,
      forCellReuseIdentifier: NSStringFromClass(MessageCell))
    channelView.view.addSubview(tableView)
    channelViewDict[title] = tableView

    let signOutButton:UIButton = UIButton(frame: CGRectMake(5, 590, 55, 20))
    signOutButton.setTitle(" << ", forState: .Normal)
    signOutButton.titleLabel?.textColor = UIColor.cyanColor()
    signOutButton.addTarget(self, action: #selector(AppDelegate.signOut(_:)),
                            forControlEvents: .TouchUpInside)
    channelView.view.addSubview(signOutButton)
    
    let textField:UITextField = UITextField(frame: CGRectMake(60, 590, 300, 20))
    textField.attributedPlaceholder = NSAttributedString(
      string: "Enter your message",
      attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()])
    textField.userInteractionEnabled = true
    textField.textColor = UIColor.whiteColor()
    textField.backgroundColor = UIColor.blackColor()
    textField.becomeFirstResponder()
    textField.delegate = self
    channelView.view.addSubview(textField)
    
    return channelView
  }
    
  func application(application: UIApplication, openURL url: NSURL,
                   options: [String: AnyObject]) -> Bool {
    return GIDSignIn.sharedInstance().handleURL(url, sourceApplication:
      options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
      annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
  }

  func applicationWillResignActive(application: UIApplication) {}
  func applicationDidEnterBackground(application: UIApplication) {}
  func applicationWillEnterForeground(application: UIApplication) {}
  func applicationDidBecomeActive(application: UIApplication) {}
  func applicationWillTerminate(application: UIApplication) {}
    
  func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
              withError error: NSError!) {
    if let error = error {
      print("signIn error : \(error.localizedDescription)")
      return
    }
    
    if (self.user == nil) {
      self.user = user
      let authentication = user.authentication
      let credential =
        FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,
          accessToken: authentication.accessToken)
      FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
        print("Signed-in to Firebase as \(user!.displayName!)")
        let nav = UINavigationController(
          rootViewController: self.tabBarController!)
        self.window?.rootViewController?.presentViewController(nav,
          animated: true, completion: nil)
        self.ref = FIRDatabase.database().reference()
        self.inbox = "client-" + String(abs(self.user.userID.hash))
        self.requestLogger()
      }
    }
  }
    
  func signOut(sender:UIButton) {
    fbLog!.log(inbox, message: "Signed out")
    do {
      try FIRAuth.auth()!.signOut()
      let signInController = self.storyboard!
        .instantiateViewControllerWithIdentifier("Signin") as UIViewController!
      let nav = UINavigationController(rootViewController: signInController)
      window?.rootViewController?.presentViewController(nav, animated: false,
                                                        completion: nil)
      window?.rootViewController?.dismissViewControllerAnimated(false,
                                                                completion: nil)
    } catch let error as NSError {
        print ("Error signing out: %@", error)
    }
    user = nil
  }
    
  func requestLogger() {
    ref.child(IBX + "/" + inbox!).removeValue()
    ref.child(IBX + "/" + inbox!)
      .observeEventType(.Value, withBlock: {snapshot in
      print(self.inbox!)
      if (snapshot.exists()) {
        self.fbLog = FirebaseLogger(ref: self.ref, path: self.IBX + "/"
          + String(snapshot.value!) + "/logs")
        self.ref.child(self.IBX + "/" + self.inbox!).removeAllObservers()
        self.fbLog!.log(self.inbox, message: "Signed in")
      }
    })
    ref.child(REQLOG).childByAutoId().setValue(inbox)
  }

  func tabBarController(ptabBarController: UITabBarController,
                    didSelectViewController viewController: UIViewController) {
    query?.removeAllObservers()
    query = ref.child(CHS)
            .child(tabBarController!.selectedViewController!.tabBarItem.title!)
            .queryOrderedByChild("time").queryLimitedToLast(maxMessages)
    let title = String(tabBarController!.selectedViewController!
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

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if (msgs.count == Int(maxMessages)) {
        msgs.removeFirst()
    }
    let channel = tabBarController!.selectedViewController!
      .tabBarItem.title! as String
    let msg : Message = Message(text : textField.text!,
                                displayName: user.profile.name)
    let entry = ref.child(CHS).child(channel).childByAutoId()
    entry.setValue(msg.toJson())
    textField.text = ""
    
    return true
  }
}

