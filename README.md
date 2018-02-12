# Making REST Calls Reusable

In most of my projects, I have to do some kind of server-data call and it normally uses the RESTful API. Thus I created a `RESTController` class that makes the URL calls without me having to recode up the `URLSession` each time with all the error checking involved. I updated this code to Swift 4.0 and it should be compatible with iOS 9.0+.

The `RESTController` class and makes REST calls to a server that expects JSON data as a return type. It then converts the JSON results to a `Dictionary`. The `RESTControllerDelegate` allows users to later define what to do on an error, or success.

## RESTController

This is where the bulk of the work is done. This uses the `RESTControllerDelegate` as its delegate.

### Primary Functions
#### func restCall 
Makes a REST call to a server. `method`, `headers`, `params`, `contentType` and `isSuccess` are optional parameters. 
     
*Note:* this function only currently works for the Content-Type `application/json`.
 - parameter `url`:         the string of the url for the server
 - parameter `headers`:     A dictionary of `key:value` to be added to the http header call
 - parameter `params`:      A dictionary of `key:value` parameters to be passed in the url rest call
 - parameter `method`:      either `POST` or `GET`. Default is `POST`
 - parameter `contentType`: only supports json and urlEncode currently. Default value is .json
 - parameter `isSuccess`:   a `string` that is the `key` of the `(key:value)` in the `JSON` data result. It is usually "success"

##### Function Delclaration
```swift
func restCall(url: String, headers: [String:String]? = nil, params: [String: String] = [:], method: HTTPMethod = HTTPMethod.post, contentType: ContentType = ContentType.json, isSuccess: String? = nil)
```

## RESTControllerDelegate
This `delegate` contains the functions that handles what do to with the data recieved from the server on a *success* or *fail*.

### Delegate Functions

#### func didReceiveAPIResults
The REST call was successful and returned a valid JSON result and was able to convert it to a `[key:value]` pair `Dictionary`.
- parameter `results`: the JSON data in a `Dictionary` format
- parameter `url`:     the server url in a string format

##### Function Declaration
```swift
func didReceiveAPIResults(results: [String: AnyObject]!, url: String)
```

#### func didNotReceiveAPIResults
The REST call was unsuccessful. This is defaulted to do nothing, but you may want to add addtional functionality later.
- parameter `error`: the error string
- parameter `url`:   the server url

##### Function Declaration
```swift
func didNotReceiveAPIResults(error: String, url: String)
```