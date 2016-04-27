# Making REST Calls Reusable

In most of my projects, I have to do some kind of server-data call and it normally uses the RESTful API. Thus I created a RESTController class that makes the URL calls without me having to recode up the NSURLSession each time with all the error checking involved.

The RESTController class and makes REST calls to a server that expects JSON data as a return type. It then converts the JSON results to a Dictionary. The RESTControllerProtocol allows users to later define what to do on an error, or success.

## class RESTController

This is where the bulk of the work is done. This uses the RESTControllerProtocol as its delegate.

### func restCall 
Make a REST call to a server. method, contentType and isSuccess are optional parameters
     
*Note:* this function only currently works for the Content-Type `application/json`. Additional content types will
 - parameter params: A dictionary of `key:value` parameters to be passed in the url rest call
 - parameter url:    the string of the url for the server
 - parameter method: either `POST` or `GET`. Default is POST
 - parameter contentType: only supports json and urlEncode currently. Default value is .json
 - parameter isSuccess: a string that is the key of the (key:value) in the JSON data result. It is usually "success"

```swift
func restCall (params : [String: String], url : String, method: HTTPMethod = HTTPMethod.post, contentType: ContentType = ContentType.json, isSuccess: String? = nil)
```