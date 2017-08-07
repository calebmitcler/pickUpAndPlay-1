//
//  userHomePageViewController.swift
//  pickUpAndPlay
//
//  Created by Caleb Mitcler on 6/1/17.
//  Copyright © 2017 Caleb Mitcler. All rights reserved.
//
//TODO: Allow user to edit profile
//TODO: Allow logout

import UIKit
import FirebaseAuth
import Firebase

class userHomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var ref: DatabaseReference! = Database.database().reference()
    var gameList: [Game] = []
    var selectedGameId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupButtons()
        getUserInfo()
        fetchGames()
    }
    
    func setupButtons() {
        profilePic.layer.cornerRadius = profilePic.frame.height/2
        backgroundImage.clipsToBounds = true
    }
    
    //MARK: Table View Delegate methods
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection: Int)-> Int{
        // an int that represents the number of games being held at this location
        return gameList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableViewCell", for: indexPath) as? GameTableViewCell
        
        let game = gameList[indexPath.row]
        
        //set the cell's labels to their corresponding values for each game in the gameList array
        cell?.timeLabel.text = game.time
        cell?.dateLabel.text = game.date
        cell?.spotsRemainingLabel.text = String(game.spotsRemaining)
        
        //Check to see what sport the game is and set the cell's image appropriately
        if game.sport == "soccer" {
            cell?.sportImage.image = UIImage(named: "soccerBall")
        } else if game.sport == "basketball" {
            cell?.sportImage.image = UIImage(named: "basketball")
        } else if game.sport == "volleyball" {
            cell?.sportImage.image = UIImage(named: "volleyball")
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedGameId = self.gameList[indexPath.row].gameId
        self.performSegue(withIdentifier: "goToEventDetails", sender: self)
    }
    
    //MARK: Table View appearance setup / rigging
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        
        let myGreen = UIColor(displayP3Red:46.0/255.0, green:204.0/255.0, blue:114.0/255.0, alpha:1.0)
        
        let greenRoundedView: UIView = UIView(frame: CGRect(x:0,y:5,width:tableView.frame.width, height:80))
        greenRoundedView.layer.backgroundColor = myGreen.cgColor
        greenRoundedView.layer.masksToBounds = false
        greenRoundedView.layer.cornerRadius = 10.0
        greenRoundedView.layer.shadowOffset = CGSize(width:-1,height: 0)
        greenRoundedView.layer.shadowOpacity = 0.2
        
        
        cell.contentView.addSubview(greenRoundedView)
        cell.contentView.sendSubview(toBack: greenRoundedView)
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "logOut", sender: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEventDetails" {
            let x : eventDetailsViewController = segue.destination as! eventDetailsViewController
            x.gameId = self.selectedGameId
        }
    }
    
    //MARK: Firebase functions
    func getUserInfo () {
        
        //Get the user's first and last name from Firebase
        let userID = Auth.auth().currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let firstName = value?["firstName"] as? String ?? "Didn't work"
            let lastName = value?["lastName"] as? String ?? "Didn't work"
            self.nameLabel.text = firstName + " " + lastName
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }//End getUserInfo
    
    func fetchGames() {
        let ref = Database.database().reference()
        _ = ref.child("events").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let playerArray = dictionary["playerList"]!
                if playerArray.contains(Auth.auth().currentUser?.uid as Any) {
                    
                    let gameId = snapshot.key
                    //Format the date stored in the database
                    let df = DateFormatter()
                    
                    df.dateFormat = "MMM d, yyyy, h:mm a"
                    let dateAsDate = df.date(from: dictionary["time"] as! String)
                    df.dateFormat = "MMMM d"
                    let justDate = df.string(from: dateAsDate!)
                    df.dateFormat = "h:mm a"
                    let timeString = df.string(from: dateAsDate!)
                    
                    
                    //Set values of game variable from database information
                    let sport = dictionary["sport"]
                    let time = timeString
                    let date = justDate
                    let spotsRemaining = dictionary["playerLimit"] //- dictionary["playerList"].count
                    
                    
                    
                    let game = Game(gameId, sport as! String, time , date, dateAsDate!, spotsRemaining as! Int)
                    self.gameList.append(game)
                    self.tableView.reloadData()
                } //End if location
                //Sort games by date
                self.gameList.sort(by: {$0.dateTime.compare($1.dateTime) == .orderedAscending })
            } //End if let dictionary
        }) //End observe snapshot
    } //End fetchGames
}//End class
