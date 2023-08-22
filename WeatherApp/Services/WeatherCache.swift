//
//  Created by Shady
//  All rights reserved.
//  

import Foundation
typealias InsertionResult = Result<Void, Error>
typealias InsertionCompletion = (InsertionResult) -> Void

protocol WeatherCache{
    
    func insert(_ weather: WeatherViewModel, completion: @escaping InsertionCompletion)
}
