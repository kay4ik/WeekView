//
//  SuccessDone.swift
//  Weekview
//
//  Created by Kay Boschmann on 04.12.17.
//  Copyright © 2017 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit

class SuccessDonePopUp: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        sleep(1)
        go()
    }
    
    @IBAction func tuchUpOutside(_ sender: UITapGestureRecognizer) {
        go()
    }
    
    private func go(){
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
}
