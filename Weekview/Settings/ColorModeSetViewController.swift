//
//  ColorModeSetViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 31.10.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit

class ColorModeSetViewController: UIViewController {
    @IBOutlet weak var colorModeSelector: UISegmentedControl!
    @IBOutlet weak var prioHighView: UIView!
    @IBOutlet weak var prioMidView: UIView!
    @IBOutlet weak var prioLowView: UIView!
    
    private let setting = Settings.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mode = setting.colorMode
        colorModeSelector.selectedSegmentIndex = mode
        changeColorsTo(mode: mode)
    }
    
    private func changeColorsTo(mode: Int) {
        prioHighView.backgroundColor = PriorityMngr.getColorOf(priority: 2, colorMode: mode)
        prioMidView.backgroundColor = PriorityMngr.getColorOf(priority: 1, colorMode: mode)
        prioLowView.backgroundColor = PriorityMngr.getColorOf(priority: 0, colorMode: mode)
    }
    
    private func change(mode: Int) {
        setting.colorMode = mode
    }
    
    @IBAction func colorSelectorChanged(_ sender: Any) {
        let mode = colorModeSelector.selectedSegmentIndex
        changeColorsTo(mode: mode)
        change(mode: mode)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
