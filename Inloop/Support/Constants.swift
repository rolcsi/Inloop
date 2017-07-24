//
//  Constants.swift
//  Inloop
//
//  Created by Roland Beke on 21.7.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

import UIKit

enum Constants {

    private static let api = "https://inloop-contacts.appspot.com/_ah/api/"
    
    static let ordersUrl = api + "contactendpoint/v1/contact"
    static let detailUrl = api + "orderendpoint/v1/order/"
    static let addUrl = api + "contactendpoint/v1/contact"
    
    static let mailDomain = "@somewhere.com"
}
