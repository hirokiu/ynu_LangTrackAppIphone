//
//  AppDelegate.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-01-30.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

enum Identifiers {
    static let viewAction = "VIEW_IDENTIFIER"
    static let viewAction2 = "VIEW_IDENTIFIER2"
    static let newsCategory = "NEWS_CATEGORY"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {


    let gcmMessageIDKey = "gcm.message_id"
    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if #available(iOS 13.0, *) {
            // In iOS 13 setup is done in SceneDelegate
        } else {
            let window = UIWindow(frame: UIScreen.main.bounds)
            self.window = window
            
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller:UIViewController = mainstoryboard.instantiateViewController(withIdentifier: "main") as! MainViewController
            window.rootViewController = newViewcontroller
        }
        if #available(iOS 15.0, *){
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        
        //om appen är stängd och man får en notis så visas alert, men ingen funktion körs... man måste hantera badge via notisen, man måste hålla räkningen i backend!!
        //registerForPushNotifications()
        print("makeNewItem in didFinishLaunchingWithOptions1")
        
        // Kolla om appen startas genom klick på notifikation, här hanteras notifikation om appen inte är igång
        //om appen redan är igång, i förgrund eller bakgrund, hanteras notifikationer i didReceiveRemoteNotification
        /*
         Kolla om värdet UIApplication.LaunchOptionsKey.remoteNotification existerar i launchOptions. Om det gör det är appen uppstartad genom att användaren klickade på en notifikation.
         .remoteNotification innehåller det skickade meddelandet
         */
        /*let notificationOption = launchOptions?[.remoteNotification]
        print("running didFinishLaunchingWithOptions...")
        
        // 1
        if let notification = notificationOption as? [String: AnyObject],
            let aps = notification["aps"] as? [String: AnyObject] {
            
            // 2
            //setBadge()
            print("makeNewItem in didFinishLaunchingWithOptions2")
        }*/
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        if #available(iOS 13.0, *) {
            // In iOS 13 setup is done in SceneDelegate
        } else {
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken)")

        let dataDict:[String: String?] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        SurveyRepository.deviceToken = fcmToken!
        var username = Auth.auth().currentUser?.email
        if username != nil{
            if username! != ""{
                username!.until("@")
                SurveyRepository.userId = username ?? ""
            }
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("didReceiveRemoteNotification Message ID: \(messageID)")
        }
        //send notification to update surveys
        NotificationCenter.default.post(
            name: .newNotification,
            object: nil)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    //här hanteras notifikation om appen är igång
    /*func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        //setBadge()
        print("makeNewItem in didReceiveRemoteNotification")
        //send notification to update surveys
        NotificationCenter.default.post(
            name: .newNotification,
            object: nil)
        completionHandler(.newData)
    }*/
    
    /*func setBadge()  {
        var ind = 0
        let newsStore = ItemsStore.shared
        for j in newsStore.items {
            if(j.viewed != true){
                ind += 1
            }
        }
        if(ind <= 0){
            UIApplication.shared.applicationIconBadgeNumber = 0
        }else{
            UIApplication.shared.applicationIconBadgeNumber = ind
        }
    }*/

}
//Whenever a notification action is triggered
//här hanteras även tryck på View(knapp) i notis
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // 1
        let notificationPayload = response.notification.request.content.userInfo
        
        // 2
        if let aps = notificationPayload["aps"] as? [String: AnyObject]{
            //setBadge()
            print("makeNewItem in didReceive response:")
            
            // 3
            /*if response.actionIdentifier == Identifiers.viewAction{
                print("du valde viewAction")
            }
            if (response.actionIdentifier == Identifiers.viewAction2){
                print("du valde viewAction2")
            }*/
            //send notification with notification info, to update surveys
            
        }
        NotificationCenter.default.post(
        name: .newNotification,
        object: nil)
        
        
        // 4
        completionHandler()
    }
}

