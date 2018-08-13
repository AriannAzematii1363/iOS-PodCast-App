//
//  PodcastCell.swift
//  PodcastsCourseLBTA
//
//  Created by Arian Azemati on 2018-08-10.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
    
    
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    var podcast :Podcast! {
        didSet {
            artistNameLabel.text = podcast.artistName
            trackNameLabel.text  = podcast.trackName
            
            
            episodeCountLabel.text = "\(podcast.trackCount ?? 0) Episodes"
            
           
            
            guard let url = URL(string: podcast.artworkUrl100 ?? "") else {return}
//            URLSession.shared.dataTask(with: url) { (data, _, _) in
//                print("Finished Downloading Image data:", data)
//                guard let data = data else {return}
//                DispatchQueue.main.async {
//                    self.podcastImageView.image = UIImage(data: data)
//                }
//            }.resume()
            
            podcastImageView.sd_setImage(with: url, completed: nil)
            
        }
    }
    
    
}
