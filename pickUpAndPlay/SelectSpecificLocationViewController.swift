//
//  SelectSpecificLocationViewController.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 8/23/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//

import UIKit
import Firebase

class SelectSpecificLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let ref = Database.database().reference()
    var passedLocation = Location()
    var possibleLocations = [Location]()
    var selectedLocation = Location()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLocationImage()
        setupLocations()
        setupLabel()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupLabel() {
        locationName.text = passedLocation.name
        locationName.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
    }
    
    //MARK: Table View Delegate methods
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection: Int)-> Int{
        // an int that represents the number of games being held at this location
        return possibleLocations.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = possibleLocations[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedLocation = self.possibleLocations[indexPath.row]
        self.performSegue(withIdentifier: "goToScheduleController", sender: self)
    }
    
    //MARK: Table View appearance setup / rigging
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let gtvCell = cell as? GreenTableViewCell {
            gtvCell.setSizeAndColor(tableView.frame.width)
        }
    }
    
    //send location to schedule controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToScheduleController" {
            let x : scheduleViewController = segue.destination as! scheduleViewController
            x.passedLocation = self.selectedLocation
        }
    }
    
    func setupLocations(){
        for subLocation in passedLocation.subLocations! {
            let location = Location(passedLocation.locationId, subLocation.availableSports, subLocation.name, passedLocation.long, passedLocation.lat, subLocation.locationImageURL)
            possibleLocations.append(location)
        }
    }
    
    //MARK: Need to do Async
    func fetchLocationImage(){
            let url = URL(string: passedLocation.locationImageURL)
            let data = try? Data(contentsOf: url!)
            self.locationImage.image = UIImage(data : data!)
    }

}//End SelectSpecificLocationViewController
