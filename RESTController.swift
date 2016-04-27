//
//  RESTController.swift
//  DMTables
//
//  Created by Vahid Ajimine on 3/31/16.
//  Copyright © 2016 Vahid Ajimine. All rights reserved.

import Foundation
//MARK: RESTControllerProtocol
/**
 *  The protocol to make sure that a class properly defines these set functions
 */
protocol RESTControllerProtocol {
    /**
     The REST call was successful and returned a valid JSON result and was able to convert it to a `[key:value]` pair dictionary.
     
     - parameter results: the JSON data in a dictionary format
     - parameter url:     the server url in a string format
     */
    func didReceiveAPIResults(results: [String: AnyObject]!, url: String)
    
    /**
     The REST call was unsuccessful. This is defaulted to do nothing, but you may want to add addtional functionality later
     
     - parameter error: the error string
     - parameter url:   the server url
     */
    func didNotReceiveAPIResults(error: String, url: String)
}
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

//MARK: - ENUMS
//MARK: HTTPMethod
/**
 All the various HTTP call requests
 
 - post: makes a post call
 - get:  makes a get call
 */
enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
}
//MARK: ContentType
/// The HTTP header field for the various MIME types of the body of the request (used with `POST` and `PUT` requests)
enum ContentType: String {
    
    case json = "application/json"
    case urlEncode = "application/x-www-form-urlencoded"
    case multipartForm = "multipart/form-data"
    case textHTML = "text/html"
    
    static let headerFieldValue = "Content-Type"
}

//MARK: -
/** 
 The class that makes JSON RESTful calls to a server
 
 NOTE: Only POST calls are supported at this time.
*/
class RESTController {
    
    /// The delegate functions for this class
    var delegate: RESTControllerProtocol
    
    /**
     Initializes this class
     
     - parameter delegate: the delegate protocol definitions. Usually set to self
     
     - returns: creates a REST call object
     */
    init(delegate: RESTControllerProtocol) {
        self.delegate = delegate
    }
    
    /**
     Make a REST call to a server. method, contentType and isSuccess are optional parameters
     
     Note: this function only currently works for the Content-Type `application/json`. Additional content types will
     
     - parameter params: A dictionary of `key:value` parameters to be passed in the url rest call
     - parameter url:    the string of the url for the server
     - parameter method: either `POST` or `GET`. Default is POST
     - parameter contentType: only supports json and urlEncode currently. Default value is .json
     - parameter isSuccess: a string that is the key of the (key:value) in the JSON data result. It is usually "success"
     */
    func restCall(params : [String: String], url : String, method: HTTPMethod = HTTPMethod.post, contentType: ContentType = ContentType.json, isSuccess: String? = nil) {
        
        //Checks to see if the URL string is valid
        guard let tempURL = NSURL(string: url) else {
            self.runDelegateProtocolFunction("Error: could not create URL from string", error: "", url: url)
            return
        }
        //Creates the session and request
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: tempURL)
        request.HTTPMethod = method.rawValue
        
        do {
            //TODO: Add GET protocols
            switch contentType {
            case .json:
                //Converts the params object to JSON in the HTTP request
                let jsonPost = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
                request.HTTPBody = jsonPost
                request.addValue(ContentType.json.rawValue , forHTTPHeaderField: ContentType.headerFieldValue)
            case .urlEncode:
                //Convert the Dictionary to a String
                var postValues: String = ""
                for (key, value) in params{
                    if postValues == ""{ //Initial run
                        postValues += "\(key)=\(value)"
                    }
                    else { // Need to do have & in between each param
                        postValues += "&\(key)=\(value)"
                    }
                }
                //Must encode the request to HTTPRequest
                request.HTTPBody = postValues.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                //Needed to let the Server know what kind of data that is being sent
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            case .multipartForm:
                //TODO: Implement multipart/form-data
                print ("Not Implemented yet")
                return
            case .textHTML:
                //TODO: Implement text/HTML
                print ("Not Implemented yet")
                return
            }
        } catch {
            self.runDelegateProtocolFunction("Error: could not convert params to JSON", error: "", url: url)
            return
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            
            //First checks to see if the data is not nil
            guard let resultData = data else {
                self.runDelegateProtocolFunction("Error: did not recieve data", error: "", url: url)
                return
            }
            
            //Checks to see if there were any errors in the request
            guard error == nil else {
                self.runDelegateProtocolFunction("Error in calling POST on \(request)", error: "\(request)", url: url)
                print(error)
                return
            }
            
            let json:[String: AnyObject]!
            
            //Try to convert the data stream to a dictionary
            do {
                json = try NSJSONSerialization.JSONObjectWithData(resultData, options: .MutableLeaves) as! [String: AnyObject]
            } catch {
                let jsonString = String(data: resultData, encoding: NSUTF8StringEncoding)
                self.runDelegateProtocolFunction("Error could not parse JSON: '\(jsonString)'", error: jsonString!, url: url)
                return
            }
            
            if let success = isSuccess {
                self.runDelegateProtocolFunction("\"\(success)\": \(json[success])", results: json, url: url)
            } else {
                self.runDelegateProtocolFunction("REST call was successful", results: json, url: url)
            }
            
        })
        
        task.resume()
    }
    
    //MARK: Helper Functions
    /**
     This runs the delegate method `self.delegate.didNotReceiveAPIResults` and dispatches it to the main thread
     
     - parameter printString: the `String` to be printed to the console
     - parameter error:       the error string parameter for the function `RESTControllerProtocol.didNotRecieveAPIResults`
     - parameter url:         the url string parameter for the function `RESTControllerProtocol.didNotRecieveAPIResults`
     */
    private func runDelegateProtocolFunction(printString: String, error: String, url: String) {
        print(printString)
        dispatch_async(dispatch_get_main_queue(), {
            self.delegate.didNotReceiveAPIResults(error, url: url)
        })
    }
    
    /**
     This runs the delegate method `self.delegate.didReceiveAPIResults` and dispatches it to the main thread
     
     - parameter printString: the `String` to be printed to the console
     - parameter results:       the results `[String: AnyObject]!` parameter for the function `RESTControllerProtocol.didRecieveAPIResults`
     - parameter url:         the url string parameter for the function `RESTControllerProtocol.didRecieveAPIResults`
     */
    private func runDelegateProtocolFunction(printString: String, results: [String: AnyObject]!, url: String) {
        print(printString)
        dispatch_async(dispatch_get_main_queue(), {
            self.delegate.didReceiveAPIResults(results, url: url)
        })
    }
}


