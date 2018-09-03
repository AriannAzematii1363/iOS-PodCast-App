//
//  DownloadsController.swift
//  PodcastsCourseLBTA
//
//  Created by Arian Azemati on 2018-09-02.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController {
   
    var episodes = UserDefaults.standard.downloadedEpisode()
    
    fileprivate let cellId = "cellId"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        setupTableView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        episodes = UserDefaults.standard.downloadedEpisode()
        tableView.reloadData()
    }
    
    
    //MARK:- Setup
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    //MARK:- UItableView
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let episode = episodes[indexPath.row]
        episodes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        UserDefaults.standard.deleteEpisode(episode: episode)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let episode = self.episodes[indexPath.row]
        
        if episode.fileUrl != nil {
            UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playListEpisodes: self.episodes)
            print("lunch episode player")
        } else {
            let alertController = UIAlertController(title: "File URL Not Found", message: "can not find local file play using stream URL instead", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "YES", style: .default, handler: { (_) in
                UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playListEpisodes: self.episodes)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
      
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        cell.episode = self.episodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
    
    
}
