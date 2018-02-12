//
//  RESTController/HTTPMethod.swift
//
//  Created by Vahid Ajimine on 2/9/16.
//  Copyright © 2018 Vahid Ajimine. All rights reserved.

import Foundation

//MARK: ENUMS - HTTPMethod
/**
 All the various HTTP call requests
 
 - post: makes a post call
 - get:  makes a get call
 */
public enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
}
