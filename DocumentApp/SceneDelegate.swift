//
//  SceneDelegate.swift
//  DocumentApp
//
//  Created by Никита Морозов on 05.08.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private let authService: AuthServiceProtocol = AuthService()
    private let fileManagerService: FileManagerServiceProtocol = FileManagerService()
    private let settingsManager: SettingsManagerProtocol = SettingsManager()
    
    private lazy var documentsURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        if authService.hasSavedPassword() {
            showAuthScreen(mode: .signIn, in: window)
        } else {
            showAuthScreen(mode: .createPassword, in: window)
        }
        
        window.makeKeyAndVisible()
    }
    private func showAuthScreen(mode: AuthViewController.Mode, in window: UIWindow) {
        let authVC = AuthViewController(authService: authService, mode: mode)
        authVC.delegate = self
        let nav = UINavigationController(rootViewController: authVC)
        window.rootViewController = nav
    }
    
    private func showMainScreen(in window: UIWindow) {
        let tabBar = MainTabBarController(
            fileManagerService: fileManagerService,
            settingsManager: settingsManager,
            authService: authService,
            documentsURL: documentsURL
        )
        window.rootViewController = tabBar
        
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil)
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

extension SceneDelegate: AuthViewControllerDelegate {
    func authViewControllerDidAuthenticate(_ controller: AuthViewController) {
        guard let window else { return }
        showMainScreen(in: window)
    }

    func authViewControllerDidCancel(_ controller: AuthViewController) {
        // Отмена возможна только на экране смены пароля — он закрылся модалкой, ничего не делаем.
    }
}
