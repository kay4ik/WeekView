//
//  MapModeSetTableViewController.swift
//  Weekview
//
//  Created by Kay Boschmann on 30.10.18.
//  Copyright © 2018 Kaufland Informationssysteme GmbH & Co. KG. All rights reserved.
//

import UIKit
import MapKit

class MapModeSetTableViewController: UITableViewController {
    @IBOutlet weak var standardCheckImg: UIImageView!
    @IBOutlet weak var sateliteCheckImg: UIImageView!
    @IBOutlet weak var hybrideCheckImg: UIImageView!
    @IBOutlet weak var informationText: UITextView!
    
    private let settings = Settings.shared
    private var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Select Row
        let type = settings.mapType
        let indexPath = IndexPath(row: type, section: 0)
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.middle)
        selectionImage(show: true, Cell: type)
        informationText.text = getInfoTextFor(Cell: type)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if counter == 0 {
            selectionImage(show: false, Cell: settings.mapType)
        }
        let selection = indexPath.row
        selectionImage(show: true, Cell: selection)
        informationText.text = getInfoTextFor(Cell: selection)
        setMap(Mode: selection)
        counter += 1
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectionImage(show: false, Cell: indexPath.row)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    //MARK: - Description Texts
    private func getInfoTextFor(Cell: Int) -> String {
        let infoStandard = "Eine Karte welche Straßen und deren Namen anzeigt."
        let infoSatelite = "Ein Satelitenbild der Region. Der Datenverbrauch kann höher sein."
        let infoHybrid = "Ein Satelitenbild auf dem Straßen und deren Namen angezeigt werden. Der Datenverbrauch kann höher sein."
        
        switch Cell {
        case 0:
            return infoStandard
        case 1:
            return infoSatelite
        case 2:
            return infoHybrid
        default:
            fatalError("Invalid Selected Cell in MapModeSet VC")
        }
    }
    
    private func setMap(Mode: Int) {
        settings.mapType = Mode
    }
    
    private func selectionImage(show: Bool, Cell: Int) {
        switch Cell {
        case 0:
            standardCheckImg.isHidden = !show
        case 1:
            sateliteCheckImg.isHidden = !show
        case 2:
            hybrideCheckImg.isHidden = !show
        default:
            fatalError("Invalid Selected Cell in MapModeSet VC")
        }
    }
}
