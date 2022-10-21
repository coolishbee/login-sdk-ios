//
//  ListViewController.swift
//  LoginSDKSample
//
//  Created by coolishbee on 2022/10/18.
//

import UIKit
import LoginSDK

class ListViewController: UITableViewController {
    
    let kCellIdentifier = "CellIdentifier"
    let demos = ["SetupSDK", "Google Login", "Facebook Login", "Apple Login"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Login SDK Demo"
        
        self.tableView?.register(UITableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier)! as UITableViewCell
        
        cell.textLabel?.text = demos[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            UniversalAPIClient.shared.setupSDK()
        } else if indexPath.row == 1 {
            UniversalAPIClient.shared.socialLogin(loginType: .google,
                                                  inViewController: self) { result, error in
                guard let result = result else {
                    print("Error! \(String(describing: error))")
                    return
                }
                let apiVC = APIScrollViewController()
                apiVC.label.text = result.json
                self.navigationController?.pushViewController(apiVC, animated: true)
            }
        } else if indexPath.row == 2 {
            UniversalAPIClient.shared.socialLogin(loginType: .facebook,
                                                  inViewController: self) { result, error in
                guard let result = result else {
                    print("Error! \(String(describing: error))")
                    return
                }
                let apiVC = APIScrollViewController()
                apiVC.label.text = result.json
                self.navigationController?.pushViewController(apiVC, animated: true)
            }
        } else if indexPath.row == 3 {
            UniversalAPIClient.shared.socialLogin(loginType: .apple,
                                                  inViewController: self) { result, error in
                guard let result = result else {
                    print("Error! \(String(describing: error))")
                    return
                }
                let apiVC = APIScrollViewController()
                apiVC.label.text = result.json
                self.navigationController?.pushViewController(apiVC, animated: true)
            }
        }
    }
}
