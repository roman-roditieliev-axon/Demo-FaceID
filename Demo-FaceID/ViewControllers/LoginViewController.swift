//
//  ViewController.swift
//  Demo-FaceID
//
//  Created by User on 14.07.2021.
//

import UIKit

// @Published var username = "a_podcast_admin@axon.dev"
//@Published var password = "Qwerty1234567"

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    // MARK: - Properties

    private let segueMainIdentifier = "Main"
    private var networkManager = NetworkManager()
    private var storage = Storage()
    private var biometric = BiometricAuthManager()

    private var email = ""
    private var password = ""

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()

        if !storage.isFirstLaunch {
            checkFaceID()
        }
    }

    // MARK: - Setup VC

    private func setupVC() {
        emailTextField.delegate = self
        passwordTextField.delegate = self

        loginButton.layer.cornerRadius = 5
        emailTextField.layer.cornerRadius = 5
        passwordTextField.layer.cornerRadius = 5
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])

        emailTextField.layer.borderWidth = 2
        passwordTextField.layer.borderWidth = 2
        loginButton.layer.borderWidth = 2

        emailTextField.layer.borderColor = UIColor.darkGray.cgColor
        passwordTextField.layer.borderColor = UIColor.darkGray.cgColor
        loginButton.layer.borderColor = UIColor.darkGray.cgColor

        loginButton.isUserInteractionEnabled = self.storage.isFirstLaunch ? true : false
    }

    // MARK: - Login logic

    private func showAlert(error: String) {
        let alertView = UIAlertController(title: "Error",
                                          message: error,
                                          preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertView.addAction(okAction)
        DispatchQueue.main.async {
            self.loginButton.isUserInteractionEnabled = self.storage.isFirstLaunch ? true : false
            self.present(alertView, animated: false)
        }
    }

    private func savePassword() {
        do {
            let passwordItem = KeychainManager(service: KeychainConfiguration.serviceName,
                                               account: self.email,
                                               accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.savePassword(self.password)
            self.storage.userEmail = self.email
            self.storage.isFirstLaunch = false
        }
        catch {
            fatalError("Error reading password from keychain - \(error)")
        }
    }

    private func login() {
        if !email.isEmpty && !password.isEmpty {
            networkManager.login(email: email, password: password, completion: { response in
                if self.storage.isFirstLaunch {
                    self.savePassword()
                    self.checkFaceID()
                } else {
                    self.goToMainVC()
                }
            })
        }
    }

    private func checkCredentialsFromKeychain() {
        if !storage.isFirstLaunch && !storage.userEmail.isEmpty {
            do {
                let passwordItem = KeychainManager(service: KeychainConfiguration.serviceName,
                                                        account: storage.userEmail,
                                                        accessGroup: KeychainConfiguration.accessGroup)
                let keychainPassword = try passwordItem.readPassword()
                self.password = keychainPassword
                self.email = storage.userEmail
                self.login()
            }
            catch {
              fatalError("Error reading password from keychain - \(error)")
            }
        }
    }

    private func checkFaceID() {
        self.biometric.authenticateUser { (message) in
            if let error = message {
                self.storage.isFirstLaunch = true
                self.storage.userEmail = ""
                self.showAlert(error: error)
            } else {
                self.checkCredentialsFromKeychain()
            }
        }
    }

    // MARK: - Actions

    private func goToMainVC() {
        performSegue(withIdentifier: segueMainIdentifier, sender: nil)
    }

    @IBAction func didTapLoginButton(_ sender: Any) {
        self.view.endEditing(true)
        login()
    }

}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            switch textField {
            case emailTextField:
                self.email = text
            case passwordTextField:
                self.password = text
            default:
                break
            }
        }
    }
}
