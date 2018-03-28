//
//  ViewController.swift
//  DB
//
//  Created by Shivang Pandey on 27/03/18.
//  Copyright © 2018 Shivang Pandey. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController {
    @IBOutlet weak var tableview: UITableView!
    var appDelegate:AppDelegate?
    var dbcontext:NSManagedObjectContext?
    var newUser:NSManagedObject?
    var entity:NSEntityDescription?
    var arr:[PersonData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
         dbcontext = appDelegate?.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: "Person", in: dbcontext!)
        newUser = NSManagedObject(entity: entity!, insertInto: dbcontext)
        fetchData()
        self.tableview.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func fetchData() {
        arr.removeAll()
       let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        request.returnsObjectsAsFaults = false
        do {
            let result:[NSManagedObject] = try dbcontext?.fetch(request) as! [NSManagedObject]
            if result.count != 0 {
                for data in result {
                    let name = data.value(forKey: "name") as? String
                    let email = data.value(forKey: "email") as? String
                    let mobile = data.value(forKey: "phone") as? String
                    let person = PersonData(name: name, email: email, mobile: mobile)
                    self.arr.append(person)
                }
            }
            
        } catch  {
            print("faild",error.localizedDescription)
        }
    }

    @IBAction func addPerson(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Detail", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            (textfiled) in
            textfiled.placeholder = "Enter Name"
            textfiled.keyboardType = .namePhonePad
        })
        alert.addTextField(configurationHandler: {
            (textfiled) in
            textfiled.placeholder = "Enter mobile no."
            textfiled.keyboardType = .phonePad
        })
        alert.addTextField(configurationHandler: {
            (textfiled) in
            textfiled.placeholder = "Enter Email"
            textfiled.keyboardType = .emailAddress
        })
        let save = UIAlertAction(title: "Save", style: .destructive, handler: {
            _ in
            let name = alert.textFields?[0].text
            let mobile = alert.textFields?[1].text
            let email = alert.textFields?[2].text
            self.newUser?.setValue(name, forKey: "name")
            self.newUser?.setValue(email, forKey: "email")
            self.newUser?.setValue(mobile, forKey: "phone")
            do{
                try self.dbcontext?.save()
                self.fetchData()
                self.tableview.reloadData()
            }catch{
               print("faild saving",error.localizedDescription)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(save)
        self.present(alert, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
        let person = arr[indexPath.row]
        cell.name.text = person.name ?? ""
        cell.email.text = person.email ?? ""
        cell.mobile.text = person.mobile ?? ""
        return cell
    }
    
    
}
class Cell:UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var mobile: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(true, animated: true)
    }
}
class PersonData {
    var name:String?
    var email:String?
    var mobile:String?
    init(name:String?,email:String?,mobile:String?) {
        self.name = name
        self.email = email
        self.mobile = mobile
    }
}
