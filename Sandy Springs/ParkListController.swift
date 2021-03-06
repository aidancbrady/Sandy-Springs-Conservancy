//
//  ParkSearchController.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 1/19/18.
//  Copyright © 2018 aidancbrady. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class ParkSearchController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var allCells: [ParkCell] = [ParkCell]()
    var filterCells: [ParkCell] = [ParkCell]()
    var distances = [String: Double]()
    
    var selectedAmenities: [String] = [String]()
    var isAmenitySearch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //show nav bar
        navigationController!.navigationBar.isHidden = false
        
        for data in Constants.parkData {
            var valid = true
            
            if isAmenitySearch {
                for amenity in selectedAmenities {
                    if !data.value.amenities.contains(amenity) {
                        valid = false
                        break
                    }
                }
            }
            
            if valid {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ParkCell") as! ParkCell
                cell.parkImage.image = data.value.images[0]
                cell.parkName.text = data.value.parkName
                cell.phoneLabel.text = data.value.phone
                allCells.append(cell)
                filterCells.append(cell)
                
                if let location = Constants.LAST_LOCATION {
                    let parkLocation = CLLocation(latitude: data.value.coords.latitude, longitude: data.value.coords.longitude)
                    let distance = location.distance(from: parkLocation)
                    let distanceVal = distance * 0.000621371 // meters to miles
                    let val = round(10 * distanceVal) / Double(10)
                    cell.distanceLabel.text = String(val) + " mi away"
                    distances[cell.parkName.text!] = distanceVal
                } else {
                    cell.distanceLabel.isHidden = true
                }
            }
        }
        
        searchBar.delegate = self
        updateResults()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if filterCells.count == 0 {
            return 52
        }
        
        return 97
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterCells.count == 0 {
            return 1
        }
        
        return filterCells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if filterCells.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "NoParksCell")!
        }
        
        return filterCells[(indexPath as NSIndexPath).row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filterCells.count == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destController = mainStoryboard.instantiateViewController(withIdentifier: "ParkController") as! ParkController
        let menuNavigation = self.navigationController as! MenuNavigation
        
        destController.parkName = filterCells[(indexPath as NSIndexPath).row].parkName.text
        
        hideSideMenuView()
        menuNavigation.pushViewController(destController, animated: true)
        Utilities.loadPark(menuNavigation)
    }
    
    @IBAction func onMenuPressed(_ sender: Any) {
        toggleSideMenuView()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateResults()
    }
    
    func updateResults() {
        let searchText = searchBar.text!
        
        if searchText.count == 0 {
            filterCells = allCells
        } else {
            filterCells = [ParkCell]()
            
            for parkCell in allCells {
                let name = parkCell.parkName.text!.lowercased() as String
                if name.range(of: searchText.trim().lowercased()) != nil {
                    filterCells.append(parkCell)
                }
            }
        }
        
        if filterCells.count > 0 && !filterCells[0].distanceLabel.isHidden {
            filterCells.sort() { (cell1, cell2) in
                let distance1 = self.distances[cell1.parkName.text!]!
                let distance2 = self.distances[cell2.parkName.text!]!
                return distance1 < distance2
            }
        }
        
        self.tableView.reloadData()
    }
    
    func setAmenities(_ selectedAmenities: [String]) {
        self.isAmenitySearch = true
        self.selectedAmenities = selectedAmenities
    }
}
