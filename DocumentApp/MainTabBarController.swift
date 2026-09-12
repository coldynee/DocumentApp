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
        
        let randomViewModel = RandomQuoteViewModel(
            realmService: RealmService(),
            networkService: ChuckNorrisNetworkService.shared
        )
        let randomQuoteVC = RandomQuoteViewController(viewModel: randomViewModel)
        let randomNav = UINavigationController(rootViewController: randomQuoteVC)
        randomNav.tabBarItem = UITabBarItem(title: "Загрузка", image: UIImage(systemName: "arrow.down.circle"), tag: 0)
        
        let allQuotesViewModel = AllQuotesViewModel(realmService: RealmService())
        let allQuotesVC = AllQuotesViewController(viewModel: allQuotesViewModel)
        let allNav = UINavigationController(rootViewController: allQuotesVC)
        allNav.tabBarItem = UITabBarItem(title: "Все цитаты", image: UIImage(systemName: "list.bullet"), tag: 1)
        
        let categoriesViewModel = CategoriesViewModel(realmService: RealmService())
        let categoriesVC = CategoriesViewController(viewModel: categoriesViewModel)
        let catNav = UINavigationController(rootViewController: categoriesVC)
        catNav.tabBarItem = UITabBarItem(title: "Категории", image: UIImage(systemName: "folder"), tag: 2)
        
        viewControllers = [docsNav, settingsNav, randomNav, allNav, catNav]
    }
}
