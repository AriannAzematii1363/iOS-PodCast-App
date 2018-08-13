//
//  PlayerDetailsView.swift
//  PodcastsCourseLBTA
//
//  Created by Arian Azemati on 2018-08-11.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import UIKit
import AVKit


class PlayerDetailsView: UIView {
    
    
    var episode : Episode! {
        didSet {
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            
            playEpisode()
            
            guard let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "") else {return}
            episodeImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    
    
    fileprivate func playEpisode() {
        print(" Trying to play episode at url",episode.streamUrl)
        
        
        guard let url = URL(string: episode.streamUrl.toSecureHTTPS()) else {return}
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(1, 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {[weak self] (time) in
            
            self?.currentTimeLabel.text = time.toDisplayString()
            let durationTime = self?.player.currentItem?.duration
            self?.durationLabel.text = durationTime?.toDisplayString()
            
            
          self?.updateCurrentTimeSlider()
        }
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(1, 1))
        let percentage = currentTimeSeconds / durationSeconds
        
        self.currentTimeSlider.value = Float(percentage)
    }
    
    override func awakeFromNib() {
      super.awakeFromNib()
        
        observePlayerCurrentTime()
        
        let time = CMTimeMake(1, 3)
       
        let times = [ NSValue(time:time)]
        player.addBoundaryTimeObserver(forTimes:  times, queue: .main) {
            [weak self] in
            self?.enlargeEpisodeImageView()
        }
    }
    
    deinit {
        print("PlayerDetailsview Momory being reclaimed...")
    }
    
    
    //MARK:- IB Actions and Outlets
    
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        print("Slider Value",currentTimeSlider.value)
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, Int32(NSEC_PER_SEC))
        
        player.seek(to: seekTime)
    }
    
    @IBAction func handleRewind(_ sender: Any) {
    seekToCurrentTime(delta: -15)
    }
    
    @IBAction func handleFastForward(_ sender: Any) {
      seekToCurrentTime(delta: 15)
    }
    
    
    fileprivate func seekToCurrentTime(delta: Int64) {
        let fifteenSeconds = CMTimeMake(delta, 1)
        let seekTime =  CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    
    
    @IBAction func handleVolumechange(_ sender: Any) {
      player.volume = volumeSlider.value
    }
    
    
    @IBOutlet weak var currentTimeSlider: UISlider!
     
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBAction func handleDismiss(_ sender: Any) {
         self.removeFromSuperview()
    }
    
    
    fileprivate func enlargeEpisodeImageView() {
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        })
    }
    
    fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    fileprivate func shrinkEpisodeImageView() {
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform =  self.shrunkenTransform
        })
    }
    
    
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet{
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @objc func handlePlayPause() {
        print("Try to play and Pause")
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
        }
   
    }
    
    
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            //this lines of code will get call when the interface bulder set up image view
            
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
            episodeImageView.transform = shrunkenTransform
            
            
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
    
    @IBOutlet weak var authorLabel: UILabel!
    
    
    
    
    
    
    
    
}
