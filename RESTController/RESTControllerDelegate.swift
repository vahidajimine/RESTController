//
//  RESTController/RESTControllerDelegate.swift
//
//  Created by Vahid Ajimine on 2/9/16.
//  Copyright © 2018 Vahid Ajimine. All rights reserved.

import Foundation
//MARK: RESTControllerDelegate
/**
 *  The delegate methods to make sure that a class properly defines these set functions
 */
public protocol RESTControllerDelegate: class {
    /**
     The REST call was successful and returned a valid JSON result and was able to convert it to a `[key:value]` pair dictionary.
     
     - parameter results: the JSON data in a dictionary format
     - parameter url:     the server url in a string format
     */
    func didReceiveAPIResults(results: [String: AnyObject], url: String)
    
    /**
     The REST call was unsuccessful. This is defaulted to do nothing, but you may want to add addtional functionality later
     
     - parameter error: the error string
     - parameter url:   the server url
     */
    func didNotReceiveAPIResults(error: String, url: String)
}
