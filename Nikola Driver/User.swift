//
//  User.swift
//  CornerSwap
//
//  Created by Prithiviraj U on 13/01/17.
//  Copyright © 2017 CornerSwap. All rights reserved.
//

import Foundation


class User: NSObject{
    
    var id: String!
    
    var email: String!
    
    var token: String!
    
    var name: String!
    var phone: String!
    
    var is_user: Bool = false
    
    var is_seller: Bool = false
    
    var img_url: String!
    
    
    init(id: String, name: String, email: String, token: String, phone: String){
        
        self.id = id
        self.email = email
        self.name = name
        self.token = token
        self.phone = phone
        print(self.id)
        print(self.email)
        print(self.name)
        print(self.token)
    }
    
    
    func setSellerRole(){
        self.is_seller = true
    }
    
    
    func setUserRole(){
        
        self.is_user = true
    }
    
}
