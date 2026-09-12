//
//  CategoryQuotesViewController.swift
//  DocumentApp
//
//  Created by Никита Морозов on 13.09.2026.
//

import UIKit

final class CategoryQuotesViewController: UIViewController {
    private let quotes: [QuoteObject]
    private let categoryName: String
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "QuoteCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    init(categoryName: String, quotes: [QuoteObject]) {
        self.categoryName = categoryName
        self.quotes = quotes
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = categoryName
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension CategoryQuotesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        let quote = quotes[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = quote.text
        content.secondaryText = quote.createdAt.formatted()
        cell.contentConfiguration = content
        return cell
    }
}
