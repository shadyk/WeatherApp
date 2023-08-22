//
//  Created by Shady
//  All rights reserved.
//  

import UIKit
final class ListCellController {
    
    private var cell: ListTableCell?
    var viewModel: ViewItem?
    
    init(viewModel: ViewItem? = nil) {
        self.viewModel = viewModel
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        
        cell = tableView.dequeueReusableCell()
        cell?.thumbnail.alpha = 0
        cell?.lblSubtitle.alpha = 0
        cell?.lblTitle.alpha = 0
        
        cell?.lblSubtitle.text = viewModel?.value
        cell?.lblTitle.text = viewModel?.title
        cell?.thumbnail.image = UIImage(systemName: viewModel?.systemImage ?? "sun.min")
        
        if cell?.thumbnail.alpha == 0.0 {
            UIImageView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseIn, animations: {[weak self] in
                self?.cell?.thumbnail.alpha = 1.0
                self?.cell?.lblSubtitle.alpha = 1.0
                self?.cell?.lblTitle.alpha = 1.0

            })
        }
        else {
            UIImageView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseIn, animations: {[weak self] in
                self?.cell?.thumbnail.alpha = 0.0
                self?.cell?.lblSubtitle.alpha = 0.0
                self?.cell?.lblTitle.alpha = 0.0
            })
        }
        return cell!
    }
    
}
