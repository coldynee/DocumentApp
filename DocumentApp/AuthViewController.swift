//
//  AuthViewController.swift
//  DocumentApp
//
//  Created by Никита Морозов on 05.08.2026.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewControllerDidAuthenticate(_ controller: AuthViewController)
    func authViewControllerDidCancel(_ controller: AuthViewController)
}

final class AuthViewController: UIViewController {

    enum Mode {
        case signIn
        case createPassword
        case changePassword
    }

    weak var delegate: AuthViewControllerDelegate?

    private let authService: AuthServiceProtocol
    private let mode: Mode

    private enum CreateState {
        case firstEntry
        case secondEntry(first: String)
    }
    private var createState: CreateState = .firstEntry

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Пароль"
        field.isSecureTextEntry = true
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        button.isHidden = (mode != .changePassword)
        return button
    }()

    init(authService: AuthServiceProtocol, mode: Mode) {
        self.authService = authService
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        applyMode()
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(passwordField)
        view.addSubview(submitButton)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),

            passwordField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            passwordField.heightAnchor.constraint(equalToConstant: 48),

            submitButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 24),
            submitButton.leadingAnchor.constraint(equalTo: passwordField.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 48),

            cancelButton.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    private func applyMode() {
        switch mode {
        case .signIn:
            title = "Login"
            titleLabel.text = "Input password"
            submitButton.setTitle("Input password", for: .normal)
        case .createPassword:
            title = "Password create"
            titleLabel.text = "Create password"
            submitButton.setTitle("Create password", for: .normal)
        case .changePassword:
            title = "Password change"
            titleLabel.text = "Input new password"
            submitButton.setTitle("Change password", for: .normal)
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped)
            )
        }
        createState = .firstEntry
        passwordField.text = ""
    }

    @objc private func submitTapped() {
        let text = passwordField.text ?? ""

        switch mode {
        case .createPassword, .changePassword:
            handlePasswordCreation(text: text)
        case .signIn:
            handleSignIn(text: text)
        }
    }

    private func handlePasswordCreation(text: String) {
        guard text.count >= 4 else {
            showError(AuthError.passwordTooShort)
            resetToInitialState()
            return
        }

        switch createState {
        case .firstEntry:
            createState = .secondEntry(first: text)
            submitButton.setTitle("Repeat password", for: .normal)
            titleLabel.text = "Repeat password"
            passwordField.text = ""

        case .secondEntry(let first):
            if text != first {
                showError(AuthError.passwordsDontMatch)
                resetToInitialState()
                return
            }

            do {
                if mode == .changePassword {
                    try authService.savePassword(text)
                } else {
                    try authService.savePassword(text)
                }
                dismiss(animated: true) { [weak self] in
                    guard let self else { return }
                    self.delegate?.authViewControllerDidAuthenticate(self)
                }
            } catch {
                showError(error)
                resetToInitialState()
            }
        }
    }

    private func handleSignIn(text: String) {
        do {
            try authService.verifyPassword(text)
            delegate?.authViewControllerDidAuthenticate(self)
        } catch {
            showError(error)
            passwordField.text = ""
        }
    }

    private func resetToInitialState() {
        createState = .firstEntry
        passwordField.text = ""
        applyMode()
    }

    @objc private func cancelTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.delegate?.authViewControllerDidCancel(self)
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
