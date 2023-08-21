//
//  Created by Shady
//  All rights reserved.
//  

import UIKit

class ListTableCell: UITableViewCell {
    
    var thumbnail: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    
    var lblTitle: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20)
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()

    var lblSubtitle: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20)
        l.textColor = .gray
        l.textAlignment = .left
        return l
    }()
    
    private lazy var sep = UIView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupInterface()
    }
    
    private func setupInterface(){
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(thumbnail)
        contentView.addSubview(lblTitle)
        contentView.addSubview(lblSubtitle)
        contentView.addSubview(sep)
        
        thumbnail.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.size.equalTo(80)
            make.centerY.equalToSuperview()
        }
        
        lblTitle.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 12))
            make.leading.equalTo(thumbnail.snp.trailing).offset(12)
        }
        lblSubtitle.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 12))
            make.top.equalTo(lblTitle.snp_bottomMargin).offset(12)
            make.leading.equalTo(thumbnail.snp.trailing).offset(12)
        }
        sep.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
            make.height.equalTo(1)
        }
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
