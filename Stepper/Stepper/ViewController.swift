//
//  ViewController.swift
//  Stepper
//
//  Created by Oğuzhan Kertmen on 22.04.2023.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var stepProgressBar: StepperView!

    override func viewDidLoad() {
        super.viewDidLoad()
        stepProgressBar.numberOfPoints = 3
        stepProgressBar.currentIndex = 1
        stepProgressBar.stepperType = .Numeric
        stepProgressBar.stepperIcons[0] = "step1"
        stepProgressBar.stepperIcons[1] = "step2"
        stepProgressBar.stepperIcons[2] = "step3"
    }


}

