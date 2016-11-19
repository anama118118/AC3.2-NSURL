//
//  InstaCatTableViewController.swift
//  AC3.2-InstaCats-1
//
//  Created by Louis Tur on 10/10/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

struct InstaCat {
  // add necessary ivars and initilizations; check the tests to know what you should have
    let name: String
    let id: Int
    let instagramURL: URL
    var description: String? { //Computed Property
        return "Nice to me you, I'm \(name)"
    }
}

class InstaCatTableViewController: UITableViewController {

    internal let InstaCatTableViewCellIdentifier: String = "InstaCatCellIdentifier"
    internal let instaCatJSONFileName: String = "InstaCats.json"
    internal var instaCats: [InstaCat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let instaCatsURL: URL = self.getResourceURL(from: instaCatJSONFileName),
            let instaCatData: Data = self.getData(from: instaCatsURL),
            let instaCatsAll: [InstaCat] = self.getInstaCats(from: instaCatData) else {
                return
        }
        self.instaCats = instaCatsAll
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instaCats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InstaCatTableViewCellIdentifier, for: indexPath)
        cell.textLabel?.text = instaCats[indexPath.row].name
        cell.detailTextLabel?.text = String(instaCats[indexPath.row].id)
        return cell
    }

    //MARK: - Data
    //Get URL
    internal func getResourceURL(from fileName: String) -> URL? {
        // 1. There are many ways of doing this parsing, we're going to practice String traversal
        guard let dotRange = fileName.rangeOfCharacter(from: CharacterSet.init(charactersIn: ".")) else {
            return nil
        }
        
        // 2. The upperbound of a range represents the position following the last position in the range, thus we can use it
        // to effectively "skip" the "." for the extension range
        let fileNameComponent: String = fileName.substring(to: dotRange.lowerBound)
        let fileExtenstionComponent: String = fileName.substring(from: dotRange.upperBound)
        
        // 3. Here is where Bundle.main comes into play
        let fileURL: URL? = Bundle.main.url(forResource: fileNameComponent, withExtension: fileExtenstionComponent)
        
        return fileURL
    }
    
    internal func getData(from url: URL) -> Data? {
        
        // 1. this is a simple handling of a function that can throw. In this case, the code makes for a very short function
        // but it can be much larger if we change how we want to handle errors.
        // try is a key word
        let fileData: Data? = try? Data(contentsOf: url)
        return fileData
    }
    
    internal func getInstaCats(from jsonData: Data) -> [InstaCat]? {
        // 1. This time around we'll add a do-catch
        var cats = [InstaCat]()
        do {
            let instaCatJSONData: Any = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            // 2. Cast from Any into a more suitable data structure and check for the "cats" key
            if let dict = instaCatJSONData as? [String: [[String:String]]]{
                if let catArray = dict["cats"]{
                    for catDict in catArray {
                        if let catID = catDict["cat_id"],
                        let catIDInt = Int(catID),
                        let catName = catDict["name"],
                        let catInstagram = catDict["instagram"],
                        let catInstagramURL = URL(string: catInstagram){
                            cats.append(InstaCat(name: catName, id: catIDInt, instagramURL: catInstagramURL))
                        //instaCats.append(contentsOf: (InstaCat(name: catName, id: catIDInt , instagramURL: catInstagramURL, description: nil))
                        }
                    }
                }
            }
            /*
            if let data = instaCatJSONData as? [String: Any] {
                if let instagramCats = data["cats"] as? [[String:Any]] {
                    for cat in instagramCats {
                        if let name = cat["name"] as? String,
                            let idString = cat["cat_id"] as? String,
                            let instagramURLString = cat["instagram"] as? String {
                            
                            guard let id = Int(idString), let instagramURL = URL(string: instagramURLString) else {return nil}
             
                            cats.append(InstaCat(name: name, id: id, instagramURL: instagramURL))
                        }
                    }
                }
             }
            */
            
            // 3. Check for keys "name", "cat_id", "instagram", making sure to cast values as needed along the way
            
            // 4. Return something
            
        }
        catch let error as NSError {
            // JSONSerialization doc specficially says an NSError is returned if JSONSerialization.jsonObject(with:options:) fails
            print("Error occurred while parsing data: \(error.localizedDescription)")
        }
        
        return cats
        //return instaCats
    }
    //MARK: - Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.shared.open(instaCats[indexPath.row].instagramURL)
    }
}
