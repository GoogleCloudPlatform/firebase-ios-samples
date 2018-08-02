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
import GoogleSignIn
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate,
  UITableViewDelegate,
UITextFieldDelegate {
  let IBX: String = "inbox"
  let CHS: String = "channels"
  let REQLOG: String = "requestLogger"
  var chanArray: [String] = []
  var maxMessages: UInt = 20

  var window: UIWindow?
  var storyboard: UIStoryboard?
  var navigationController: UINavigationController?
  var tabBarController: UITabBarController?
  var msgViewController: MessageViewController?

  var user: GIDGoogleUser!
  var inbox: String?
  var ref: DatabaseReference!
  var msgs: [Message] = []
  var channelViewDict: [String: UITableView] = [: ]
  var fbLog: FirebaseLogger?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions
    launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
       let dictionary = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
      chanArray = dictionary["Channels"]!.components(separatedBy: ",")
      maxMessages = dictionary["MaxMessages"]! as! UInt
    } else {
      print("Couldn't read 'Info.plist' file")
    }

    storyboard = UIStoryboard(name: "Main", bundle: nil)
    navigationController = storyboard!.instantiateInitialViewController()
      as? UINavigationController

    tabBarController = self.storyboard!
        .instantiateViewController(withIdentifier: "TabBarController")
        as? UITabBarController
    msgViewController = MessageViewController(maxMessages: maxMessages)
    tabBarController?.delegate = msgViewController

    tabBarController?.viewControllers = [buildChannelView(chanArray[0])]
    for i in 1...chanArray.count - 1 {
      tabBarController?.viewControllers?.append(buildChannelView(chanArray[i]))
    }

    FirebaseApp.configure()

    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    GIDSignIn.sharedInstance().delegate = self

    return true
  }

  func buildChannelView(_ title: String) -> UIViewController {
    let channelView = UIViewController()
    let fontBold: UIFont = UIFont(name: "HelveticaNeue-Bold", size: 14)!
    channelView.tabBarItem.title = title
    channelView.tabBarItem.setTitleTextAttributes(
      [
        NSAttributedStringKey.foregroundColor: UIColor.gray,
        NSAttributedStringKey.font: fontBold
      ], for: .normal)
    channelView.tabBarItem.setTitleTextAttributes(
      [
        NSAttributedStringKey.foregroundColor: UIColor.black,
        NSAttributedStringKey.font: fontBold
      ], for: .selected)

    let tableView: UITableView = UITableView()
    let height = channelView.view.frame.height
    let width = channelView.view.frame.width
    print(height)
    print(width)
    tableView.frame = CGRect(x: 0, y: 20, width: width, height: height - 110)
    tableView.rowHeight = 50
    tableView.estimatedRowHeight = 40
    tableView.delegate = self
    tableView.dataSource = msgViewController
    tableView.register(
      MessageCell.self,
      forCellReuseIdentifier: NSStringFromClass(MessageCell.self))
    tableView.translatesAutoresizingMaskIntoConstraints = true
    channelView.view.addSubview(tableView)
    msgViewController!.channelViewDict[title] = tableView

    let signOutButton: UIButton = UIButton(
      frame: CGRect(x: 5, y: height - 80, width: 55, height: 20))
    signOutButton.setTitle(" << ", for: UIControlState())
    signOutButton.titleLabel?.textColor = UIColor.cyan

    signOutButton.addTarget(self, action: #selector(AppDelegate.signOut(_: )), for: .touchUpInside)
    channelView.view.addSubview(signOutButton)

    let textField: UITextField = UITextField(
      frame: CGRect(x: 60, y: height - 80, width: 300, height: 20))
    textField.attributedPlaceholder = NSAttributedString(
      string: "Enter your message",
      attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
    textField.isUserInteractionEnabled = true
    textField.textColor = UIColor.white
    textField.backgroundColor = UIColor.black
    textField.becomeFirstResponder()
    textField.delegate = self
    channelView.view.addSubview(textField)

    return channelView
  }

  func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplicationOpenURLOptionsKey: Any]
  ) -> Bool {
    return GIDSignIn.sharedInstance().handle(
      url,
      sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
      annotation: [: ]
    )
  }

  func sign(_ signIn: GIDSignIn, didSignInFor user: GIDGoogleUser, withError error: Error?) {
    if let error = error {
      print("signIn error : \(error.localizedDescription)")
      return
    }

    if self.user == nil {
      self.user = user
      guard let authentication = user.authentication else { return }
      let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                     accessToken: authentication.accessToken)
      Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
        if error != nil {
          return
        }
        print("Signed-in to Firebase as \(String(describing: authResult!.user.displayName))")
        let nav = UINavigationController(
          rootViewController: self.tabBarController!)
        self.window?.rootViewController?.present( nav, animated: true, completion: nil)
        self.ref = Database.database().reference()
        self.inbox = "client-" + String(abs(self.user.userID.hash))

        self.msgViewController!.inbox = self.inbox
        self.msgViewController!.ref = self.ref

        self.requestLogger()
      }
    }
  }

  func sign(_ signIn: GIDSignIn, didDisconnectWith user: GIDGoogleUser, withError error: Error) {
    // Perform any operations when the user disconnects from the app.
  }

  @objc func signOut(_ sender: UIButton) {
    fbLog!.log(inbox, message: "Signed out")
    let firebaseAuth = Auth.auth()
    do {
      try firebaseAuth.signOut()
      let signInController = self.storyboard!
        .instantiateViewController(withIdentifier: "Signin") as UIViewController
      let nav = UINavigationController(rootViewController: signInController)
      window?.rootViewController?.present(nav, animated: false, completion: nil)
      window?.rootViewController?.dismiss(animated: false, completion: nil)
    } catch let error as NSError {
      print ("Error signing out: %@", error)
    }
    user = nil
  }

  func requestLogger() {
    ref.child(IBX + "/" + inbox!).removeValue()
    ref.child(IBX + "/" + inbox!)
      .observe(.value, with: { snapshot in
        print(self.inbox!)
        if snapshot.exists() {
          self.fbLog = FirebaseLogger(ref: self.ref, path: self.IBX + "/"
            + String(describing: snapshot.value!) + "/logs")
          self.ref.child(self.IBX + "/" + self.inbox!).removeAllObservers()
          self.msgViewController!.fbLog = self.fbLog
          self.fbLog!.log(self.inbox, message: "Signed in")
        }
      })
    ref.child(REQLOG).childByAutoId().setValue(inbox)
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if msgs.count == Int(maxMessages) {
      msgs.removeFirst()
    }
    let channel = tabBarController!.selectedViewController!
      .tabBarItem.title! as String
    let msg: Message = Message(text: textField.text!, displayName: user.profile.name)
    let entry = ref.child(CHS).child(channel).childByAutoId()
    entry.setValue(msg.toDictionary())
    textField.text = ""

    return true
  }
}
