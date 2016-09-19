//
//  ResteaurantCell.swift
//  RestaurantFinder
//
//  Created by James Daniell on 12/09/2016.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import UIKit

class RestaurantCell: UITableViewCell
{
    @IBOutlet weak var restaurantTitleLabel: UILabel!
    @IBOutlet weak var restaurantCheckinLabel: UILabel!
    @IBOutlet weak var restaurantCategoryLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
