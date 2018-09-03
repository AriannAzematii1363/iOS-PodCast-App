//
//  PlayerDetailsView.swift
//  PodcastsCourseLBTA
//
//  Created by Arian Azemati on 2018-08-11.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailsView: UIView {
    
    
    var episode : Episode! {
        didSet {
            miniTitleLabel.text = episode.title
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            
            setUpNowPlayingInfo()
             setupAudioSession()
            playEpisode()
            
            guard let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "") else {return}
            episodeImageView.sd_setImage(with: url, completed: nil)
            miniEpisodeImageView.sd_setImage(with: url, completed: nil)
            
            miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
                let image = self.episodeImageView.image ?? UIImage()
                
                let artworkItem = MPMediaItemArtwork(boundsSize: .zero, requestHandler: { (size) -> UIImage in
                    return image
                })
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artworkItem
            }
            
            
        }
    }
    
    fileprivate func setUpNowPlayingInfo() {
        
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func playEpisode() {
        playEpisodeUsingFileURL()
        if episode.fileUrl != nil {
        } else {
            print(" Trying to play episode at url",episode.streamUrl)
            
            
            guard let url = URL(string: episode.streamUrl.toSecureHTTPS()) else {return}
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            player.play()
        }

    }
    
    fileprivate func playEpisodeUsingFileURL() {
        print("attempt to play episode with file url:", episode.fileUrl ?? "")
        
        //lets figure out the file name for our episode file url
        guard let fileURL = URL(string: episode.fileUrl ?? "") else {return}
        
        let fileName = fileURL.lastPathComponent
        
        guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return}
        
        trueLocation.appendPathComponent(fileName)
        print("true location of episode",trueLocation.absoluteString)
        let playerItem = AVPlayerItem(url: trueLocation)
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
    
    
    var panGesture : UIPanGestureRecognizer!
    
    fileprivate func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
        
        maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
    }
    
    
    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        
        print("MaximiesStackView dismmal")
        
        
        if gesture.state == .changed {
            let translation = gesture.translation(in: self.superview)
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
           // print(translation.y, velocity)
        } else if gesture.state == .ended {
            let translation = gesture.translation(in: self.superview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.maximizedStackView.transform = .identity
                if translation.y > 50 {
                 
                 UIApplication.mainTabBarController()?.minimizePlayerDetails()
        
                }
                
            })
        }
    
    }
    fileprivate func setupAudioSession() {
        do {
           try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
          try AVAudioSession.sharedInstance().setActive(true)
        }catch let  sessionErr {
            print("Failed to activate session",sessionErr)
        }
        
    }
    
    fileprivate func  setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
          self.player.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
            self.setupElapsedTime(playbackRate: 1)
          
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.setupElapsedTime(playbackRate: 0)
            
            
            return .success
        }
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            self.handlePlayPause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePrevTrack))
    }
    

    var playListEpisodes = [Episode]()
    
    @objc fileprivate func handlePrevTrack() {
        if playListEpisodes.isEmpty {
            return
        }
        
        let currentEpisodeIndex = playListEpisodes.index { (ep) -> Bool in
            self.episode.title == ep.title && self.episode.author == ep.author
        }
        
        guard let index = currentEpisodeIndex else {return}
        
        let previouseEpisode : Episode
        
        if index == 0 {
            let count = playListEpisodes.count
           previouseEpisode = playListEpisodes[count - 1]
        } else {
            previouseEpisode = playListEpisodes[index - 1]
        }
        self.episode = previouseEpisode
    }
    
    @objc fileprivate func handleNextTrack() {
        if playListEpisodes.count == 0 {
            return
        }
        
        let currentEpisodeIndex = playListEpisodes.index { (ep) -> Bool in
            return  self.episode.title == ep.title && self.episode.author == ep.author
        }
        
        guard let index = currentEpisodeIndex else {return }
        
        let nextEpisode: Episode
        if index ==  playListEpisodes.count - 1 {
            nextEpisode = playListEpisodes[0]
        } else {
            nextEpisode = playListEpisodes[index + 1]
        }
        self.episode = nextEpisode
    }
    
    fileprivate func setupElapsedTime(playbackRate : Float) {
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }
    
    fileprivate func observeBoundaryTime() {
        let time = CMTimeMake(1, 3)
        
        
        let times = [ NSValue(time:time)]
        player.addBoundaryTimeObserver(forTimes:  times, queue: .main) {
            [weak self] in
            self?.enlargeEpisodeImageView()
            self?.setupLockScreenDuration()
        }
    }
    
    fileprivate func setupLockScreenDuration() {
        
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
    }
    
    fileprivate func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: .AVAudioSessionInterruption, object: nil)
    }
    
    @objc fileprivate func handleInterruption(notification : Notification) {

        guard let userInfo =  notification.userInfo else {return}
        
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else {return}
        
        if type == AVAudioSessionInterruptionType.began.rawValue {
            print("Inerruption began")
            
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        } else {
            print("interrption ended ..")
            guard let options =  userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {return}
            
            if options == AVAudioSessionInterruptionOptions.shouldResume.rawValue {
                player.play()
                playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
      
            
        }
        
       //AVAudioSessionInterruptionType.
    }
    
    
    override func awakeFromNib() {
        
      super.awakeFromNib()
        setupRemoteControl()
       
        setupGestures()
        setupInterruptionObserver()
        
        
         observePlayerCurrentTime()
        
        observeBoundaryTime()
    }
    
    
  
    
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }
    
    deinit {
        print("PlayerDetailsview Momory being reclaimed...")
    }
    
    
    //MARK:- IB Actions and Outlets
    
    
    
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    
    
    @IBOutlet weak var miniTitleLabel: UILabel!
    
    @IBOutlet weak var maximizedStackView: UIStackView!
    
    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
            miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    
    @IBOutlet weak var miniFastForwardButton: UIButton! {
        didSet{
            miniFastForwardButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            miniFastForwardButton.addTarget(self, action: #selector(handleFastForward), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var miniPlayerView: UIView!
    
    
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        print("Slider Value",currentTimeSlider.value)
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, Int32(NSEC_PER_SEC))
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
       
        
        
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
        // self.removeFromSuperview()
        
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.minimizePlayerDetails()
        
      
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
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
            self.setupElapsedTime(playbackRate: 1)
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
             self.setupElapsedTime(playbackRate: 0)
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
