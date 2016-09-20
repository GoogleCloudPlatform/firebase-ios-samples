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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate,
  UITableViewDelegate,
UITextFieldDelegate {
  let IBX : String = "inbox"
  let CHS : String = "channels"
  let REQLOG : String = "requestLogger"
  var maxMessages: UInt = 20
  
  var window: UIWindow?
  var storyboard: UIStoryboard?
  var navigationController: UINavigationController?
  var tabBarController: UITabBarController!
  var msgViewController : MessageViewController?
  
  var user: GIDGoogleUser!
  var inbox: String?
  var ref: FIRDatabaseReference!
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
    msgViewController = MessageViewController(maxMessages: maxMessages)
    tabBarController?.delegate = msgViewController
    
    tabBarController?.viewControllers = [buildChannelView(chanArray[0])]
    for i in 1...chanArray.count-1 {
      tabBarController?.viewControllers?.append(buildChannelView(chanArray[i]))
    }
    
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
    let height = channelView.view.frame.height
    let width = channelView.view.frame.width
    print(height)
    print(width)
    tableView.frame = CGRectMake(0, 20, width, height - 110);
    tableView.rowHeight = 50
    tableView.estimatedRowHeight = 40
    tableView.delegate = self
    tableView.dataSource = msgViewController
    tableView.registerClass(
      MessageCell.self,
      forCellReuseIdentifier: NSStringFromClass(MessageCell))
    tableView.translatesAutoresizingMaskIntoConstraints = true
    channelView.view.addSubview(tableView)
    msgViewController!.channelViewDict[title] = tableView
    
    let signOutButton:UIButton = UIButton(
      frame: CGRectMake(5, height - 80, 55, 20))
    signOutButton.setTitle(" << ", forState: .Normal)
    signOutButton.titleLabel?.textColor = UIColor.cyanColor()

    signOutButton.addTarget(self, action: #selector(AppDelegate.signOut(_:)),
                            forControlEvents: .TouchUpInside)
    channelView.view.addSubview(signOutButton)
    
    let textField:UITextField = UITextField(
      frame: CGRectMake(60, height - 80, 300, 20))
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
        FIRGoogleAuthProvider.credentialWithIDToken(
          authentication.idToken,
          accessToken: authentication.accessToken)
      FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
        print("Signed-in to Firebase as \(user!.displayName!)")
        let nav = UINavigationController(
          rootViewController: self.tabBarController!)
        self.window?.rootViewController?.presentViewController(
          nav,
          animated: true, completion: nil)
        self.ref = FIRDatabase.database().reference()
        self.inbox = "client-" + String(abs(self.user.userID.hash))

        self.msgViewController!.inbox = self.inbox
        self.msgViewController!.ref = self.ref
        
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
          self.msgViewController!.fbLog = self.fbLog
          self.fbLog!.log(self.inbox, message: "Signed in")
        }
      })
    ref.child(REQLOG).childByAutoId().setValue(inbox)
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if (msgs.count == Int(maxMessages)) {
      msgs.removeFirst()
    }
    let channel = tabBarController!.selectedViewController!
      .tabBarItem.title! as String
    let msg : Message = Message(text : textField.text!,
                                displayName: user.profile.name)
    let entry = ref.child(CHS).child(channel).childByAutoId()
    entry.setValue(msg.toDictionary())
    textField.text = ""

    return true
  }
}