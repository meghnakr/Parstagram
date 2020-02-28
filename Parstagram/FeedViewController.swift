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
import FirebaseAuth

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var feedTableView: UITableView!
    
    var ref: DatabaseReference!
    //var posts = [[String: Any]]()
    //var posts: [AnyObject]
    var posts = [String : [String : Any]]()
    //var posts = DatabaseQuery()
    var postArray = [postStructure]()
    
    struct postStructure {
        var imageID = ""
        var caption = ""
        var username = ""
        var date = 0
        var month = 0
        var year = 0
        var hour = 0
        var minute = 0
    }
    
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
        self.postArray.removeAll()
        postArray = []
        //self.posts.removeAllObservers()
        //self.posts = (ref?.child("posts").queryLimited(toFirst: 20))!
        self.ref.child("posts").observeSingleEvent(of: .value) { (snapshot) in
            
            self.posts.removeAll()
            self.postArray.removeAll()
            self.postArray = []
            let temp = snapshot.value
            if(temp is NSNull)
            {
                return
            }
            self.posts = temp as! [String : [String : Any]]
            print(self.posts)
            self.feedTableView.reloadData()
        
            print("Array: \(self.postArray)")
            var i = 0
            for post in self.posts
            {
                var postStruct = postStructure()
                postStruct.imageID = post.value["imageID"] as! String
                postStruct.caption = post.value["caption"] as! String
                postStruct.username = post.value["username"] as! String
                postStruct.date = post.value["day"] as! Int
                postStruct.month = post.value["month"] as! Int
                postStruct.year = post.value["year"] as! Int
                postStruct.hour = post.value["hour"] as! Int
                postStruct.minute = post.value["minutes"] as! Int
                /*self.postArray[i].imageID = post.value["imageID"] as! String
                self.postArray[i].caption = post.value["caption"] as! String
                self.postArray[i].username = post.value["username"] as! String
                self.postArray[i].date = post.value["date"] as! Int
                self.postArray[i].month = post.value["month"] as! Int
                self.postArray[i].year = post.value["year"] as! Int
                self.postArray[i].hour = post.value["hour"] as! Int
                self.postArray[i].minute = post.value["minutes"] as! Int*/
                self.postArray.append(postStruct)
                i = i + 1
            }
            print("Unsorted Array: \(self.postArray)")
            self.sortPosts()
            print("Sorted Array: \(self.postArray)")
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
        
        //var urlRef = Firebase(url: "https://parstagram-2c5fd.firebaseio.com/")
        
        //self.feedTableView.reloadData()
    }
    
    func sortPosts()
    {
        print("sort: count  = \(postArray.count)")
        var i = 0
        while i < postArray.count
        {
            print("i = \(i)")
            var max = i
            var j = i+1
            while j < postArray.count
            {
                let post = postArray[j]
                let postMax = postArray[max]
                if(post.year > postMax.year)
                {
                    max = j
                } else if(post.year == postMax.year) {
                    if(post.month > postMax.month)
                    {
                        max = j
                    } else if(post.month == postMax.month) {
                        if(post.date > postMax.date)
                        {
                            max = j
                        }
                        else if(post.date == postMax.date) {
                            if(post.hour > postMax.hour) {
                                max = j
                            } else if(post.hour == postMax.hour) {
                                if(post.minute > postMax.minute) {
                                    max = j
                                }
                            }
                        }
                    }
                }
                j = j + 1
            }
            let temp = postArray[i]
            postArray[i] = postArray[max]
            postArray[max] = temp
            i = i + 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadPosts()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("posts count = \(posts.count)")
        /*var i = 0
        for post in posts
        {
            i = i + 1
        }
        print(i)
        return i*/
        print("count = \(postArray.count)")
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feedTableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        print("row no. \(indexPath.row)")
        
        let randomID = postArray[indexPath.row].imageID
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
        cell.usernameLabel.text = postArray[indexPath.row].username
        cell.captionLabel.text = postArray[indexPath.row].caption
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
        /*var i = 0
        for post in posts
        {
            if(i == indexPath.row)
            {
                //print("Reached here 1")
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
        }*/
        //let imageURL = URL(string: (post["image"] as? String)!)
        //let data = try? Data(contentsOf: imageURL!)
        /*if let imageData = data {
            cell.photoView.image = UIImage(data: imageData)
        }*/
        //cell.usernameLabel.text = post["username"] as! String
        //cell.captionLabel.text = post["caption"] as! String
        return cell
    }
    
    @IBAction func onLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        let delegate = SceneDelegate()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        delegate.window?.rootViewController = loginViewController
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
