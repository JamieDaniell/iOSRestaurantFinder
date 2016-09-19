//
//  APIClient.swift
//  RestaurantFinder
//
//  Created by Pasan Premaratne on 5/4/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation

public let TRENetworkingErrorDomain = "com.Stormy.NetworkingError"

// IN caase of error
public let MissingHTTPResponseError: Int = 10
public let UnexpectedResponseError: Int = 20

protocol JSONDecodable
{
    init?(JSON: [String : AnyObject])
}

protocol Endpoint
{
    var baseURL: String { get }
    var path: String { get }
    var parameters: [String: AnyObject] { get }
}

extension Endpoint
{
    var queryComponents: [NSURLQueryItem]
    {
        var components = [NSURLQueryItem]()
        for ( key, value ) in parameters
        {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.append(queryItem)
        }
        return components
    }
    var request: NSURLRequest
    {
        let components = NSURLComponents(string: baseURL)!
        components.path = path
        components.queryItems = queryComponents
        
        
        let url = components.URL!
        return NSURLRequest(URL: url)
    }
}

typealias JSON = [String: AnyObject]
typealias JSONCompletion = (JSON?, NSHTTPURLResponse?, NSError?) -> Void
typealias JSONTask = NSURLSessionDataTask

enum APIResult<T>
{
    case Success(T)
    case Failure(ErrorType)
}

// Defines the Api client- It must have 
// --> A conficuration which it can set 
// --> A session
// --> A JSON task that returns a json task - Defined as NSURLSessionDataTask
// --> fetch which takes a type JSON decodable and two closures
protocol APIClient
{
    var configuration: NSURLSessionConfiguration { get }
    var session: NSURLSession { get }
    
    // take a request object and create a data task with a session and then define the body of the completion handler and then return the task
    func JSONTaskWithRequest(request: NSURLRequest, completion: JSONCompletion) -> JSONTask
    func fetch<T: JSONDecodable>(request: NSURLRequest, parse: JSON -> T?, completion: APIResult<T> -> Void)
}

extension APIClient
{
    func JSONTaskWithRequest(request: NSURLRequest, completion: JSONCompletion) -> JSONTask
    {
        
        // create the task ( a function ) and session has a completion closure
        // There are three parts to the request if request is successful -> data, response and error which are run over a function
        // The ultimate aim is to pass a value to completion
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            // guard against failure
            guard let HTTPResponse = response as? NSHTTPURLResponse else
            {
                // return a failure
                let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "")]
                let error = NSError(domain: TRENetworkingErrorDomain, code: MissingHTTPResponseError, userInfo: userInfo)
                completion(nil, nil, error)
                return
            }
            // if no data --> Return
            if data == nil
            {
                if let error = error
                {
                    completion(nil, HTTPResponse, error)
                }
            }
            // We have data
            else
            {
                // get the response
                switch HTTPResponse.statusCode
                {
                    case 200:
                        // If we have the right code we succeed and make our json object
                        do
                        {
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String : AnyObject]
                            completion(json, HTTPResponse, nil)
                        }
                        catch let error as NSError
                        {
                            completion(nil, HTTPResponse, error)
                        }
                    default:
                        print("Received HTTP response: \(HTTPResponse.statusCode), which was not handled")
                }
            }
        }
        return task
    }
    
    // Fetch function gets the actual data
    // parse function takes some json and tries to make it into some model 
    // completion function takes some result
    func fetch<T>(request: NSURLRequest, parse: JSON -> T?, completion: APIResult<T> -> Void)
    {
        // get the task ( a function )which if request is sucessful will run the parts over a function
        // the fucntion is defined by JSONCompletionTask
        // starts the JSONTaskWithRequest and the correspoiding closure
        let task = JSONTaskWithRequest(request) { json, response, error in
            
            // get the main thread
            dispatch_async(dispatch_get_main_queue())
            {
                //make sure the json exists
                guard let json = json else
                {
                    // if there is an error
                    if let error = error
                    {
                        completion(.Failure(error))
                    }
                    else
                    {
                        // TODO: Implement error handling
                    }
                    return
                }
                // if json is able to be parsed gove back the completion enum APIResult
                if let resource = parse(json)
                {
                    completion(.Success(resource))
                }
                // if there has been an error show and pass through
                else
                {
                    let error = NSError(domain: TRENetworkingErrorDomain, code: UnexpectedResponseError, userInfo: nil)
                    completion(.Failure(error))
                }
            }
        }
        task.resume()
    }
    
    func fetch<T: JSONDecodable>(endpoint: Endpoint, parse:  JSON ->[T]?, completion: APIResult<[T]> -> Void)
    {
        
        let request = endpoint.request
        let task = JSONTaskWithRequest(request){ json, response, error in
            
            // get the main thread
            dispatch_async(dispatch_get_main_queue())
            {
                //make sure the json exists
                guard let json = json else
                {
                    // if there is an error
                    if let error = error
                    {
                        completion(.Failure(error))
                    }
                    else
                    {
                        // TODO: Implement error handling
                    }
                    return
                }
                // if json is able to be parsed gove back the completion enum APIResult
                if let resource = parse(json)
                {
                    completion(.Success(resource))
                }
                    // if there has been an error show and pass through
                else
                {
                    let error = NSError(domain: TRENetworkingErrorDomain, code: UnexpectedResponseError, userInfo: nil)
                    completion(.Failure(error))
                }
            }
        }
        task.resume()

    }
}

