//
//  Created by Shady
//  All rights reserved.
//  

import UIKit
final class ListCellController {
    
    private var cell: ListTableCell?
    var viewModel: WeatherViewmodel?
    
    init(viewModel: WeatherViewmodel? = nil) {
        self.viewModel = viewModel
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.lblSubtitle.text = viewModel?.value
        cell?.lblTitle.text = viewModel?.title
        cell?.thumbnail.image = UIImage(systemName: "cloud.sun.rain")
        return cell!
    }

}
