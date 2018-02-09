//
//  RESTController/RESTControllerProtocolExtensionDefault.swift
//
//  Created by Vahid Ajimine on 2/9/16.
//  Copyright © 2018 Vahid Ajimine. All rights reserved.

import Foundation
//MARK: Default Method
extension RESTControllerProtocol {
    /**
     The REST call was unsuccessful. This is defaulted to do nothing, but you may want to add addtional functionality later
     
     - parameter error: the error string
     - parameter url:   the server url
     */
    func didNotReceiveAPIResults(error: String, url: String) {
        //purposely left empty
    }
}