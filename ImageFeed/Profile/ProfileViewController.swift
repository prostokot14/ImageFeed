//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Антон Кашников on 16.05.2023.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    // MARK: - Visual Components
    private var profileImageView = UIImageView()
    private var nameLabel = UILabel()
    private var loginNameLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var logoutButton = UIButton()

    // MARK: - Private Properties
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var animationLayers = Set<CALayer>()
    
    // MARK: - UIViewController
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypBlack
        
        configureLogoutButton()
        configureProfileImageView()
        configureNameLabel()
        configureLoginNameLabel()
        configureDescriptionLabel()

        profileImageServiceObserver = NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.animationLayers.forEach {
                $0.removeFromSuperlayer()
            }
            self?.updateAvatar()
        }

        setupPhotoGradient()
        setupLabelsGradient()
        updateAvatar()
        updateProfileDetails()
    }

    // MARK: - Private methods
    private func updateAvatar() {
        guard let profileImagePath = ProfileImageService.shared.avatarURL else {
            return
        }

        let processor = RoundCornerImageProcessor(cornerRadius: 16, backgroundColor: UIColor.ypBlack)
        
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: URL(string: profileImagePath), options: [.processor(processor)]) { [weak self] result in
            switch result {
            case .success(_):
                self?.animationLayers.forEach {
                    $0.removeFromSuperlayer()
                }
            case .failure(let error):
                print(error.localizedDescription)
                self?.profileImageView.image = UIImage(named: "placeholder.jpeg")
            }
        }
    }

    private func configureProfileImageView() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.trailingAnchor.constraint(lessThanOrEqualTo: logoutButton.leadingAnchor, constant: 0)
        ])
    }
    
    private func configureNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .ypWhite
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: UIFont.Weight(700))
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureLoginNameLabel() {
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.textColor = .ypGray
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(loginNameLabel)
        
        NSLayoutConstraint.activate([
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    private func configureDescriptionLabel() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    private func configureLogoutButton() {
        logoutButton = UIButton.systemButton(with: UIImage(named: "logout_button") ?? UIImage(), target: self, action: #selector(didTapLogoutButton))
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.tintColor = .ypRed
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    private func updateProfileDetails() {
        nameLabel.text = profileService.profile?.name
        loginNameLabel.text = profileService.profile?.loginName
        descriptionLabel.text = profileService.profile?.bio
    }
    
    private func switchToSplashViewController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else {
            fatalError("Invalid Configuration")
        }
        
        let splashViewController = SplashViewController()
        splashViewController.logout = "logout"
        window.rootViewController = splashViewController
    }
    
    private func setupPhotoGradient() {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor, UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor, UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 35
        gradient.masksToBounds = true
        animationLayers.insert(gradient)
        profileImageView.layer.addSublayer(gradient)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsPhotoChange")
        
        // TODO: add gradient for labels
    }
    
    private func setupLabelsGradient() {
        let gradientNameLabel = CAGradientLayer()
        gradientNameLabel.frame = CGRect(origin: .zero, size: nameLabel.frame.size)
        gradientNameLabel.locations = [0, 0.1, 0.3]
        gradientNameLabel.colors = [UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor, UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor, UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor]
        gradientNameLabel.startPoint = CGPoint(x: 0, y: 0.5)
        gradientNameLabel.endPoint = CGPoint(x: 1, y: 0.5)
        animationLayers.insert(gradientNameLabel)
        nameLabel.layer.addSublayer(gradientNameLabel)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientNameLabel.add(gradientChangeAnimation, forKey: "locationsNameLabelChange")
    }
    
    @objc private func didTapLogoutButton() {
        let alertController = UIAlertController(title: "Вы уверены, что хотите выйти?", message: "Чтобы продолжить смотреть фотографии, нужно будет заново авторизоваться.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self else {
                return
            }
            
            self.profileService.clean()
            
            self.updateAvatar()
            self.nameLabel = UILabel()
            self.loginNameLabel = UILabel()
            self.descriptionLabel = UILabel()
            self.logoutButton = UIButton()
            
            self.switchToSplashViewController()
        })
        alertController.addAction(UIAlertAction(title: "Нет", style: .cancel))
        present(alertController, animated: true)
    }
}
