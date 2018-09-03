//
//  EpisodeCell.swift
//  PodcastsCourseLBTA
//
//  Created by Arian Azemati on 2018-08-11.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import UIKit
import SDWebImage

class EpisodeCell: UITableViewCell {
    
    
    var episode: Episode! {
        didSet {
            descriptionLabel.text = episode.description
            titleLabel.text = episode.title
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
            
            let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "") 
            episodeImageView.sd_setImage(with: url, completed: nil)
            
        }
    }
    
    
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet{
            titleLabel.numberOfLines = 2
        }
    }
        
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 2
        }
    }
    
}
