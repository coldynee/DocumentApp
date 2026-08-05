//
//  MainTabBarController.swift
//  DocumentApp
//
//  Created by Никита Морозов on 05.08.2026.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    private let fileManagerService: FileManagerServiceProtocol
    private let settingsManager: SettingsManagerProtocol
    private let authService: AuthServiceProtocol
    private let documentsURL: URL
    
    init(fileManagerService: FileManagerServiceProtocol,
         settingsManager: SettingsManagerProtocol,
         authService: AuthServiceProtocol,
         documentsURL: URL) {
        self.fileManagerService = fileManagerService
        self.settingsManager = settingsManager
        self.authService = authService
        self.documentsURL = documentsURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let docsVC = DocumentsViewController(
            fileManagerService: fileManagerService,
            settingsManager: settingsManager,
            directoryURL: documentsURL,
            screenTitle: "Documents"
        )
        let docsNav = UINavigationController(rootViewController: docsVC)
        docsNav.tabBarItem = UITabBarItem(title: "Files",
                                          image: UIImage(systemName: "folder"),
                                          selectedImage: UIImage(systemName: "folder.fill"))
        
        let settingsVC = SettingsViewController(authService: authService)
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "Settings",
                                              image: UIImage(systemName: "gear"),
                                              selectedImage: UIImage(systemName: "gear"))
        
        viewControllers = [docsNav, settingsNav]
    }
}
