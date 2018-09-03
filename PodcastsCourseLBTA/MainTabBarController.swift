//
//  MainTabBarController.swift
//  PodcastsCourseLBTA
//
//  Created by Brian Voong on 2/13/18.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().prefersLargeTitles = true
        
        tabBar.tintColor = .purple
        
        setupViewControllers()
        
        setupPlayerDetailsView()
        
    }
    
    
    
    func maximizePlayerDetails(episode: Episode?, playListEpisodes:[Episode] = []) {
        
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        
        
        self.bottomAnchorConstraint.constant = 0
        
        if episode != nil {
             playerDetailsView.episode = episode
        }
       
        playerDetailsView.playListEpisodes = playListEpisodes
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            self.playerDetailsView.maximizedStackView.alpha = 1
            self.playerDetailsView.miniPlayerView.alpha = 0
            
        })
    }
    
    @objc func minimizePlayerDetails() {
      print("122")
        
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            
            self.tabBar.transform = .identity
            self.view.layoutIfNeeded()
            self.playerDetailsView.maximizedStackView.alpha = 0
            self.playerDetailsView.miniPlayerView.alpha = 1
            
        })
    }
    
    //MARK:- Setup Functions
    
    let playerDetailsView = PlayerDetailsView.initFromNib()
    
    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    
    
    
   fileprivate func setupPlayerDetailsView() {
    
    view.insertSubview(playerDetailsView, belowSubview: tabBar)

    //use auto layout
    
    playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
    
    maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant:  view.frame.height)
    
    maximizedTopAnchorConstraint.isActive = true
    
    bottomAnchorConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
     bottomAnchorConstraint.isActive = true
    
    
    
    minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
  //  minimizedTopAnchorConstraint.isActive = true
    
    playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    
    
    }
    
    func setupViewControllers() {
        let layout  = UICollectionViewFlowLayout()
        let favoritesController = FavoritesController(collectionViewLayout: layout)
        viewControllers = [
            generateNavigationController(for: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavigationController(for: favoritesController, title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
            generateNavigationController(for: DownloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        ]
    }
    
    //MARK:- Helper Functions
    
    fileprivate func generateNavigationController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
//        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }
    
    
    
    
    
    
}
