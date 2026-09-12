//
//  RandomQuoteViewController.swift
//  DocumentApp
//
//  Created by Никита Морозов on 13.09.2026.
//

import UIKit
import Combine

final class RandomQuoteViewController: UIViewController {
    private let viewModel: RandomQuoteViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let quoteLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Загрузить цитату", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: RandomQuoteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Случайная цитата"
        
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.addSubview(quoteLabel)
        view.addSubview(loadButton)
        
        NSLayoutConstraint.activate([
            quoteLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            quoteLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            quoteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            quoteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            loadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            loadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadButton.widthAnchor.constraint(equalToConstant: 200),
            loadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        loadButton.addTarget(self, action: #selector(loadButtonTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.$quoteText
            .sink { [weak self] text in
                self?.quoteLabel.text = text
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .sink { [weak self] isLoading in
                self?.loadButton.isEnabled = !isLoading
                self?.loadButton.setTitle(isLoading ? "Загрузка..." : "Загрузить цитату", for: .normal)
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .sink { [weak self] error in
                if let error = error {
                    self?.showAlert(message: error)
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func loadButtonTapped() {
        viewModel.loadAndSaveQuote()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
