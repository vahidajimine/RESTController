//
//  RESTController/ContentType.swift
//
//  Created by Vahid Ajimine on 2/9/16.
//  Copyright © 2018 Vahid Ajimine. All rights reserved.

import Foundation
//MARK: ContentType
/// The HTTP header field for the various MIME types of the body of the request (used with `POST` and `PUT` requests)
public enum ContentType: String {
    
    case json = "application/json"
    case urlEncode = "application/x-www-form-urlencoded"
    case multipartForm = "multipart/form-data"
    case textHTML = "text/html"
    
    static public let headerFieldValue = "Content-Type"
}
