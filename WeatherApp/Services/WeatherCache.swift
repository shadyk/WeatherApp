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

    func retrieve(completion: @escaping RetrievalCompletion)
    
}
