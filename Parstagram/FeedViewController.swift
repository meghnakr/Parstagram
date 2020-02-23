//
//  FeedViewController.swift
//  Parstagram
//
//  Created by user162638 on 2/19/20.
//  Copyright © 2020 user162638. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var feedTableView: UITableView!
    
    var ref: DatabaseReference!
    //var posts = [[String: Any]]()
    //var posts: [AnyObject]
    var posts = [String : [String : Any]]()
    //var posts = DatabaseQuery()
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTableView.delegate = self
        feedTableView.dataSource = self
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
        //print("Reached here 1")
        /*self.ref.child("posts").observeSingleEvent(of: .value) { (snapshot) in
            print("Reached here 2")
            //self.posts.removeAll()
            /*guard let postArray = snapshot.value as? [String : Any] else {
                print("Reached here 3")
                return
            }*/
            var i = 0
            for child in snapshot.children
            {
                self.posts[i]["caption"] =
                self.posts[i]["image"] = child.value["image"] as? String
                self.posts[i]["username"] = child.value["username"] as? String
            }*/
            //self.posts = postArray
        loadPosts()
    }
    
    func loadPosts()
    {
        self.posts.removeAll()
        //self.posts.removeAllObservers()
        //self.posts = (ref?.child("posts").queryLimited(toFirst: 20))!
        self.ref.child("posts").observeSingleEvent(of: .value) { (snapshot) in
            let temp = snapshot.value
            if(temp is NSNull)
            {
                return
            }
            self.posts = temp as! [String : [String : Any]]
        print(self.posts)
        self.feedTableView.reloadData()
        }
        /*let db = ref.child("posts")
        let query = db.queryLimited(toFirst: 20)
        query.observe(.value, with: { (snapshot: DataSnapshot) in
            //self.posts = snapshot.value as! [[String : Any]]
            //let dictionary = snapshot.value as! NSDictionary
            //self.posts = dictionary as! [AnyObject]
            /*var i = 0
                for snap in snapshot.children {
                self.posts[i] = snap as AnyObject
                i = i + 1
            }*/
            self.posts = snapshot.value as! [String : [String : Any]]*/
        //})
        self.feedTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadPosts()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("posts count = \(posts.count)")
        var i = 0
        for post in posts
        {
            i = i + 1
        }
        print(i)
        return i
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feedTableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        /*let post = posts[indexPath.row]
        let randomID = post["imageID"] as! String
        let storageRef = Storage.storage().reference(withPath: "images/\(randomID).jpg")
        storageRef.getData(maxSize: 10 * 1024 * 1024) { [weak self] (data, error) in
            if let error = error {
                print("Error\(error.localizedDescription)")
                return
            }
            if let data = data {
                cell.photoView.image = UIImage(data: data)
            }
        }
        cell.usernameLabel.text = post["username"] as! String
        cell.captionLabel.text = post["caption"] as! String*/
        var i = 0
        for post in posts
        {
            if(i == indexPath.row)
            {
                print("Reached here 1")
                /*let imageURL = URL(string: (post.value["image"] as? String)!)
                print(imageURL)
                let data = try? Data(contentsOf: imageURL!)
                if let imageData = data {
                    print("Reached here 2")
                    cell.photoView.image = UIImage(data: imageData)
                } else
                {
                    print("Reached here 3")
                }*/
                let randomID = post.value["imageID"] as! String
                let storageRef = Storage.storage().reference(withPath: "images/\(randomID).jpg")
                storageRef.getData(maxSize: 10 * 1024 * 1024) { [weak self] (data, error) in
                    if let error = error {
                        print("Error\(error.localizedDescription)")
                        return
                    }
                    if let data = data {
                        cell.photoView.image = UIImage(data: data)
                    }
                }
                cell.usernameLabel.text = post.value["username"] as! String
                cell.captionLabel.text = post.value["caption"] as! String
                break
            }
            else
            {
                i = i + 1
            }
        }
        //let imageURL = URL(string: (post["image"] as? String)!)
        //let data = try? Data(contentsOf: imageURL!)
        /*if let imageData = data {
            cell.photoView.image = UIImage(data: imageData)
        }*/
        //cell.usernameLabel.text = post["username"] as! String
        //cell.captionLabel.text = post["caption"] as! String
        return cell
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
