//
//  CategoriesViewController.swift
//  DocumentApp
//
//  Created by Никита Морозов on 13.09.2026.
//

import UIKit
import Combine

final class CategoriesViewController: UIViewController {
    private let viewModel: CategoriesViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Категории"
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        
        bindViewModel()
        viewModel.loadCategories()
    }
    
    private func bindViewModel() {
        viewModel.$categories.sink { [weak self] _ in
            self?.tableView.reloadData()
        }.store(in: &cancellables)
    }
}

extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = viewModel.categories[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCategory = viewModel.categories[indexPath.row]
        
        let quotes = viewModel.getQuotes(for: selectedCategory)
        let detailVC = CategoryQuotesViewController(categoryName: selectedCategory, quotes: quotes)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
