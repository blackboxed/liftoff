//
//  GeneratorViewController.swift
//  Liftoff
//
//  Created by Blackboxed on 2017-05-12.
//  Copyright © 2017 Blackboxed. All rights reserved.
//

import os
import UIKit
import RaunchKit

final class GeneratorViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("Setting up...", log: generatorvc_log, type: .default)
        
        // Appearance
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Slider
        periodSlider.addTarget(self, action: #selector(periodSliderTouchUp(sender:forEvent:)), for: .touchUpInside)
        periodSlider.addTarget(self, action: #selector(periodSliderTouchUp(sender:forEvent:)), for: .touchUpOutside)
        speedSlider.addTarget(self, action: #selector(speedSliderTouchUp(sender:forEvent:)), for: .touchUpInside)
        speedSlider.addTarget(self, action: #selector(speedSliderTouchUp(sender:forEvent:)), for: .touchUpOutside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopGenerator()
    }
    
    private var isPlaying = false {
        didSet {
            if isPlaying {
                startStopButton.image = #imageLiteral(resourceName: "PauseIcon")
            }
            else {
                startStopButton.image = #imageLiteral(resourceName: "PlayIcon")
            }
        }
    }
    
    private var period = 250 {
        didSet {
            if isPlaying {
                startGenerator()
            }
        }
    }
    
    private var speed = 50 {
        didSet {
            if isPlaying {
                startGenerator()
            }
        }
    }
    
    private var generator: RaunchGenerator?
    
    private func startGenerator() {
        generator?.stop()
        generator = try? Raunch.generator(period: RaunchTimeInterval(milliseconds: Int64(period)), speed: speed)
        generator?.start()
        isPlaying = true
    }
    
    private func stopGenerator() {
        generator?.stop()
        generator = nil
        isPlaying = false
    }
    
    @IBOutlet weak var periodSlider: UISlider!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var startStopButton: UIBarButtonItem!
    
    @IBAction func periodSliderValueChanged(_ sender: UISlider) {
        periodLabel.text = "Period: \(Int(sender.value)) ms"
    }
    
    @objc func periodSliderTouchUp(sender: UISlider, forEvent event: UIEvent) {
        let value = Int(sender.value)
        periodLabel.text = "Period: \(value) ms"
        period = value
        sender.setValue(Float(value), animated: true)
    }
    
    @IBAction func speedSliderValueChanged(_ sender: UISlider) {
        speedLabel.text = "Speed: \(Int(sender.value))"
    }

    @objc func speedSliderTouchUp(sender: UISlider, forEvent event: UIEvent) {
        let value = Int(sender.value)
        speedLabel.text = "Speed: \(value)"
        speed = value
        sender.setValue(Float(value), animated: true)
    }
    
    @IBAction func startStopButtonTouched(_ sender: UIBarButtonItem) {
        if isPlaying {
            stopGenerator()
        }
        else {
            startGenerator()
        }
    }
}
