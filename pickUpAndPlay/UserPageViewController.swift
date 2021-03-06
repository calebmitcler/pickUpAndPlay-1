//
//  UserPageViewController.swift
//  pickUpAndPlay
//
//  Created by Caleb Mitcler on 6/1/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import AlamofireImage
import Alamofire

class UserPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var tableSpinner: UIActivityIndicatorView!
    @IBOutlet weak var userSpinner: UIActivityIndicatorView!
    
    var ref = Database.database().reference()
    var gameList: [Game] = []
    var selectedGame = Game()
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupButtons()
        getUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchGames()
    }


    
    //MARK: Table View Delegate methods
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection: Int)-> Int{
        return gameList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableViewCell", for: indexPath) as? GameTableViewCell
        
        let game = gameList[indexPath.row]
        
        //Sets all of the cell's outlets to the properties stored in game
        cell?.setGame(game)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedGame = self.gameList[indexPath.row]
        self.performSegue(withIdentifier: "goToEventDetails", sender: self)
    }
    
    //MARK: Table View appearance setup / rigging
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let gtvCell = cell as? GameTableViewCell {
            gtvCell.setSizeAndColor(tableView.frame.width)
        }
    }
    
    func getUserInfo () {
        //Get the user's first and last name from Firebase
        userSpinner.startAnimating()
        ref.child("users").child(self.userId).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let firstName = value?["firstName"] as? String ?? " "
            let lastName = value?["lastName"] as? String ?? " "
            self.nameLabel.text = firstName + " " + lastName
            self.gameLabel.text = "\(firstName)'s Games"
            
            let profilePicURL = value?["photo"] as? String? ?? ""
            
            if profilePicURL != "", profilePicURL != nil {
                Alamofire.request(profilePicURL!).responseData { (response) in
                    if response.error == nil {
                        print(response.result)
                        // Show the downloaded image:
                        if let data = response.data {
                            self.profilePic.image = UIImage(data:data)
                        }
                    }
                }
                self.userSpinner.stopAnimating()
                
            } else {
                self.profilePic.image = UIImage(named: "defaultProfilePic")
                print("No profile pic URL")
            }

            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }//End getUserInfo
    
    func fetchGames() {
        gameList = [Game]()
        tableView.reloadData()
        tableSpinner.startAnimating()
        let currentDate = Date().timeIntervalSince1970
        ref.child("userEvents/\(userId)").queryOrdered(byChild: "time").queryStarting(atValue: currentDate).observe(.value, with: {(snapshot) in

            if let gameDictionary = snapshot.value as? [String : AnyObject] {
                for (gameId, game) in gameDictionary{
                    
                    //Format the date stored in the database
                    let df = DateFormatter()
                    let dateAsDate = Date(timeIntervalSince1970: game["time"] as! Double)
                    df.dateFormat = "EEE, MMM d"
                    let justDate = df.string(from: dateAsDate)
                    df.dateFormat = "h:mm a"
                    let timeString = df.string(from: dateAsDate)
                    
                    //Set values of game variable from database information
                    let sport = game["sport"]
                    let time = timeString
                    let date = justDate
                    self.ref.child("eventUsers").child("\(gameId)").observeSingleEvent(of: .value, with: {(snapshot) in
                        let eventUserDict = snapshot.value as? NSDictionary
                        let playersInGame = eventUserDict?.allKeys.count
                        let spotsRemaining = game["playerLimit"] as! Int - playersInGame!
                        
                        let locationDict = game["location"] as! [String: [String:Any]]
                        
                        for(key, value) in locationDict {
                            let location = Location(key, value["availableSports"] as! [String], value["locationName"] as! String, value["longitude"] as! CLLocationDegrees, value["latitude"] as! CLLocationDegrees, value["image"] as! String)
                            let game = Game(gameId, sport as! String, time , date, dateAsDate, spotsRemaining, game["playerLimit"] as! Int, location)
                            self.gameList.append(game)
                            self.tableView.reloadData()
                        }//End for
                    })
                }
            } //End if let dictionary
            self.tableSpinner.stopAnimating()
        }) //End observe snapshot
    } //End fetchGames
    
    private func setupButtons() {
        profilePic.layer.cornerRadius = profilePic.frame.height/2
        backgroundImage.clipsToBounds = true
    }
    
    @IBAction func unwindtoUserPage(unwindSegue: UIStoryboardSegue){}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let x : eventDetailsViewController = segue.destination as! eventDetailsViewController
        x.game = self.selectedGame
        x.cameFrom = "userPage"
    }
}//End class
