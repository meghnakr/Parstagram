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
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    @IBOutlet weak var feedTableView: UITableView!
    
    var ref: DatabaseReference!
    //var posts = [[String: Any]]()
    //var posts: [AnyObject]
    var posts = [String : [String : Any]]()
    //var posts = DatabaseQuery()
    var postArray = [postStructure]()
    
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var selectedPost = postStructure()
    
    struct postStructure {
        var postID = ""
        var imageID = ""
        var caption = ""
        var username = ""
        var date = 0
        var month = 0
        var year = 0
        var hour = 0
        var minute = 0
        //var comments = [String : [String : Any]]()
        var comments = [commentStructure]()
    }
    
    struct commentStructure {
        var number = ""
        var username = ""
        var text = ""
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
        feedTableView.keyboardDismissMode = .interactive
        ref = Database.database().reference()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
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
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil 
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create comment
        let commentNo = self.ref.child("posts/\(selectedPost.postID)/comments").childByAutoId().key
        let user = Auth.auth().currentUser
        self.ref.child("Users").child(user!.uid).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String
            //currentDictionary["\(commentNo)"]  = ["text": comment, "username": username!]
            let commentDictionary = ["text": text, "username": username!, "commentNum": commentNo!] as [String : Any]
            //currentDictionary.append(["text": comment, "username": username!])
            //self.ref.child("posts/\(postElement.postID)").child("comments").updateChildValues(["\(commentNo)": currentDictionary])
            let commentUpdates = ["posts/\(self.selectedPost.postID)/comments/\(commentNo!)": commentDictionary]
            self.ref.updateChildValues(commentUpdates)
            self.loadPosts()
        }
        //Dismiss and hide keyboard and textfield
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
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
                postStruct.postID = post.value["postID"] as! String
                postStruct.imageID = post.value["imageID"] as! String
                postStruct.caption = post.value["caption"] as! String
                postStruct.username = post.value["username"] as! String
                postStruct.date = post.value["day"] as! Int
                postStruct.month = post.value["month"] as! Int
                postStruct.year = post.value["year"] as! Int
                postStruct.hour = post.value["hour"] as! Int
                postStruct.minute = post.value["minutes"] as! Int
                //postStruct.comments = post.value["comments"] as? [String: [String : Any]] ?? [String : [String : Any]]()
                print("Comments: \(String(describing: post.value["comments"]))")
                let commentDictionary = post.value["comments"] as? [String : [String : Any]] ?? [:]
                for comment in commentDictionary
                {
                    var commentStruct = commentStructure()
                    commentStruct.number = comment.value["commentNum"] as! String
                    commentStruct.username = comment.value["username"] as! String
                    commentStruct.text = comment.value["text"] as! String
                    postStruct.comments.append(commentStruct)
                }
                //postStruct.comments = post.value["comments"] as? NSArray ?? []
                print("Comment Array: \(postStruct.comments)")
                print("Comment Count: \(postStruct.comments.count)")
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
            var eachPost = postStructure()
            for post in self.postArray {
                eachPost = post
                eachPost.comments = self.sortComments(commentArray: eachPost.comments)
            }
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
    
    func sortComments(commentArray : [commentStructure]) -> [commentStructure]
    {
        var commentArray2 = commentArray
        print("sort: count  = \(commentArray.count)")
        var i = 0
        while i < commentArray2.count
        {
            print("i = \(i)")
            var max = i
            var j = i+1
            while j < commentArray2.count
            {
                let comment = commentArray2[j]
                let commentMax = commentArray2[max]
                if(comment.year > commentMax.year)
                {
                    max = j
                } else if(comment.year == commentMax.year) {
                    if(comment.month > commentMax.month)
                    {
                        max = j
                    } else if(comment.month == commentMax.month) {
                        if(comment.date > commentMax.date)
                        {
                            max = j
                        }
                        else if(comment.date == commentMax.date) {
                            if(comment.hour > commentMax.hour) {
                                max = j
                            } else if(comment.hour == commentMax.hour) {
                                if(comment.minute > commentMax.minute) {
                                    max = j
                                }
                            }
                        }
                    }
                }
                j = j + 1
            }
            let temp = commentArray2[i]
            commentArray2[i] = commentArray2[max]
            commentArray2[max] = temp
            i = i + 1
        }
        return commentArray2
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
        //print("count = \(postArray.count)")
        
        print("post no. \(section)")
        let post = postArray[section];
        print("Post: \(post)")
        let comments = (post.comments as NSArray) ?? []
        print("\(comments)")
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("number of sections: \(postArray.count)")
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = postArray[indexPath.section]
        let comments = (post.comments as NSArray) ?? []
        
        if(indexPath.row == 0)
        {
            let cell = feedTableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            print("row no. \(indexPath.row)")
        
            let randomID = post.imageID
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
            cell.usernameLabel.text = post.username
            cell.captionLabel.text = post.caption
            return cell
        }
        else if (indexPath.row > comments.count)
        {
            let cell = feedTableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
        else
        {
            let cell = feedTableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1] as! commentStructure
            cell.usernameLabel.text = comment.username
            cell.commentLabel.text = comment.text
            print("row no.\(indexPath.row)")
            return cell
        }
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("was selected")
        let postElement = postArray[indexPath.section]
        if(indexPath.row > postElement.comments.count) {
            selectedPost = postElement
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
        }
        //let currentDictionary = postElement.comments
        //let selectedImageID = postElement.imageID
    }
    
    @IBAction func onLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
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
