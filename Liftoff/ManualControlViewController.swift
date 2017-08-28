//
//  ManualControlViewController.swift
//  Liftoff
//
//  Created by Blackboxed on 2017-04-26.
//  Copyright © 2017 Blackboxed. All rights reserved.
//

import UIKit
import RaunchKit

final class ManualControlViewController: UIViewController {

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let position = Int(round(sender.value))
        do {
            try Raunch.position(position, speed: 99)
        }
        catch {
            debugPrint(error)
        }
    }
    
}

