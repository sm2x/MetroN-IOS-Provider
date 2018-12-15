//
//  UploadDocumentsViewController.swift
//  Nikola Driver
//
//  Created by Sutharshan Ram on 18/08/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation
import SwiftyJSON
import Localize_Swift

class UploadDocumentsViewController: UITableViewController {
    
     var hud : MBProgressHUD = MBProgressHUD()
    var uploadList: [UploadItem] = []
    var imageArray = [String]()
    var docId: String = ""
    var picker = UIImagePickerController()
    
    @IBOutlet weak var burgerMenu: UIBarButtonItem!
    
    //@IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        
        imageArray.append("driving_lisence")
        imageArray.append("lisence_plate")
        imageArray.append("vehicle_registration")
        imageArray.append("photo_camera")
        imageArray.append("photo_camera")
        imageArray.append("photo_camera")
        imageArray.append("photo_camera")
        picker.delegate=self
        if revealViewController() != nil {
            
            burgerMenu.target = revealViewController()
            burgerMenu.action = "revealToggle:"
            
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            revealViewController().frontViewController.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        tableView.delegate = self
        getDocs()
    }
    
    func getDocs(){
        
        API.getDocs(completionHandler: { json, error in
            
            self.showLoader(str: "loading documents")
            
            if let error = error {
                //self.hideLoader()
                debugPrint("Error occuring while fetching provider.service :( | \(error.localizedDescription)")
            }else {
                if let json = json {
                    var active : Int = 0
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        
                        self.hideLoader()
                        
                        print(json ?? "error in getDocs json")
                        self.uploadList.removeAll()
                        if json["documents"].exists() {
                            let docsJson: [JSON] = json["documents"].arrayValue
                    
                                for docJsn in docsJson {
                                    let upload:UploadItem = UploadItem.init(rqObj: docJsn)
                                    self.uploadList.append(upload)
                                }
                                    print(self.uploadList.count)
                                    self.tableView.reloadData()
                                }
                    
                            }else{
                                print(json ?? "error in getDocs json")
                              print(statusMessage)
                              print(json ?? "json empty")
                         self.hideLoader()
                        if let msg : String = json[Const.ERROR].rawString() {
                            self.view.makeToast(message: msg)
                        }
                        
                               // var msg = json![Const.ERROR].rawString()!
                        
                    }

                
                }else{
                    //self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }
            }
            

        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return uploadList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:DocumentCell=tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath) as! DocumentCell
        let upload: UploadItem = uploadList[indexPath.row]
        
        cell.docName.text = upload.name
        
        var pic: String = upload.image
        
        if !((pic ?? "").isEmpty){
            pic = pic.decodeUrl()
            
            let url = URL(string: pic)!
            let placeholderImage = UIImage(named: "photo_camera")!
            
            cell.docImage?.af_setImage(
                withURL: url,
                placeholderImage: placeholderImage
            )
        }else{
        
            print("image Array \(uploadList.count)")
           
            cell.docImage.image = UIImage(named: "photo_camera")
        }
        cell.bgView.layer.cornerRadius = 3
//        cell.bgView.layer.borderColor = UIColor.lightGray.cgColor
//        cell.bgView.layer.borderWidth = 1
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let upload: UploadItem = uploadList[indexPath.row]
        docSelected(docId: upload.id)
    }
    
    func docSelected(docId: String){
        
        self.docId = docId
        
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
        
//        let pickerController = DKImagePickerController()
//
//        pickerController.singleSelect = true
//        pickerController.didSelectAssets = { (assets: [DKAsset]) in
//            print("didSelectAssets")
//            print(assets)
//            if assets.count > 0 {
//                let asset = assets[0]
//
//                //asset.fetchImageWithSize(layout.itemSize.toPixel(), completeBlock: { image, info in
////                asset.fetchImageWithSize(CGSize(width: 200.0, height:200.0), completeBlock: { image, info in
////                    //if cell.tag == tag {
////                    //self.profileImage.image = image
////                    //self.imageChanged = true
////                    //}
////                })
//
//                asset.fetchOriginalImage(true, completeBlock: { image, info in
//                    //if cell.tag == tag {
//                    //self.profileImage.image = image
//                    //self.imageChanged = true
//                    //}
//                    self.uploadDoc(docId: docId, image: image!)
//                })
//
//            }
//        }
//
//        self.present(pickerController, animated: true) {}
    }
    
    func uploadDoc(docId: String, image: UIImage){
        
        self.showLoader(str: "uploading document")
        API.uploadDocument(docId: docId, image: image, completionHandler:  { json, error in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let json = json {
                    
                    let status = json[Const.STATUS_CODE].boolValue
                    let statusMessage = json[Const.STATUS_MESSAGE].stringValue
                    if(status){
                        
                        self.hideLoader()
                        print("Full uploadDoc JSON")
                            print(json ?? "json null")
                            self.view.makeToast(message: "Document Updated")
                            print("uploadDoc  success.")
                            self.getDocs()
                        }else{
                            print(statusMessage)
                            print(json ?? "json empty")
                        
                         self.hideLoader()
                        
                        if let msg : String = json[Const.ERROR].rawString() {
                            self.view.makeToast(message: msg)
                        }
                      
                    }
                    
                    
                }else{
                    //self.hideLoader()
                    debugPrint("Invalid JSON :(")
                }

                

            }
        })
    }
}
extension UploadDocumentsViewController : MBProgressHUDDelegate {
    
    func showLoader(str: String) {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
        hud.labelText = str
    }
    
    func hideLoader() {
        hud.hide(true)
    }
    
    
}
extension UploadDocumentsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        // use the image
        self.uploadDoc(docId: docId, image: chosenImage)
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


