//
//  PlayerViewController.swift
//  Liftoff
//
//  Created by Blackboxed on 2017-05-10.
//  Copyright © 2017 Blackboxed. All rights reserved.
//

import os
import UIKit
import AVFoundation
import RaunchKit

final class PlayerViewController: UIViewController {

    var videoURL: URL!
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var raunchPlayer: RaunchPlayer!
    var displayLink: CADisplayLink?
    var isScrubbing = false
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playPauseButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("Setting up...", log: playervc_log, type: .default)
        
        // Slider
        slider.setThumbImage(#imageLiteral(resourceName: "Thumb"), for: .normal)
        
        // Player
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.layer.bounds
        view.layer.addSublayer(playerLayer)
        
        // Raunch player
        let contentURL = videoURL.deletingPathExtension().appendingPathExtension("miiyoo")
        let string = try! String(contentsOfFile: contentURL.path, encoding: .utf8)
        let miiyooTrack = MiiyooTrack(string: string)
        let raunchTrack = RaunchTrack(miiyooTrack: miiyooTrack)
        raunchPlayer = Raunch.player(for: raunchTrack)
        
        // Appearance
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.toolbar.barTintColor = UIColor.black
        navigationController?.setToolbarHidden(false, animated: false)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Slider
        slider.addTarget(self, action: #selector(sliderTouchDown(sender:forEvent:)), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderTouchUp(sender:forEvent:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderTouchUp(sender:forEvent:)), for: .touchUpOutside)
        
        // Display link
        displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink?.preferredFramesPerSecond = 2
        displayLink?.add(to: .current, forMode: .defaultRunLoopMode)
        
        // Playback stopped notifications
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        os_log("Starting playback automatically", log: playervc_log, type: .default)
        play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Players
        player.pause()
        raunchPlayer.pause()
        
        // Slider
        slider.removeTarget(self, action: nil, for: .allEvents)
        
        // Display link
        displayLink?.invalidate()
        
        // Notifications
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer.frame = view.layer.bounds
    }
    
    @IBAction func doneButtonTouched(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playPauseButtonTouched(_ sender: UIBarButtonItem) {
        if isPlaying {
            pause()
        }
        else {
            play()
        }
    }
    
    @objc func sliderTouchDown(sender: UISlider, forEvent event: UIEvent) {
        isScrubbing = true
        player.pause()
        raunchPlayer.pause()
        os_log("Started scrubbing", log: playervc_log, type: .default)

    }
    
    @objc func sliderTouchUp(sender: UISlider, forEvent event: UIEvent) {
        let totalTime = player.currentItem!.duration
        let targetTime = totalTime.seconds * Double(slider.value)
        raunchPlayer.seek(to: RaunchTimeInterval(milliseconds: Int64(targetTime * 1000.0)))
        player.seek(to: CMTime(seconds: targetTime, preferredTimescale: totalTime.timescale))
        isScrubbing = false
        os_log("Stopped scrubbing at %.2f", log: playervc_log, type: .default, targetTime)
        
        if isPlaying {
            play()
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let value = sender.value
        let totalTime = player.currentItem!.duration
        let targetTime = totalTime.seconds * Double(value)
        os_log("Seeking to %.2f", log: playervc_log, type: .default, targetTime)
        player.seek(to: CMTime(seconds: targetTime, preferredTimescale: totalTime.timescale))
    }
    
    var isPlaying = false {
        didSet {
            if isPlaying {
                playPauseButton.image = #imageLiteral(resourceName: "PauseIcon")
            }
            else {
                playPauseButton.image = #imageLiteral(resourceName: "PlayIcon")
            }
        }
    }
    
    func play() {
        os_log("Playing", log: playervc_log, type: .default)
        isPlaying = true
        player.play()
        raunchPlayer.play()
    }
    
    func pause() {
        os_log("Pausing", log: playervc_log, type: .default)
        isPlaying = false
        player.pause()
        raunchPlayer.pause()
    }
    
    @objc func playerDidFinishPlaying(notification: NSNotification) {
        os_log("Playback ended", log: playervc_log, type: .default)
        isPlaying = false
    }
    
    @objc func step(displaylink: CADisplayLink) {
        if !isScrubbing {
            let time = player.currentTime()
            let totalTime = player.currentItem!.duration
            let progress = Float(time.seconds / totalTime.seconds)
            slider.setValue(progress, animated: false)
        }
    }
}
