//
//  UserDetailTableViewCell.swift
//  CQAssignment
//
//  Created by Neel Nishant on 12/01/20.
//  Copyright © 2020 Neel Nishant. All rights reserved.
//

import UIKit


//custom UITableView Cell
class UserDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
