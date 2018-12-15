//
//  RideHistoryViewController.swift
//  Nikola
//
//  Created by Sutharshan Ram on 15/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON
import AlamofireImage
import Toucan

class RideHistoryViewController : UITableViewController{
    
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    var hud : MBProgressHUD = MBProgressHUD()
    let reuseIdentifier: String = "RideHistoryCell"
    var rides:[RideHistoryItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            
            burgerMenu.target = revealViewController()
            burgerMenu.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        revealViewController().frontViewController.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        fetchRideHistory()
    }
    
    func fetchRideHistory(){
        self.showLoader(str: "Loading...")
        API.fetchRideHistory{ json, error in
            
            if json == nil {
                print("json nil")
                self.hideLoader()
                print(error?.localizedDescription)
                return
            }
            
            let status = json![Const.STATUS_CODE].boolValue
            let statusMessage = json![Const.STATUS_MESSAGE].stringValue
            if(status){
                self.hideLoader()
                DATA().putRideHistoryData(request: json!["requests"].rawString()!)
                let typesArray = json!["requests"].arrayValue
                self.rides.removeAll()
                for type: JSON in typesArray {
                    self.rides.append(RideHistoryItem.init(jsonObj: type))
                }
                print(json ?? "error in fetchRideHistory json")
                
                self.tableView.reloadData()
                
            }else{
                print(statusMessage)
                self.hideLoader()
                print(json ?? "json empty")
                var msg = json![Const.ERROR].rawString()!
                self.view.makeToast(message: msg)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if rides.count == 0 {
            let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
            noDataLabel.text = "No Rides History Available".localized()
            noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            noDataLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = noDataLabel
        }else {
            self.tableView.backgroundView = nil
        }
        
        return rides.count
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:RideHistoryCell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! RideHistoryCell
        
        let ride : RideHistoryItem = rides[indexPath.row]
        
        cell.ridetime?.text = "\(ride.date)"
        cell.pickUpAddress?.text = "\(ride.s_address)"
        cell.dropAddress?.text = "\(ride.d_address)"
        cell.drivername?.text = "\(ride.user_name)"
        cell.type?.text = "\(ride.taxi_name)"
        cell.amount?.text = "$ \(ride.total)"
        
        if !((ride.picture ?? "").isEmpty)
        {
            let url = URL(string: ride.picture.decodeUrl())!
            let placeholderImage = UIImage(named: "taxi")!
            let size = CGSize(width: 100.0, height: 100.0)
            let filter = AspectScaledToFillSizeCircleFilter(size: size)
            cell.driverImage?.af_setImage(
                withURL: url,
                placeholderImage: placeholderImage,
                filter: filter)
        }else{
            cell.driverImage.image = Toucan(image: UIImage(named: "taxi")!).maskWithEllipse().image
        }
        cell.bgView.layer.cornerRadius = 10

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
//        let row = indexPath.row
//        print(countryArray[row])
//        selectedIndex = indexPath
//        self.setDefaultCard(card: cards[row])
//        tableView.reloadData()
        
        let ride : RideHistoryItem = rides[indexPath.row]
        DATA().putRideHistorySelectedData(request: ride.jsnObj.rawString()!)
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "RideDetailsViewController") as! RideDetailsViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)

    }
    
    
}
extension RideHistoryViewController : MBProgressHUDDelegate {
    
    func showLoader(str: String) {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
        hud.labelText = str
    }
    
    func hideLoader() {
        hud.hide(true)
}
}

