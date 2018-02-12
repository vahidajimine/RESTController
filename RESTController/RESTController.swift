//
//  RESTController.swift
//
//  Created by Vahid Ajimine on 3/31/16.
//  Copyright © 2016 Vahid Ajimine. All rights reserved.

import Foundation
//MARK: -
/** 
 The class that makes JSON RESTful calls to a server
 
 NOTE: Only POST calls are supported at this time.
*/
public class RESTController {
    
    /// The delegate functions for this class
    weak var delegate: RESTControllerDelegate?
    
    /**
     Initializes this class
     
     - parameter delegate: the delegate protocol definitions. Usually set to self
     
     - returns: creates a REST call object
     */
    init(delegate: RESTControllerDelegate) {
        self.delegate = delegate
    }
    
    /**
     Make a REST call to a server. method, contentType and isSuccess are optional parameters
     
     Note: this function only currently works for the Content-Type `application/json`. Additional content types will
     
     - parameter url: the string of the url for the server
     - parameter headers: A dictionary of `key:value` to be added to the http header call
     - parameter params: A dictionary of `key:value` parameters to be passed in the url rest call
     - parameter method: either `POST` or `GET`. Default is POST
     - parameter contentType: only supports json and urlEncode currently. Default value is .json
     - parameter isSuccess: a string that is the key of the (key:value) in the JSON data result. It is usually "success"
     */
    public func restCall(url: String, headers: [String:String]? = nil, params: [String: String] = [:], method: HTTPMethod = HTTPMethod.post, contentType: ContentType = ContentType.json, isSuccess: String? = nil) {
        
        //Checks to see if the URL string is valid
        guard let tempURL = URL(string: url) else {
            self.runDelegateProtocolFunction(printString: "Error: could not create URL from string", error: "", url: url)
            return
        }
        //Creates the session and request
        //let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let session = URLSession(configuration: URLSessionConfiguration.default)
        var request: URLRequest = URLRequest(url: tempURL)
        request.httpMethod = method.rawValue
        
        if let hasHeaders = headers {
            for (key,value) in hasHeaders{
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        do {
            if (method == .post) {
                switch contentType {
                case .json:
                    //Converts the params object to JSON in the HTTP request
                    let jsonPost = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
                    request.httpBody = jsonPost
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
                    request.httpBody = postValues.data(using: String.Encoding.utf8, allowLossyConversion: true)
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
            } else { //GET
                for (key,value) in params {
                    request.addValue(value, forHTTPHeaderField: key)
                }
            }
        } catch {
            self.runDelegateProtocolFunction(printString: "Error: could not convert params to JSON", error: "", url: url)
            return
        }
        
        //MARK: After call
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            
            //First checks to see if the data is not nil
            guard let resultData = data else {
                self.runDelegateProtocolFunction(printString: "Error: did not recieve data", error: "", url: url)
                return
            }
            
            //Checks to see if there were any errors in the request
            guard error == nil else {
                self.runDelegateProtocolFunction(printString:"Error in calling POST on \(request)", error: "\(request)", url: url)
                print(error!)
                return
            }
            
            let json:[String: AnyObject]
            
            //Try to convert the data stream to a dictionary
            do {
                //print(resultData) //Debug print
                json = try JSONSerialization.jsonObject(with: resultData, options: .mutableLeaves) as! [String: AnyObject]
                //print(json) //Debug print
            } catch {
                let jsonString = String(data: resultData, encoding: String.Encoding.utf8)
                self.runDelegateProtocolFunction(printString: "Error could not parse JSON: '\(jsonString!)'", error: jsonString!, url: url)
                return
            }
            
            if let success = isSuccess {
                self.runDelegateProtocolFunction(printString: "\"\(success)\": \(json[success]!)", results: json, url: url)
            } else {
                self.runDelegateProtocolFunction(printString: "REST call was successful", results: json, url: url)
            }
            
        })
        
        task.resume()
    }
    
    //MARK: - Helper Functions
    /**
     This runs the delegate method `self.delegate.didNotReceiveAPIResults` and dispatches it to the main thread
     
     - parameter printString: the `String` to be printed to the console
     - parameter error:       the error string parameter for the function `RESTControllerProtocol.didNotRecieveAPIResults`
     - parameter url:         the url string parameter for the function `RESTControllerProtocol.didNotRecieveAPIResults`
     */
    private func runDelegateProtocolFunction(printString: String, error: String, url: String) {
        print(printString)
        DispatchQueue.main.async{ self.delegate?.didNotReceiveAPIResults(error: error, url: url) }
    }
    
    /**
     This runs the delegate method `self.delegate.didReceiveAPIResults` and dispatches it to the main thread
     
     - parameter printString: the `String` to be printed to the console
     - parameter results:       the results `[String: AnyObject]` parameter for the function `RESTControllerProtocol.didRecieveAPIResults`
     - parameter url:         the url string parameter for the function `RESTControllerProtocol.didRecieveAPIResults`
     */
    private func runDelegateProtocolFunction(printString: String, results: [String: AnyObject], url: String) {
        print(printString)
        DispatchQueue.main.async {self.delegate?.didReceiveAPIResults(results: results, url: url) }
    }
}


