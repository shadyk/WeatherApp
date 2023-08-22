//
//  Created by Shady
//  All rights reserved.
//  

import Foundation
typealias InsertionResult = Result<Void, Error>
typealias InsertionCompletion = (InsertionResult) -> Void

typealias RetrievalResult = Result<WeatherViewModel?, Error>
typealias RetrievalCompletion = (RetrievalResult) -> Void

protocol WeatherCache{
    
    func insert(_ weather: WeatherViewModel, completion: @escaping InsertionCompletion)
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
    
}
